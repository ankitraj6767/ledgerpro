import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/constants/supabase_config.dart';
import '../../core/sync/queued_mutation_remote.dart';

final supabaseLedgerApiProvider = Provider<SupabaseLedgerApi?>((ref) {
  if (!SupabaseConfig.isConfigured) return null;
  try {
    return SupabaseLedgerApi(Supabase.instance.client);
  } catch (_) {
    return null;
  }
});

class SupabaseLedgerApi implements QueuedMutationRemote {
  const SupabaseLedgerApi(this._client);

  final SupabaseClient _client;

  static const infraRealtimeTables = <String>[
    'organizations',
    'organization_members',
    'infra_projects',
    'investors',
    'project_investments',
    'government_funds',
    'government_fund_receipts',
    'project_expenses',
    'project_notes',
    'project_progress_updates',
    'project_documents',
    'customer_project_assignments',
    'project_audit_logs',
    'tenders',
    'districts',
    'warehouses',
    'schools',
    'site_managers',
    'material_items',
    'warehouse_stock',
    'school_material_requirements',
    'material_receipts',
    'material_issues',
    'material_returns',
    'material_audit_logs',
  ];

  static const _tableByEntity = <String, String>{
    'business': 'businesses',
    'book': 'books',
    'party': 'parties',
    'transaction': 'transactions',
    'reminder': 'reminders',
    'infraProject': 'infra_projects',
    'infra_project': 'infra_projects',
    'organization': 'organizations',
    'organizationMember': 'organization_members',
    'organization_member': 'organization_members',
    'investor': 'investors',
    'projectInvestment': 'project_investments',
    'project_investment': 'project_investments',
    'governmentFund': 'government_funds',
    'government_fund': 'government_funds',
    'governmentFundReceipt': 'government_fund_receipts',
    'government_fund_receipt': 'government_fund_receipts',
    'projectExpense': 'project_expenses',
    'project_expense': 'project_expenses',
    'projectNote': 'project_notes',
    'project_note': 'project_notes',
    'projectDocument': 'project_documents',
    'project_document': 'project_documents',
    'customerProjectAssignment': 'customer_project_assignments',
    'customer_project_assignment': 'customer_project_assignments',
    'projectProgressUpdate': 'project_progress_updates',
    'project_progress_update': 'project_progress_updates',
    'tender': 'tenders',
    'district': 'districts',
    'warehouse': 'warehouses',
    'school': 'schools',
    'siteManager': 'site_managers',
    'site_manager': 'site_managers',
    'materialItem': 'material_items',
    'material_item': 'material_items',
    'warehouseStock': 'warehouse_stock',
    'warehouse_stock': 'warehouse_stock',
    'schoolMaterialRequirement': 'school_material_requirements',
    'school_material_requirement': 'school_material_requirements',
    'materialReceipt': 'material_receipts',
    'material_receipt': 'material_receipts',
    'materialIssue': 'material_issues',
    'material_issue': 'material_issues',
    'materialReturn': 'material_returns',
    'material_return': 'material_returns',
  };

  static const _allowedQueuedRpcs = <String>{
    'ensure_infra_workspace',
    'create_project',
    'add_project_investment',
    'update_project_investment',
    'delete_project_investment',
    'add_government_fund',
    'update_government_fund',
    'delete_government_fund',
    'add_government_fund_receipt',
    'delete_government_receipt',
    'add_project_expense',
    'update_project_expense',
    'delete_project_expense',
    'update_project_progress',
    'delete_project',
    'set_customer_project_assignments',
    'receive_material',
    'issue_material_to_school',
    'return_material_from_school',
    'create_material_item',
    'set_school_material_requirement',
    'create_material_tender',
    'create_material_district',
    'create_material_manager',
    'create_material_warehouse',
    'create_material_school',
    'update_material_school_progress',
  };

