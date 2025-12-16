import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const CHAPA_SECRET_KEY = Deno.env.get("CHAPA_SECRET_KEY")!;
const APP_BASE_URL = Deno.env.get("APP_BASE_URL")!; // e.g. https://your-app.com

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

function generateReference(prefix: string = "FSK"): string {
  const random = crypto.randomUUID().replace(/-/g, "").slice(0, 16);
  return `${prefix}_${random}`;
}

serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed" }),
        { status: 405, headers: { "Content-Type": "application/json" } },
      );
    }

    const authHeader = req.headers.get("Authorization") ?? "";
    const token = authHeader.replace("Bearer ", "").trim();

    if (!token) {
      return new Response(
        JSON.stringify({ error: "Missing auth token" }),
        { status: 401, headers: { "Content-Type": "application/json" } },
      );
    }

    const body = await req.json().catch(() => null);
    if (!body) {
      return new Response(
        JSON.stringify({ error: "Invalid JSON body" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    const { sale_id, provider } = body;

    if (!sale_id || !provider) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    if (provider !== "chapa") {
      return new Response(
        JSON.stringify({ error: "Unsupported provider" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    // Attach auth context to Supabase
    const authed = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
      global: { headers: { Authorization: `Bearer ${token}` } },
    });

    // 1) Get current user
    const {
      data: { user },
      error: userError,
    } = await authed.auth.getUser();

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: "Unauthenticated" }),
        { status: 401, headers: { "Content-Type": "application/json" } },
      );
    }

    // 2) Load sale and ensure it belongs to this user context
    const { data: sale, error: saleErr } = await authed
      .from("sales")
      .select("id, shop_id, total_amount, currency, payment_status")
      .eq("id", sale_id)
      .maybeSingle();

    if (saleErr || !sale) {
      return new Response(
        JSON.stringify({ error: "Sale not found" }),
        { status: 404, headers: { "Content-Type": "application/json" } },
      );
    }

    if (sale.payment_status === "paid") {
      return new Response(
        JSON.stringify({ error: "Sale already paid" }),
        { status: 409, headers: { "Content-Type": "application/json" } },
      );
    }

    const amount = Number(sale.total_amount);
    if (!Number.isFinite(amount) || amount <= 0) {
      return new Response(
        JSON.stringify({ error: "Invalid sale amount" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    const currency = sale.currency ?? "ETB";

    // 3) Generate unique reference and create payments row (pending)
    const reference = generateReference("FSK");

    const { data: payment, error: paymentErr } = await supabase
      .from("payments")
      .insert({
        sale_id,
        provider: "chapa",
        reference,
        amount,
        currency,
        status: "pending",
      })
      .select("*")
      .single();

    if (paymentErr || !payment) {
      return new Response(
        JSON.stringify({ error: "Failed to create payment" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    // 4) Call Chapa initialize API
    const callbackUrl = `${APP_BASE_URL}/api/chapa-webhook`;

    const res = await fetch("https://api.chapa.co/v1/transaction/initialize", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${CHAPA_SECRET_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        amount: amount.toString(),
        currency,
        email: user.email ?? "customer@example.com",
        tx_ref: reference,
        callback_url: callbackUrl,
        // Optional: customization and metadata
        "customization[title]": "FetanSuki Payment",
        "customization[description]": "POS sale payment",
        // You can also send metadata: { sale_id, user_id: user.id }
      }),
    });

    const chapaPayload = await res.json().catch(() => null);

    if (!res.ok || !chapaPayload || chapaPayload.status !== "success") {
      // Mark payment as failed on provider-init error
      await supabase
        .from("payments")
        .update({ status: "failed" })
        .eq("id", payment.id);

      return new Response(
        JSON.stringify({ error: "Failed to initialize payment" }),
        { status: 502, headers: { "Content-Type": "application/json" } },
      );
    }

    const paymentUrl =
      chapaPayload.data?.checkout_url ?? chapaPayload.data?.authorization_url;

    if (!paymentUrl) {
      return new Response(
        JSON.stringify({ error: "Missing checkout URL from provider" }),
        { status: 502, headers: { "Content-Type": "application/json" } },
      );
    }

    // 5) Return payment URL and reference to client
    return new Response(
      JSON.stringify({
        payment_id: payment.id,
        reference,
        payment_url: paymentUrl,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error(err);
    return new Response(
      JSON.stringify({ error: "Server error" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});


