// backend/functions/create-sale/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

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

    const { shop_id, items, payment_type } = body;

    if (!shop_id || !Array.isArray(items) || items.length === 0 || !payment_type) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    // Server-side Supabase client (service role) but still validate JWT
    const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
      global: {
        headers: { Authorization: `Bearer ${token}` },
      },
    });

    // 1) Get current user
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: "Unauthenticated" }),
        { status: 401, headers: { "Content-Type": "application/json" } },
      );
    }

    const userId = user.id;

    // 2) Authorization: is this user allowed to sell for this shop?
    // Adjust to your actual schema (e.g. shop_users table).
    const { data: shopRow, error: shopErr } = await supabase
      .from("shops")
      .select("id, owner_id")
      .eq("id", shop_id)
      .maybeSingle();

    if (shopErr || !shopRow) {
      return new Response(
        JSON.stringify({ error: "Shop not found" }),
        { status: 404, headers: { "Content-Type": "application/json" } },
      );
    }

    const { data: me, error: meErr } = await supabase
      .from("users")
      .select("role")
      .eq("id", userId)
      .maybeSingle();

    if (meErr || !me) {
      return new Response(
        JSON.stringify({ error: "User profile not found" }),
        { status: 403, headers: { "Content-Type": "application/json" } },
      );
    }

    const isOwner = shopRow.owner_id === userId;
    const isSeller = ["seller", "admin"].includes(me.role);

    if (!isOwner && !isSeller) {
      return new Response(
        JSON.stringify({ error: "Not allowed to create sales for this shop" }),
        { status: 403, headers: { "Content-Type": "application/json" } },
      );
    }

    // 3) Call transactional SQL function
    const { data: result, error: rpcErr } = await supabase
      .rpc("fn_create_sale", {
        p_shop_id: shop_id,
        p_cashier_id: userId,
        p_items: items,
        p_payment_type: payment_type,
      });

    if (rpcErr) {
      // Map common business errors to 409 / 400
      const msg = rpcErr.message || "";
      const status = msg.includes("Insufficient stock") ? 409 : 400;

      return new Response(
        JSON.stringify({ error: rpcErr.message }),
        { status, headers: { "Content-Type": "application/json" } },
      );
    }

    // 4) Audit log
    await supabase.from("audit_logs").insert({
      user_id: userId,
      event_type: "create_sale",
      meta: { shop_id, items, payment_type, result },
    });

    // 5) Return receipt data
    return new Response(
      JSON.stringify({
        sale_id: result?.[0]?.sale_id ?? null,
        total_amount: result?.[0]?.total_amount ?? null,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (e) {
    console.error(e);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});