  Future<void> upsertParty(Map<String, dynamic> party) async {
    await _client.from('parties').upsert(party);
  }

  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    await _client.from('transactions').insert(transaction);
  }

  Future<void> upsertReminder(Map<String, dynamic> reminder) async {
    await _client.from('reminders').upsert(reminder);
  }

  @override
  Future<void> applyQueuedMutation(QueuedMutationRequest mutation) async {
    final table =
        _tableByEntity[mutation.entityType] ??
        mutation.payload['_entity_table']?.toString();
    try {
      await _recordReplayState(mutation, table: table, status: 'in_flight');
      final rpc = mutation.payload['_rpc']?.toString();
      if (rpc != null && rpc.isNotEmpty) {
        await _applyWhitelistedRpc(rpc, mutation.payload['params']);
        await _recordReplayState(mutation, table: table, status: 'synced');
        return;
      }

      if (table == null) {
        throw UnsupportedError(
          'Unsupported queued mutation entity: ${mutation.entityType}',
        );
      }

      final payload = _cleanPayload(mutation.payload);
      final action = mutation.action.toLowerCase();
      switch (action) {
        case 'create':
        case 'update':
        case 'upsert':
          await _assertNoConflict(table: table, payload: mutation.payload);
          await _client.from(table).upsert(payload);
          await _recordReplayState(mutation, table: table, status: 'synced');
          return;
        case 'archive':
        case 'delete':
          await _archive(table: table, mutation: mutation, payload: payload);
          await _recordReplayState(mutation, table: table, status: 'synced');
          return;
        default:
          throw UnsupportedError(
            'Unsupported queued mutation action: ${mutation.action}',
          );
      }
    } catch (error) {
      await _recordReplayState(
        mutation,
        table: table,
        status: error is SyncConflictException ? 'conflict' : 'failed',
        errorMessage: '$error',
      );
      rethrow;
    }
  }

  RealtimeChannel subscribeToBook({
    required String businessId,
    required String bookId,
    required void Function(PostgresChangePayload payload) onChange,
  }) {
    return _client
        .channel('ledger:$businessId:$bookId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transactions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'book_id',
            value: bookId,
          ),
          callback: onChange,
        )
        .subscribe();
  }

  RealtimeChannel subscribeToInfraWorkspace({
    required String organizationId,
    required void Function(PostgresChangePayload payload) onChange,
  }) {
    var channel = _client.channel('infra:$organizationId');
    for (final table in infraRealtimeTables) {
      final filterColumn = table == 'organizations' ? 'id' : 'organization_id';
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: filterColumn,
          value: organizationId,
        ),
        callback: onChange,
      );
    }
    return channel.subscribe();
  }

  Future<void> unsubscribe(RealtimeChannel channel) {
    return _client.removeChannel(channel);
  }

  Future<void> _applyWhitelistedRpc(String rpc, Object? rawParams) async {
    if (!_allowedQueuedRpcs.contains(rpc)) {
      throw UnsupportedError('Queued RPC is not allowed: $rpc');
    }
    final params = rawParams is Map
        ? Map<String, dynamic>.from(rawParams)
        : const <String, dynamic>{};
    await _client.rpc(rpc, params: params);
  }

  Map<String, dynamic> _cleanPayload(Map<String, dynamic> payload) {
    return Map<String, dynamic>.from(payload)
      ..remove('_rpc')
      ..remove('params')
      ..remove('expected_updated_at')
      ..remove('expectedUpdatedAt');
  }

  Future<void> _assertNoConflict({
    required String table,
    required Map<String, dynamic> payload,
  }) async {
    final expected =
        payload['expected_updated_at']?.toString() ??
        payload['expectedUpdatedAt']?.toString();
    final id = payload['id']?.toString();
    if (expected == null || expected.isEmpty || id == null || id.isEmpty) {
      return;
    }
    final current = await _client
        .from(table)
        .select('updated_at, deleted_at')
        .eq('id', id)
        .maybeSingle();
    if (current == null) return;
    if (current['deleted_at'] != null) {
      throw SyncConflictException('$table/$id was deleted on the server.');
    }
    final serverUpdatedAt = current['updated_at']?.toString();
    if (serverUpdatedAt != expected) {
      throw SyncConflictException(
        '$table/$id changed on the server before this device synced.',
      );
    }
  }

  Future<void> _archive({
    required String table,
    required QueuedMutationRequest mutation,
    required Map<String, dynamic> payload,
  }) async {
    final payloadId = payload['id']?.toString();
    final id = payloadId != null && payloadId.isNotEmpty
        ? payloadId
        : mutation.entityId;
    if (id.isEmpty) {
      throw const FormatException('Archive mutation requires an entity id.');
    }
    await _client
        .from(table)
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }

  Future<void> _recordReplayState(
    QueuedMutationRequest mutation, {
    required String? table,
    required String status,
    String? errorMessage,
  }) async {
    final organizationId = mutation.payload['organization_id']?.toString();
    final deviceId = mutation.payload['device_id']?.toString();
    final entityId = mutation.payload['id']?.toString() ?? mutation.entityId;
    if (!_looksLikeUuid(organizationId) ||
        deviceId == null ||
        deviceId.isEmpty ||
        table == null ||
        table.isEmpty) {
      return;
    }

    try {
      await _client.rpc(
        'record_infra_sync_mutation',
        params: {
          'p_organization_id': organizationId,
          'p_mutation_id': mutation.id,
          'p_device_id': deviceId,
          'p_entity_table': table,
          'p_entity_id': _looksLikeUuid(entityId) ? entityId : null,
          'p_status': status,
          'p_payload_hash': mutation.payload['payload_hash']?.toString(),
          'p_error_message': errorMessage,
        },
      );
    } catch (_) {
      // Older deployments may not have the replay metadata RPC yet. The
      // mutation itself still uses RLS/RPCs as the authority.
    }
  }

  bool _looksLikeUuid(String? value) {
    if (value == null) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }
}
