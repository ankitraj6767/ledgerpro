create extension if not exists pgcrypto;

create schema if not exists ledger_private;

do $$
begin
  create type public.member_role as enum ('owner', 'manager', 'accountant', 'staff');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.party_kind as enum ('customer', 'supplier', 'both');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.ledger_transaction_type as enum (
    'you_gave',
    'you_got',
    'sale',
    'purchase',
    'expense',
    'refund',
    'adjustment',
    'discount_write_off',
    'opening_balance'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.payment_mode as enum ('cash', 'upi', 'bank', 'card', 'cheque', 'wallet', 'other');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.sync_status as enum ('synced', 'pending', 'failed');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.payment_status as enum (
    'pending',
    'manually_confirmed',
    'gateway_confirmed',
    'failed',
    'cancelled'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.invoice_status as enum (
    'draft',
    'sent',
    'partially_paid',
    'paid',
    'overdue',
    'cancelled'
  );
exception when duplicate_object then null;
end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  avatar_path text,
  default_language text not null default 'en',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.businesses (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id),
  business_name text not null,
  owner_name text not null,
  phone text not null,
  address text,
  gstin text,
  upi_id text,
  logo_path text,
  default_language text not null default 'en',
  default_currency text not null default 'INR' check (default_currency = 'INR'),
  business_category text,
  financial_year_start date not null default make_date(extract(year from now())::int, 4, 1),
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.business_members (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  user_id uuid not null references public.profiles(id),
  role public.member_role not null default 'staff',
  permissions text[] not null default '{}',
  assigned_book_ids uuid[],
  invited_by uuid references auth.users(id),
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (business_id, user_id)
);

create table if not exists public.books (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  name text not null,
  is_default boolean not null default false,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (business_id, name)
);

create table if not exists public.parties (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid not null references public.books(id),
  kind public.party_kind not null default 'customer',
  name text not null,
  phone text,
  alternate_phone text,
  address text,
  gstin text,
  opening_balance_paise bigint not null default 0,
  cached_balance_paise bigint not null default 0,
  credit_limit_paise bigint not null default 0 check (credit_limit_paise >= 0),
  tags text[] not null default '{}',
  notes text,
  profile_image_path text,
  search_vector tsvector not null default ''::tsvector,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.party_tags (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid references public.books(id),
  party_id uuid not null references public.parties(id),
  tag text not null,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (party_id, tag)
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid not null references public.books(id),
  party_id uuid not null references public.parties(id),
  type public.ledger_transaction_type not null,
  amount_paise bigint not null check (amount_paise > 0),
  occurred_at timestamptz not null default now(),
  payment_mode public.payment_mode not null default 'cash',
  note text,
  due_date date,
  reminder_date timestamptz,
  attachment_path text,
  original_transaction_id uuid references public.transactions(id),
  reversal_transaction_id uuid references public.transactions(id),
  is_reversal boolean not null default false,
  sync_status public.sync_status not null default 'synced',
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.transaction_attachments (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid not null references public.books(id),
  transaction_id uuid not null references public.transactions(id),
  storage_path text not null,
  mime_type text,
  size_bytes bigint,
  sync_status public.sync_status not null default 'pending',
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.reminders (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid references public.books(id),
  party_id uuid not null references public.parties(id),
  transaction_id uuid references public.transactions(id),
  channel text not null check (channel in ('whatsapp', 'sms', 'call', 'manual')),
  template_key text,
  message text not null,
  scheduled_at timestamptz,
  sent_at timestamptz,
  provider_status text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.reminder_templates (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.businesses(id),
  name text not null,
  language_code text not null,
  body text not null,
  tone text not null default 'polite',
  is_system boolean not null default false,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid references public.books(id),
  party_id uuid references public.parties(id),
  transaction_id uuid references public.transactions(id),
  amount_paise bigint not null check (amount_paise > 0),
  payment_mode public.payment_mode not null default 'upi',
  status public.payment_status not null default 'pending',
  upi_link text,
  gateway text,
  gateway_payment_id text,
  manually_confirmed_by uuid references auth.users(id),
  confirmed_at timestamptz,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid not null references public.books(id),
  party_id uuid references public.parties(id),
  invoice_number text not null,
  invoice_kind text not null default 'non_gst' check (invoice_kind in ('gst', 'non_gst', 'quotation', 'purchase_bill', 'credit_note', 'debit_note')),
  invoice_date date not null default current_date,
  due_date date,
  subtotal_paise bigint not null default 0 check (subtotal_paise >= 0),
  discount_paise bigint not null default 0 check (discount_paise >= 0),
  cgst_paise bigint not null default 0 check (cgst_paise >= 0),
  sgst_paise bigint not null default 0 check (sgst_paise >= 0),
  igst_paise bigint not null default 0 check (igst_paise >= 0),
  total_paise bigint not null default 0 check (total_paise >= 0),
  paid_paise bigint not null default 0 check (paid_paise >= 0),
  balance_paise bigint generated always as (greatest(total_paise - paid_paise, 0)) stored,
  status public.invoice_status not null default 'draft',
  notes text,
  terms text,
  converted_transaction_id uuid references public.transactions(id),
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (business_id, invoice_number)
);

create table if not exists public.invoice_items (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  invoice_id uuid not null references public.invoices(id),
  product_id uuid,
  item_name text not null,
  hsn_sac text,
  quantity numeric(14, 3) not null check (quantity > 0),
  unit text not null,
  rate_paise bigint not null check (rate_paise >= 0),
  discount_paise bigint not null default 0 check (discount_paise >= 0),
  gst_rate numeric(5, 2) not null default 0 check (gst_rate >= 0),
  cgst_paise bigint not null default 0 check (cgst_paise >= 0),
  sgst_paise bigint not null default 0 check (sgst_paise >= 0),
  igst_paise bigint not null default 0 check (igst_paise >= 0),
  line_total_paise bigint not null check (line_total_paise >= 0),
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.product_categories (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  name text not null,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (business_id, name)
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  category_id uuid references public.product_categories(id),
  supplier_party_id uuid references public.parties(id),
  name text not null,
  sku text,
  barcode text,
  unit text not null default 'pcs',
  purchase_price_paise bigint not null default 0 check (purchase_price_paise >= 0),
  sale_price_paise bigint not null default 0 check (sale_price_paise >= 0),
  gst_rate numeric(5, 2) not null default 0 check (gst_rate >= 0),
  opening_stock numeric(14, 3) not null default 0,
  stock_on_hand numeric(14, 3) not null default 0,
  low_stock_threshold numeric(14, 3) not null default 0,
  image_path text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (business_id, sku)
);

create table if not exists public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid references public.books(id),
  product_id uuid not null references public.products(id),
  party_id uuid references public.parties(id),
  movement_type text not null check (movement_type in ('purchase', 'sale', 'return', 'damage', 'adjustment')),
  quantity numeric(14, 3) not null check (quantity <> 0),
  unit_cost_paise bigint not null default 0 check (unit_cost_paise >= 0),
  reference_transaction_id uuid references public.transactions(id),
  reference_invoice_id uuid references public.invoices(id),
  note text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.business_cards (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  display_name text not null,
  phone text,
  address text,
  gstin text,
  upi_id text,
  card_theme text not null default 'classic',
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid references public.books(id),
  actor_id uuid references auth.users(id),
  entity_table text not null,
  entity_id uuid not null,
  action text not null,
  before_data jsonb,
  after_data jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now()
);

create table if not exists public.app_settings (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid references public.books(id),
  key text not null,
  value jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (business_id, book_id, key)
);

create table if not exists public.export_jobs (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid references public.books(id),
  export_type text not null,
  format text not null check (format in ('pdf', 'csv')),
  filters jsonb not null default '{}'::jsonb,
  storage_path text,
  status text not null default 'queued' check (status in ('queued', 'running', 'ready', 'failed', 'expired')),
  error_message text,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.sync_queue_metadata (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid references public.books(id),
  device_id text not null,
  entity_type text not null,
  entity_id uuid,
  mutation_id text,
  status public.sync_status not null default 'pending',
  attempts integer not null default 0 check (attempts >= 0),
  last_error text,
  last_synced_at timestamptz,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.share_links (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  book_id uuid references public.books(id),
  party_id uuid references public.parties(id),
  export_job_id uuid references public.export_jobs(id),
  token_hash text not null,
  purpose text not null,
  expires_at timestamptz not null,
  revoked_at timestamptz,
  created_by uuid references auth.users(id) default auth.uid(),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

alter table public.invoice_items
  add constraint invoice_items_product_id_fkey
  foreign key (product_id) references public.products(id)
  deferrable initially deferred;

create index if not exists businesses_owner_idx on public.businesses(owner_id) where deleted_at is null;
create index if not exists business_members_user_idx on public.business_members(user_id, business_id) where deleted_at is null;
create index if not exists books_business_idx on public.books(business_id) where deleted_at is null;
create index if not exists parties_book_balance_idx on public.parties(book_id, cached_balance_paise desc) where deleted_at is null;
create index if not exists parties_search_idx on public.parties using gin(search_vector);
create index if not exists parties_phone_idx on public.parties(phone) where deleted_at is null;
create index if not exists transactions_party_time_idx on public.transactions(party_id, occurred_at desc) where deleted_at is null;
create index if not exists transactions_book_time_idx on public.transactions(book_id, occurred_at desc) where deleted_at is null;
create index if not exists transactions_due_idx on public.transactions(book_id, due_date) where deleted_at is null and due_date is not null;
create index if not exists reminders_due_idx on public.reminders(business_id, scheduled_at) where deleted_at is null;
create index if not exists payments_party_idx on public.payments(party_id, created_at desc) where deleted_at is null;
create index if not exists invoices_business_status_idx on public.invoices(business_id, status, invoice_date desc) where deleted_at is null;
create index if not exists products_business_sku_idx on public.products(business_id, sku) where deleted_at is null;
create index if not exists products_low_stock_idx on public.products(business_id) where deleted_at is null and stock_on_hand <= low_stock_threshold;
create index if not exists stock_movements_product_idx on public.stock_movements(product_id, created_at desc) where deleted_at is null;
create index if not exists audit_logs_business_time_idx on public.audit_logs(business_id, created_at desc);
create index if not exists sync_queue_metadata_status_idx on public.sync_queue_metadata(business_id, status, created_at);
create index if not exists share_links_token_idx on public.share_links(token_hash) where revoked_at is null;

create or replace function ledger_private.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function ledger_private.set_party_search_vector()
returns trigger
language plpgsql
as $$
begin
  new.search_vector :=
    to_tsvector(
      'simple',
      coalesce(new.name, '') || ' ' ||
      coalesce(new.phone, '') || ' ' ||
      coalesce(new.alternate_phone, '') || ' ' ||
      coalesce(new.notes, '') || ' ' ||
      array_to_string(coalesce(new.tags, '{}'), ' ')
    );
  return new;
end;
$$;

create or replace function ledger_private.can_access_business(target_business_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.businesses b
    where b.id = target_business_id
      and b.deleted_at is null
      and b.owner_id = (select auth.uid())
  )
  or exists (
    select 1
    from public.business_members bm
    where bm.business_id = target_business_id
      and bm.user_id = (select auth.uid())
      and bm.deleted_at is null
  );
$$;

create or replace function ledger_private.has_permission(target_business_id uuid, required_permission text)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.businesses b
    where b.id = target_business_id
      and b.owner_id = (select auth.uid())
      and b.deleted_at is null
  )
  or exists (
    select 1
    from public.business_members bm
    where bm.business_id = target_business_id
      and bm.user_id = (select auth.uid())
      and bm.deleted_at is null
      and (
        bm.role = 'owner'
        or required_permission = any(bm.permissions)
        or (bm.role = 'manager' and required_permission <> 'manage_staff')
        or (bm.role = 'accountant' and required_permission in ('view_parties', 'add_transaction', 'edit_transaction', 'send_reminders', 'create_invoice', 'export_reports', 'view_dashboard_totals'))
        or (bm.role = 'staff' and required_permission in ('view_parties', 'add_transaction', 'send_reminders'))
      )
  );
$$;

create or replace function ledger_private.add_owner_membership()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  insert into public.business_members (
    business_id,
    user_id,
    role,
    permissions,
    created_by,
    updated_by
  )
  values (
    new.id,
    new.owner_id,
    'owner',
    array[
      'view_parties',
      'add_transaction',
      'edit_transaction',
      'archive_transaction',
      'send_reminders',
      'create_invoice',
      'manage_inventory',
      'export_reports',
      'manage_staff',
      'view_dashboard_totals',
      'manage_settings'
    ],
    new.owner_id,
    new.owner_id
  )
  on conflict (business_id, user_id) do update
    set role = 'owner',
        permissions = excluded.permissions,
        updated_at = now(),
        deleted_at = null;
  return new;
end;
$$;

create or replace function ledger_private.prevent_hard_delete()
returns trigger
language plpgsql
as $$
begin
  raise exception 'Hard delete is disabled for %. Use deleted_at, archive, or reversal entries.', tg_table_name;
end;
$$;

create or replace function ledger_private.write_audit_log()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  before_row jsonb;
  after_row jsonb;
  row_business_id uuid;
  row_book_id uuid;
  row_entity_id uuid;
begin
  before_row := case when tg_op in ('UPDATE', 'DELETE') then to_jsonb(old) else null end;
  after_row := case when tg_op in ('INSERT', 'UPDATE') then to_jsonb(new) else null end;
  if tg_table_name = 'businesses' then
    row_business_id := coalesce((after_row ->> 'id')::uuid, (before_row ->> 'id')::uuid);
  else
    row_business_id := coalesce((after_row ->> 'business_id')::uuid, (before_row ->> 'business_id')::uuid);
  end if;
  row_book_id := nullif(coalesce(after_row ->> 'book_id', before_row ->> 'book_id'), '')::uuid;
  row_entity_id := coalesce((after_row ->> 'id')::uuid, (before_row ->> 'id')::uuid);

  if row_business_id is not null and tg_table_name <> 'audit_logs' then
    insert into public.audit_logs (
      business_id,
      book_id,
      actor_id,
      entity_table,
      entity_id,
      action,
      before_data,
      after_data,
      ip_address,
      user_agent
    )
    values (
      row_business_id,
      row_book_id,
      auth.uid(),
      tg_table_name,
      row_entity_id,
      lower(tg_op),
      before_row,
      after_row,
      nullif(
        split_part(coalesce(current_setting('request.headers', true)::jsonb ->> 'x-forwarded-for', ''), ',', 1),
        ''
      )::inet,
      current_setting('request.headers', true)::jsonb ->> 'user-agent'
    );
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'profiles',
    'businesses',
    'business_members',
    'books',
    'parties',
    'party_tags',
    'transactions',
    'transaction_attachments',
    'reminders',
    'reminder_templates',
    'payments',
    'invoices',
    'invoice_items',
    'products',
    'product_categories',
    'stock_movements',
    'business_cards',
    'app_settings',
    'export_jobs',
    'sync_queue_metadata',
    'share_links'
  ]
  loop
    execute format('drop trigger if exists set_updated_at on public.%I', table_name);
    execute format('create trigger set_updated_at before update on public.%I for each row execute function ledger_private.set_updated_at()', table_name);
  end loop;
end $$;

drop trigger if exists set_party_search_vector on public.parties;
create trigger set_party_search_vector
before insert or update on public.parties
for each row execute function ledger_private.set_party_search_vector();

drop trigger if exists add_owner_membership on public.businesses;
create trigger add_owner_membership
after insert on public.businesses
for each row execute function ledger_private.add_owner_membership();

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'businesses',
    'business_members',
    'books',
    'parties',
    'party_tags',
    'transactions',
    'transaction_attachments',
    'reminders',
    'payments',
    'invoices',
    'invoice_items',
    'products',
    'product_categories',
    'stock_movements',
    'business_cards',
    'app_settings',
    'export_jobs',
    'sync_queue_metadata',
    'share_links'
  ]
  loop
    execute format('drop trigger if exists audit_changes on public.%I', table_name);
    execute format('create trigger audit_changes after insert or update or delete on public.%I for each row execute function ledger_private.write_audit_log()', table_name);
  end loop;
end $$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'transactions',
    'transaction_attachments',
    'payments',
    'invoices',
    'invoice_items',
    'stock_movements',
    'audit_logs'
  ]
  loop
    execute format('drop trigger if exists prevent_hard_delete on public.%I', table_name);
    execute format('create trigger prevent_hard_delete before delete on public.%I for each row execute function ledger_private.prevent_hard_delete()', table_name);
  end loop;
end $$;

alter table public.profiles enable row level security;
alter table public.businesses enable row level security;
alter table public.business_members enable row level security;
alter table public.books enable row level security;
alter table public.parties enable row level security;
alter table public.party_tags enable row level security;
alter table public.transactions enable row level security;
alter table public.transaction_attachments enable row level security;
alter table public.reminders enable row level security;
alter table public.reminder_templates enable row level security;
alter table public.payments enable row level security;
alter table public.invoices enable row level security;
alter table public.invoice_items enable row level security;
alter table public.products enable row level security;
alter table public.product_categories enable row level security;
alter table public.stock_movements enable row level security;
alter table public.business_cards enable row level security;
alter table public.audit_logs enable row level security;
alter table public.app_settings enable row level security;
alter table public.export_jobs enable row level security;
alter table public.sync_queue_metadata enable row level security;
alter table public.share_links enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles for select to authenticated
using (id = (select auth.uid()));

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles for insert to authenticated
with check (id = (select auth.uid()));

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles for update to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()));

drop policy if exists "businesses_select_members" on public.businesses;
create policy "businesses_select_members"
on public.businesses for select to authenticated
using (ledger_private.can_access_business(id));

drop policy if exists "businesses_insert_owner" on public.businesses;
create policy "businesses_insert_owner"
on public.businesses for insert to authenticated
with check (owner_id = (select auth.uid()) and created_by = (select auth.uid()));

drop policy if exists "businesses_update_owner_settings" on public.businesses;
create policy "businesses_update_owner_settings"
on public.businesses for update to authenticated
using (ledger_private.has_permission(id, 'manage_settings'))
with check (ledger_private.has_permission(id, 'manage_settings'));

drop policy if exists "business_members_select_members" on public.business_members;
create policy "business_members_select_members"
on public.business_members for select to authenticated
using (ledger_private.can_access_business(business_id));

drop policy if exists "business_members_manage_staff" on public.business_members;
create policy "business_members_manage_staff"
on public.business_members for all to authenticated
using (ledger_private.has_permission(business_id, 'manage_staff'))
with check (ledger_private.has_permission(business_id, 'manage_staff'));

drop policy if exists "books_select_members" on public.books;
create policy "books_select_members"
on public.books for select to authenticated
using (ledger_private.can_access_business(business_id));

drop policy if exists "books_manage_settings" on public.books;
create policy "books_manage_settings"
on public.books for insert to authenticated
with check (ledger_private.has_permission(business_id, 'manage_settings'));

drop policy if exists "books_update_settings" on public.books;
create policy "books_update_settings"
on public.books for update to authenticated
using (ledger_private.has_permission(business_id, 'manage_settings'))
with check (ledger_private.has_permission(business_id, 'manage_settings'));

drop policy if exists "parties_select_members" on public.parties;
create policy "parties_select_members"
on public.parties for select to authenticated
using (ledger_private.has_permission(business_id, 'view_parties'));

drop policy if exists "parties_insert_members" on public.parties;
create policy "parties_insert_members"
on public.parties for insert to authenticated
with check (ledger_private.has_permission(business_id, 'view_parties'));

drop policy if exists "parties_update_members" on public.parties;
create policy "parties_update_members"
on public.parties for update to authenticated
using (ledger_private.has_permission(business_id, 'view_parties'))
with check (ledger_private.has_permission(business_id, 'view_parties'));

drop policy if exists "party_tags_member_access" on public.party_tags;
create policy "party_tags_member_access"
on public.party_tags for all to authenticated
using (ledger_private.has_permission(business_id, 'view_parties'))
with check (ledger_private.has_permission(business_id, 'view_parties'));

drop policy if exists "transactions_select_members" on public.transactions;
create policy "transactions_select_members"
on public.transactions for select to authenticated
using (ledger_private.can_access_business(business_id));

drop policy if exists "transactions_insert_add_permission" on public.transactions;
create policy "transactions_insert_add_permission"
on public.transactions for insert to authenticated
with check (ledger_private.has_permission(business_id, 'add_transaction'));

drop policy if exists "transactions_update_edit_permission" on public.transactions;
create policy "transactions_update_edit_permission"
on public.transactions for update to authenticated
using (ledger_private.has_permission(business_id, 'edit_transaction'))
with check (ledger_private.has_permission(business_id, 'edit_transaction'));

drop policy if exists "transaction_attachments_member_access" on public.transaction_attachments;
create policy "transaction_attachments_member_access"
on public.transaction_attachments for all to authenticated
using (ledger_private.can_access_business(business_id))
with check (ledger_private.can_access_business(business_id));

drop policy if exists "reminders_select_members" on public.reminders;
create policy "reminders_select_members"
on public.reminders for select to authenticated
using (ledger_private.can_access_business(business_id));

drop policy if exists "reminders_send_permission" on public.reminders;
create policy "reminders_send_permission"
on public.reminders for insert to authenticated
with check (ledger_private.has_permission(business_id, 'send_reminders'));

drop policy if exists "reminders_update_permission" on public.reminders;
create policy "reminders_update_permission"
on public.reminders for update to authenticated
using (ledger_private.has_permission(business_id, 'send_reminders'))
with check (ledger_private.has_permission(business_id, 'send_reminders'));

drop policy if exists "reminder_templates_select_members" on public.reminder_templates;
create policy "reminder_templates_select_members"
on public.reminder_templates for select to authenticated
using (business_id is null or ledger_private.can_access_business(business_id));

drop policy if exists "reminder_templates_manage_settings" on public.reminder_templates;
create policy "reminder_templates_manage_settings"
on public.reminder_templates for insert to authenticated
with check (business_id is not null and ledger_private.has_permission(business_id, 'manage_settings'));

drop policy if exists "reminder_templates_update_settings" on public.reminder_templates;
create policy "reminder_templates_update_settings"
on public.reminder_templates for update to authenticated
using (business_id is not null and ledger_private.has_permission(business_id, 'manage_settings'))
with check (business_id is not null and ledger_private.has_permission(business_id, 'manage_settings'));

drop policy if exists "payments_select_members" on public.payments;
create policy "payments_select_members"
on public.payments for select to authenticated
using (ledger_private.can_access_business(business_id));

drop policy if exists "payments_write_transactions" on public.payments;
create policy "payments_write_transactions"
on public.payments for insert to authenticated
with check (ledger_private.has_permission(business_id, 'add_transaction'));

drop policy if exists "payments_update_transactions" on public.payments;
create policy "payments_update_transactions"
on public.payments for update to authenticated
using (ledger_private.has_permission(business_id, 'edit_transaction'))
with check (ledger_private.has_permission(business_id, 'edit_transaction'));

drop policy if exists "invoices_select_members" on public.invoices;
create policy "invoices_select_members"
on public.invoices for select to authenticated
using (ledger_private.can_access_business(business_id));

drop policy if exists "invoices_create_permission" on public.invoices;
create policy "invoices_create_permission"
on public.invoices for insert to authenticated
with check (ledger_private.has_permission(business_id, 'create_invoice'));

drop policy if exists "invoices_update_permission" on public.invoices;
create policy "invoices_update_permission"
on public.invoices for update to authenticated
using (ledger_private.has_permission(business_id, 'create_invoice'))
with check (ledger_private.has_permission(business_id, 'create_invoice'));

drop policy if exists "invoice_items_invoice_permission" on public.invoice_items;
create policy "invoice_items_invoice_permission"
on public.invoice_items for all to authenticated
using (ledger_private.has_permission(business_id, 'create_invoice'))
with check (ledger_private.has_permission(business_id, 'create_invoice'));

drop policy if exists "products_member_inventory" on public.products;
create policy "products_member_inventory"
on public.products for all to authenticated
using (ledger_private.has_permission(business_id, 'manage_inventory'))
with check (ledger_private.has_permission(business_id, 'manage_inventory'));

drop policy if exists "product_categories_member_inventory" on public.product_categories;
create policy "product_categories_member_inventory"
on public.product_categories for all to authenticated
using (ledger_private.has_permission(business_id, 'manage_inventory'))
with check (ledger_private.has_permission(business_id, 'manage_inventory'));

drop policy if exists "stock_movements_member_inventory" on public.stock_movements;
create policy "stock_movements_member_inventory"
on public.stock_movements for all to authenticated
using (ledger_private.has_permission(business_id, 'manage_inventory'))
with check (ledger_private.has_permission(business_id, 'manage_inventory'));

drop policy if exists "business_cards_member_settings" on public.business_cards;
create policy "business_cards_member_settings"
on public.business_cards for all to authenticated
using (ledger_private.can_access_business(business_id))
with check (ledger_private.has_permission(business_id, 'manage_settings'));

drop policy if exists "audit_logs_owner_select" on public.audit_logs;
create policy "audit_logs_owner_select"
on public.audit_logs for select to authenticated
using (ledger_private.has_permission(business_id, 'manage_settings'));

drop policy if exists "app_settings_member_settings" on public.app_settings;
create policy "app_settings_member_settings"
on public.app_settings for all to authenticated
using (ledger_private.has_permission(business_id, 'manage_settings'))
with check (ledger_private.has_permission(business_id, 'manage_settings'));

drop policy if exists "export_jobs_member_export" on public.export_jobs;
create policy "export_jobs_member_export"
on public.export_jobs for all to authenticated
using (ledger_private.has_permission(business_id, 'export_reports'))
with check (ledger_private.has_permission(business_id, 'export_reports'));

drop policy if exists "sync_queue_metadata_member_access" on public.sync_queue_metadata;
create policy "sync_queue_metadata_member_access"
on public.sync_queue_metadata for all to authenticated
using (ledger_private.can_access_business(business_id))
with check (ledger_private.can_access_business(business_id));

drop policy if exists "share_links_member_export" on public.share_links;
create policy "share_links_member_export"
on public.share_links for all to authenticated
using (ledger_private.has_permission(business_id, 'export_reports'))
with check (ledger_private.has_permission(business_id, 'export_reports'));

grant usage on schema public to authenticated;
grant select, insert, update on
  public.profiles,
  public.businesses,
  public.business_members,
  public.books,
  public.parties,
  public.party_tags,
  public.transactions,
  public.transaction_attachments,
  public.reminders,
  public.reminder_templates,
  public.payments,
  public.invoices,
  public.invoice_items,
  public.products,
  public.product_categories,
  public.stock_movements,
  public.business_cards,
  public.app_settings,
  public.export_jobs,
  public.sync_queue_metadata,
  public.share_links
to authenticated;

grant select on public.audit_logs to authenticated;
grant usage on schema ledger_private to authenticated;
grant execute on function ledger_private.can_access_business(uuid) to authenticated;
grant execute on function ledger_private.has_permission(uuid, text) to authenticated;

insert into public.reminder_templates (name, language_code, body, tone, is_system)
values
  ('Polite English', 'en', 'Hello {{name}}, {{amount}} is pending. Please make the payment when convenient. - {{business_name}}', 'polite', true),
  ('Polite Hindi', 'hi', 'Namaste {{name}}, {{amount}} pending hai. Kripya payment kar dein. - {{business_name}}', 'polite', true),
  ('Hinglish', 'hi-IN', 'Hi {{name}}, aapka {{amount}} balance pending hai. Payment update kar dein. - {{business_name}}', 'polite', true),
  ('Firm reminder', 'en', 'Reminder: {{amount}} is overdue. Please clear this payment today. - {{business_name}}', 'firm', true),
  ('Final reminder', 'en', 'Final reminder: {{amount}} remains overdue. Please clear the payment immediately. - {{business_name}}', 'final', true)
on conflict do nothing;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'ledger-attachments',
  'ledger-attachments',
  false,
  10485760,
  array['image/jpeg', 'image/png', 'application/pdf']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "ledger_attachments_select_members" on storage.objects;
create policy "ledger_attachments_select_members"
on storage.objects for select to authenticated
using (
  bucket_id = 'ledger-attachments'
  and ledger_private.can_access_business(((storage.foldername(name))[1])::uuid)
);

drop policy if exists "ledger_attachments_insert_members" on storage.objects;
create policy "ledger_attachments_insert_members"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'ledger-attachments'
  and ledger_private.can_access_business(((storage.foldername(name))[1])::uuid)
);

drop policy if exists "ledger_attachments_update_members" on storage.objects;
create policy "ledger_attachments_update_members"
on storage.objects for update to authenticated
using (
  bucket_id = 'ledger-attachments'
  and ledger_private.can_access_business(((storage.foldername(name))[1])::uuid)
)
with check (
  bucket_id = 'ledger-attachments'
  and ledger_private.can_access_business(((storage.foldername(name))[1])::uuid)
);

drop policy if exists "authenticated_users_can_receive_ledger_broadcasts" on realtime.messages;
create policy "authenticated_users_can_receive_ledger_broadcasts"
on realtime.messages for select to authenticated
using (true);

do $$
declare
  table_name text;
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    foreach table_name in array array['parties', 'transactions', 'reminders', 'payments', 'invoices']
    loop
      begin
        execute format('alter publication supabase_realtime add table public.%I', table_name);
      exception when duplicate_object then
        null;
      end;
    end loop;
  end if;
end $$;
