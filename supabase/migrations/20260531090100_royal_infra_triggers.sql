-- =============================================================================
-- Royal Infra — triggers: updated_at, search vector, hard-delete guards
-- =============================================================================

-- Project search vector maintenance.
create or replace function ledger_private.set_infra_project_search_vector()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  new.search_vector :=
    to_tsvector(
      'simple',
      coalesce(new.name, '') || ' ' ||
      coalesce(new.code, '') || ' ' ||
      coalesce(new.category, '') || ' ' ||
      coalesce(new.location_city, '') || ' ' ||
      coalesce(new.location_state, '')
    );
  return new;
end;
$$;

drop trigger if exists set_infra_project_search_vector on public.infra_projects;
create trigger set_infra_project_search_vector
before insert or update on public.infra_projects
for each row execute function ledger_private.set_infra_project_search_vector();

-- updated_at maintenance for all mutable infra tables.
do $$
declare
  t text;
  tables text[] := array[
    'organizations',
    'organization_members',
    'infra_projects',
    'investors',
    'project_investments',
    'government_funds',
    'government_fund_receipts',
    'project_expenses',
    'project_notes'
  ];
begin
  foreach t in array tables loop
    execute format('drop trigger if exists set_updated_at on public.%I', t);
    execute format(
      'create trigger set_updated_at before update on public.%I for each row execute function ledger_private.set_updated_at()',
      t
    );
  end loop;
end $$;

-- Block hard deletes on financial tables (soft-delete only).
do $$
declare
  t text;
  tables text[] := array[
    'infra_projects',
    'project_investments',
    'government_funds',
    'government_fund_receipts',
    'project_expenses'
  ];
begin
  foreach t in array tables loop
    execute format('drop trigger if exists prevent_hard_delete on public.%I', t);
    execute format(
      'create trigger prevent_hard_delete before delete on public.%I for each row execute function ledger_private.prevent_hard_delete()',
      t
    );
  end loop;
end $$;
