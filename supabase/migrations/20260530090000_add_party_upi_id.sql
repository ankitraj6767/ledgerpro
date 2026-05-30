-- Add an optional per-party UPI id so each customer/supplier can carry their
-- own collection UPI handle for payment QR generation.
alter table public.parties
  add column if not exists upi_id text;
