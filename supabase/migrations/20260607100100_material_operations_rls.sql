-- Material operations RLS. Security-definer RPCs remain the only stock writers.

do $$
declare
  table_name text;
  tables text[] := array[
    'tenders', 'districts', 'warehouses', 'site_managers', 'schools',
    'material_items', 'warehouse_stock', 'school_material_requirements',
    'material_receipts', 'material_issues', 'material_returns',
    'material_audit_logs'
  ];
begin
  foreach table_name in array tables loop
    execute format('alter table public.%I enable row level security', table_name);
  end loop;
end $$;

do $$
declare
  table_name text;
  master_tables text[] := array[
    'tenders', 'districts', 'warehouses', 'site_managers', 'schools'
  ];
  read_only_tables text[] := array[
    'material_items', 'warehouse_stock', 'school_material_requirements',
    'material_receipts', 'material_issues', 'material_returns'
  ];
begin
  foreach table_name in array master_tables loop
    execute format('drop policy if exists %I on public.%I', table_name || '_select', table_name);
    execute format(
      'create policy %I on public.%I for select to authenticated using (ledger_private.is_org_member(organization_id))',
      table_name || '_select',
      table_name
    );
    execute format('drop policy if exists %I on public.%I', table_name || '_manage', table_name);
    execute format(
      'create policy %I on public.%I for all to authenticated using (ledger_private.org_has_role(organization_id, array[''owner'',''manager'',''accountant'']::public.org_member_role[])) with check (ledger_private.org_has_role(organization_id, array[''owner'',''manager'',''accountant'']::public.org_member_role[]))',
      table_name || '_manage',
      table_name
    );
  end loop;

  foreach table_name in array read_only_tables loop
    execute format('drop policy if exists %I on public.%I', table_name || '_manage', table_name);
    execute format('drop policy if exists %I on public.%I', table_name || '_select', table_name);
    execute format(
      'create policy %I on public.%I for select to authenticated using (ledger_private.is_org_member(organization_id))',
      table_name || '_select',
      table_name
    );
  end loop;
end $$;

drop policy if exists "material_audit_logs_select" on public.material_audit_logs;
create policy "material_audit_logs_select" on public.material_audit_logs
  for select to authenticated
  using (
    ledger_private.org_has_role(
      organization_id,
      array['owner','manager']::public.org_member_role[]
    )
  );
