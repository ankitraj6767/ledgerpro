-- Add covering indexes for foreign keys and hot filters.
-- These help as data grows to 1000+ parties / 100k+ transactions.

create index if not exists books_created_by_idx on public.books(created_by) where deleted_at is null;
create index if not exists books_updated_by_idx on public.books(updated_by) where deleted_at is null;

create index if not exists business_members_business_id_idx on public.business_members(business_id) where deleted_at is null;
create index if not exists business_members_user_id_idx on public.business_members(user_id) where deleted_at is null;
create index if not exists business_members_invited_by_idx on public.business_members(invited_by) where deleted_at is null;
create index if not exists business_members_created_by_idx on public.business_members(created_by) where deleted_at is null;
create index if not exists business_members_updated_by_idx on public.business_members(updated_by) where deleted_at is null;

create index if not exists business_cards_business_id_idx on public.business_cards(business_id) where deleted_at is null;
create index if not exists business_cards_created_by_idx on public.business_cards(created_by) where deleted_at is null;
create index if not exists business_cards_updated_by_idx on public.business_cards(updated_by) where deleted_at is null;

create index if not exists parties_business_id_idx on public.parties(business_id) where deleted_at is null;
create index if not exists parties_book_id_idx on public.parties(book_id) where deleted_at is null;
create index if not exists parties_created_by_idx on public.parties(created_by) where deleted_at is null;
create index if not exists parties_updated_by_idx on public.parties(updated_by) where deleted_at is null;

create index if not exists transactions_business_id_idx on public.transactions(business_id) where deleted_at is null;
create index if not exists transactions_book_id_idx on public.transactions(book_id) where deleted_at is null;
create index if not exists transactions_created_by_idx on public.transactions(created_by) where deleted_at is null;
create index if not exists transactions_updated_by_idx on public.transactions(updated_by) where deleted_at is null;

create index if not exists invoices_book_id_idx on public.invoices(book_id) where deleted_at is null;
create index if not exists invoices_party_id_idx on public.invoices(party_id) where deleted_at is null;
create index if not exists invoices_created_by_idx on public.invoices(created_by) where deleted_at is null;
create index if not exists invoices_updated_by_idx on public.invoices(updated_by) where deleted_at is null;

create index if not exists invoice_items_invoice_id_idx on public.invoice_items(invoice_id) where deleted_at is null;
create index if not exists invoice_items_business_id_idx on public.invoice_items(business_id) where deleted_at is null;

create index if not exists payments_business_id_idx on public.payments(business_id) where deleted_at is null;
create index if not exists payments_book_id_idx on public.payments(book_id) where deleted_at is null;
create index if not exists payments_transaction_id_idx on public.payments(transaction_id) where deleted_at is null;

create index if not exists products_category_id_idx on public.products(category_id) where deleted_at is null;
create index if not exists products_supplier_party_id_idx on public.products(supplier_party_id) where deleted_at is null;
create index if not exists products_created_by_idx on public.products(created_by) where deleted_at is null;
create index if not exists products_updated_by_idx on public.products(updated_by) where deleted_at is null;

create index if not exists stock_movements_business_id_idx on public.stock_movements(business_id) where deleted_at is null;
create index if not exists stock_movements_book_id_idx on public.stock_movements(book_id) where deleted_at is null;
create index if not exists stock_movements_party_id_idx on public.stock_movements(party_id) where deleted_at is null;
create index if not exists stock_movements_reference_transaction_id_idx on public.stock_movements(reference_transaction_id) where deleted_at is null;
create index if not exists stock_movements_reference_invoice_id_idx on public.stock_movements(reference_invoice_id) where deleted_at is null;

create index if not exists reminders_party_id_idx on public.reminders(party_id) where deleted_at is null;
create index if not exists reminders_transaction_id_idx on public.reminders(transaction_id) where deleted_at is null;

create index if not exists transaction_attachments_transaction_id_idx on public.transaction_attachments(transaction_id) where deleted_at is null;
