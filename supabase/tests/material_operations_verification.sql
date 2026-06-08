-- Structural contract for the material module. Safe to run against linked DB.

begin;

set local role postgres;
set local search_path = extensions, public, pg_catalog;

select extensions.plan(60);

select extensions.has_table('public', value, 'material table exists: ' || value)
from unnest(array[
  'tenders', 'districts', 'warehouses', 'schools', 'site_managers',
  'material_items', 'warehouse_stock', 'school_material_requirements',
  'material_receipts', 'material_issues', 'material_returns',
  'material_audit_logs'
]) value;

select extensions.has_column(
  'public',
  'schools',
  value,
  'schools evidence column exists: ' || value
)
from unnest(array[
  'room_quantity',
  'gps_photo_paths',
  'gps_latitude',
  'gps_longitude',
  'gps_accuracy_meters',
  'gps_captured_at'
]) value;

select extensions.has_function('public', value, 'material RPC exists: ' || value)
from unnest(array[
  'material_dashboard_summary', 'warehouse_stock_summary',
  'school_requirement_vs_issue', 'recent_material_issues',
  'low_stock_alerts', 'manager_material_issue_summary',
  'create_material_item', 'set_school_material_requirement',
  'create_material_tender', 'create_material_district',
  'create_material_manager', 'create_material_warehouse',
  'create_material_school', 'update_material_school_progress',
  'add_material_school_evidence',
  'update_material_tender', 'delete_material_tender',
  'update_material_district', 'delete_material_district',
  'update_material_manager', 'delete_material_manager',
  'update_material_warehouse', 'delete_material_warehouse',
  'update_material_school', 'delete_material_school',
  'update_material_item', 'delete_material_item',
  'receive_material', 'issue_material_to_school',
  'return_material_from_school'
]) value;

select extensions.ok(
  (
    select c.relrowsecurity
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relname = value
  ),
  'RLS enabled: ' || value
)
from unnest(array[
  'tenders', 'districts', 'warehouses', 'schools', 'site_managers',
  'material_items', 'warehouse_stock', 'school_material_requirements',
  'material_receipts', 'material_issues', 'material_returns',
  'material_audit_logs'
]) value;

select * from extensions.finish();

rollback;
