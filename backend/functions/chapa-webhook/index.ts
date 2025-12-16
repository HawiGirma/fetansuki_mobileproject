import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const CHAPA_WEBHOOK_SECRET = Deno.env.get("CHAPA_WEBHOOK_SECRET")!;

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return new Response("Method Not Allowed", { status: 405 });
    }

    // 1) Verify webhook signature / shared secret
    const signature = req.headers.get("Chapa-Signature");
    if (!signature || signature !== CHAPA_WEBHOOK_SECRET) {
      return new Response("Invalid signature", { status: 401 });
    }

    // 2) Parse payload
    const payload = await req.json();

    const reference = payload?.tx_ref;
    const status = payload?.status;
    const amount = Number(payload?.amount);
    const currency = payload?.currency ?? payload?.currency_code;

    if (!reference || !status || !amount || !currency) {
      return new Response("Invalid payload", { status: 400 });
    }

    // 3) Find associated payment record by reference
    const { data: payment, error } = await supabase
      .from("payments")
      .select("*")
      .eq("reference", reference)
      .single();

    if (error || !payment) {
      return new Response("Payment not found", { status: 404 });
    }

    // 4) Idempotency: if we've already processed a final state, just ack
    if (payment.status === "success" || payment.status === "failed") {
      await supabase.from("payment_events").insert({
        payment_id: payment.id,
        provider: "chapa",
        raw_payload: payload,
      });

      return new Response("Already processed", { status: 200 });
    }

    // 5) Validate amount & currency to prevent tampering
    if (Number(payment.amount) !== amount || payment.currency !== currency) {
      await supabase.from("payment_events").insert({
        payment_id: payment.id,
        provider: "chapa",
        raw_payload: payload,
      });

      return new Response("Amount or currency mismatch", { status: 409 });
    }

    const newStatus = status === "success" ? "success" : "failed";

    // 6) Update payment and mark sale as paid (if successful)
    const { error: updateError } = await supabase
      .from("payments")
      .update({
        status: newStatus,
        verified_at: newStatus === "success" ? new Date().toISOString() : null,
      })
      .eq("id", payment.id);

    if (updateError) throw updateError;

    // 7) Persist raw webhook event for audit trail
    await supabase.from("payment_events").insert({
      payment_id: payment.id,
      provider: "chapa",
      raw_payload: payload,
    });

    if (newStatus === "success") {
      await supabase
        .from("sales")
        .update({ payment_status: "paid" })
        .eq("id", payment.sale_id);
    }

    return new Response("OK", { status: 200 });
  } catch (err) {
    console.error(err);
    return new Response("Server error", { status: 500 });
  }
});

