-- JSON items format: [{ "product_id": "...", "quantity": 2 }]

CREATE OR REPLACE FUNCTION public.fn_create_sale(
  p_shop_id uuid,
  p_cashier_id uuid,
  p_items jsonb,
  p_payment_type text
)
RETURNS TABLE (
  sale_id uuid,
  total_amount numeric
) AS $$
DECLARE
  v_item        jsonb;
  v_product_id  uuid;
  v_quantity    integer;
  v_unit_price  numeric;
  v_subtotal    numeric;
  v_total       numeric := 0;
BEGIN
  -- Start implicit transaction (function body runs in a single tx)

  -- 1) Create empty sale row first
  INSERT INTO public.sales (shop_id, cashier_id, payment_type)
  VALUES (p_shop_id, p_cashier_id, p_payment_type)
  RETURNING id INTO sale_id;

  -- 2) Loop through items, lock product, check stock, update stock, insert sale_items
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_product_id := (v_item ->> 'product_id')::uuid;
    v_quantity   := (v_item ->> 'quantity')::int;

    IF v_quantity <= 0 THEN
      RAISE EXCEPTION 'Quantity must be > 0' USING ERRCODE = '22023';
    END IF;

    -- Lock product row
    SELECT unit_price, stock_qty
    INTO v_unit_price, v_quantity  -- reusing v_quantity for stock check
    FROM public.products
    WHERE id = v_product_id
    FOR UPDATE;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Product % not found', v_product_id USING ERRCODE = '22023';
    END IF;

    IF v_quantity < (v_item ->> 'quantity')::int THEN
      RAISE EXCEPTION 'Insufficient stock for product %', v_product_id USING ERRCODE = '22023';
    END IF;

    -- Restore quantity input, compute subtotal
    v_quantity  := (v_item ->> 'quantity')::int;
    v_subtotal  := v_unit_price * v_quantity;
    v_total     := v_total + v_subtotal;

    -- Decrease stock
    UPDATE public.products
    SET stock_qty = stock_qty - v_quantity
    WHERE id = v_product_id;

    -- Insert sale item
    INSERT INTO public.sale_items (sale_id, product_id, quantity, price, subtotal)
    VALUES (sale_id, v_product_id, v_quantity, v_unit_price, v_subtotal);
  END LOOP;

  -- 3) Update sale total
  UPDATE public.sales
  SET total_amount = v_total
  WHERE id = sale_id;

  total_amount := v_total;
  RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- PHASE E: PAYMENTS & RECONCILIATION TABLES + CONSTRAINTS
-- =========================================================

-- Payments main table: one row per payment attempt
CREATE TABLE IF NOT EXISTS public.payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id uuid NOT NULL REFERENCES public.sales (id) ON DELETE RESTRICT,
  provider text NOT NULL CHECK (provider IN ('chapa', 'telebirr')),
  reference text NOT NULL UNIQUE,
  amount numeric(12, 2) NOT NULL CHECK (amount > 0),
  currency text NOT NULL,
  status text NOT NULL CHECK (status IN ('pending', 'success', 'failed', 'refunded')),
  created_at timestamptz NOT NULL DEFAULT now(),
  verified_at timestamptz
);

-- Raw webhook / callback events for full audit trail
CREATE TABLE IF NOT EXISTS public.payment_events (
  id bigserial PRIMARY KEY,
  payment_id uuid NOT NULL REFERENCES public.payments (id) ON DELETE CASCADE,
  provider text NOT NULL,
  raw_payload jsonb NOT NULL,
  received_at timestamptz NOT NULL DEFAULT now()
);

-- Enforce valid, one‑way status transitions at the DB level
CREATE OR REPLACE FUNCTION public.fn_enforce_payment_status_transition()
RETURNS trigger AS $$
BEGIN
  -- Allow inserts freely
  IF TG_OP = 'INSERT' THEN
    RETURN NEW;
  END IF;

  -- Idempotent re-writes of same status are allowed
  IF NEW.status = OLD.status THEN
    RETURN NEW;
  END IF;

  -- Valid transitions:
  -- pending -> success | failed
  -- success -> refunded (if you later implement refunds)
  -- failed  -> failed (idempotent)
  IF OLD.status = 'pending' AND NEW.status IN ('success', 'failed') THEN
    RETURN NEW;
  ELSIF OLD.status = 'success' AND NEW.status IN ('success', 'refunded') THEN
    RETURN NEW;
  ELSIF OLD.status = 'failed' AND NEW.status = 'failed' THEN
    RETURN NEW;
  END IF;

  RAISE EXCEPTION 'Invalid payment status transition: % -> %', OLD.status, NEW.status
    USING ERRCODE = '22023';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_enforce_payment_status_transition ON public.payments;

CREATE TRIGGER tr_enforce_payment_status_transition
BEFORE UPDATE ON public.payments
FOR EACH ROW
EXECUTE FUNCTION public.fn_enforce_payment_status_transition();
