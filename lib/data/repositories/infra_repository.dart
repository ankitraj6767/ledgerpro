import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/cache/dashboard_cache.dart';
import '../../core/money/money.dart';
import '../../shared/models/infra_models.dart';

final infraRepositoryProvider = Provider<InfraRepository>((ref) {
  return InfraRepository(Supabase.instance.client);
});

/// Active organization membership fetched without creating a new workspace.
final infraWorkspaceProvider = FutureProvider<InfraWorkspaceSession>((
  ref,
) async {
  return ref.watch(infraRepositoryProvider).getMyWorkspace();
});

final currentOrgRoleProvider = FutureProvider<OrgMemberRole>((ref) async {
  final workspace = await ref.watch(infraWorkspaceProvider.future);
  return workspace.role;
});

final currentOrgPermissionsProvider = Provider<OrgPermissions>((ref) {
  final role = ref.watch(currentOrgRoleProvider).value;
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;
  return OrgPermissions(role, currentUserId: currentUserId);
});

/// Full organization profile (name, owner, phone, address) for the active org.
/// The workspace provider only returns id+name from the bootstrap RPC, so
/// screens that show/edit the full profile must use this instead.
final organizationProfileProvider = FutureProvider<Organization>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref.watch(infraRepositoryProvider).fetchOrganization(org.id);
});

final dashboardSummaryProvider = FutureProvider<InfraDashboardSummary>((
  ref,
) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref.watch(infraRepositoryProvider).dashboardSummary(org.id);
});

final projectsProvider = FutureProvider<List<InfraProject>>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref.watch(infraRepositoryProvider).fetchProjects(org.id);
});

final projectByIdProvider = Provider.family<InfraProject?, String>((
  ref,
  projectId,
) {
  final projects = ref.watch(projectsProvider).value ?? const <InfraProject>[];
  for (final p in projects) {
    if (p.id == projectId) return p;
  }
  return null;
});

final projectFinancialSummaryProvider =
    FutureProvider.family<ProjectFinancialSummary, String>((ref, projectId) {
      return ref
          .watch(infraRepositoryProvider)
          .projectFinancialSummary(projectId);
    });

final investorsProvider = FutureProvider<List<Investor>>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref.watch(infraRepositoryProvider).fetchInvestors(org.id);
});

final projectInvestorsProvider = FutureProvider.family<List<Investor>, String>((
  ref,
  projectId,
) {
  return ref.watch(infraRepositoryProvider).fetchProjectInvestors(projectId);
});

final projectInvestmentsProvider =
    FutureProvider.family<List<ProjectInvestment>, String>((ref, projectId) {
      return ref.watch(infraRepositoryProvider).fetchInvestments(projectId);
    });

final governmentFundsProvider =
    FutureProvider.family<List<GovernmentFund>, String>((ref, projectId) {
      return ref.watch(infraRepositoryProvider).fetchGovernmentFunds(projectId);
    });

final fundReceiptsProvider =
    FutureProvider.family<List<GovernmentFundReceipt>, String>((ref, fundId) {
      return ref.watch(infraRepositoryProvider).fetchReceipts(fundId);
    });

final projectExpensesProvider =
    FutureProvider.family<List<ProjectExpense>, String>((ref, projectId) {
      return ref.watch(infraRepositoryProvider).fetchExpenses(projectId);
    });

final projectNotesProvider = FutureProvider.family<List<ProjectNote>, String>((
  ref,
  projectId,
) {
  return ref.watch(infraRepositoryProvider).fetchNotes(projectId);
});

final infraAuditLogsProvider = FutureProvider<List<InfraAuditEntry>>((
  ref,
) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref.watch(infraRepositoryProvider).fetchAuditLogs(org.id);
});

final customerMembersProvider = FutureProvider<List<CustomerMember>>((
  ref,
) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref.watch(infraRepositoryProvider).fetchCustomerMembers(org.id);
});

/// The persisted home dashboard snapshot for the *current* user, or null when
/// there is no cache or it belongs to a different account. Lets the home screen
/// render real data on the first frame instead of empty placeholders while the
/// live providers refresh in the background (stale-while-revalidate).
final cachedDashboardProvider = Provider<DashboardSnapshot?>((ref) {
  final cached = ref.watch(dashboardCacheProvider).value;
  if (cached == null) return null;
  final userId = Supabase.instance.client.auth.currentUser?.id;
  return cached.userId == userId ? cached : null;
});

/// Side-effect provider that persists the latest dashboard data once the org,
/// summary and projects have all loaded. Watched by the home screen to keep the
/// on-disk snapshot fresh for the next cold start.
final dashboardCacheWriterProvider = Provider<void>((ref) {
  final org = ref.watch(infraWorkspaceProvider).value;
  final summary = ref.watch(dashboardSummaryProvider).value;
  final projects = ref.watch(projectsProvider).value;
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (org != null && summary != null && projects != null && userId != null) {
    ref
        .read(dashboardCacheProvider)
        .save(
          DashboardSnapshot(
            userId: userId,
            orgName: org.name,
            summary: summary,
            projects: projects,
          ),
        );
  }
});

class InfraRepository {
  const InfraRepository(this._client);
  final SupabaseClient _client;

  // --------------------------------------------------------------------------
  // Workspace
  // --------------------------------------------------------------------------
  Future<InfraWorkspaceSession> getMyWorkspace() async {
    final row = await _client.rpc('get_my_infra_workspace').single();
    final organization = Organization(
      id: row['out_organization_id'] as String,
      name: row['out_organization_name']?.toString() ?? 'My Organization',
    );
    return InfraWorkspaceSession(
      organization: organization,
      role: OrgMemberRoleMapping.fromDb(row['out_role']?.toString()),
    );
  }

  Future<Organization> ensureWorkspace({String? orgName}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Please sign in again to continue.');
    }
    final row = await _client
        .rpc(
          'ensure_infra_workspace',
          params: {
            'p_email': user.email,
            'p_full_name': user.userMetadata?['full_name']?.toString(),
            'p_org_name': orgName,
          },
        )
        .single();
    return Organization(
      id: row['out_organization_id'] as String,
      name: row['out_organization_name']?.toString() ?? 'My Organization',
    );
  }

  Future<Organization> fetchOrganization(String organizationId) async {
    final row = await _client
        .from('organizations')
        .select('id, name, owner_name, phone, address, logo_path')
        .eq('id', organizationId)
        .single();
    return Organization(
      id: row['id'] as String,
      name: row['name']?.toString() ?? 'My Organization',
      ownerName: row['owner_name']?.toString(),
      phone: row['phone']?.toString(),
      address: row['address']?.toString(),
      logoPath: row['logo_path']?.toString(),
    );
  }

  Future<void> updateOrganization({
    required String organizationId,
    String? name,
    String? ownerName,
    String? phone,
    String? address,
  }) async {
    final patch = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (name != null && name.trim().isNotEmpty) patch['name'] = name.trim();
    if (ownerName != null && ownerName.trim().isNotEmpty) {
      patch['owner_name'] = ownerName.trim();
    }
    if (phone != null) patch['phone'] = phone.trim();
    if (address != null) patch['address'] = address.trim();
    await _client.from('organizations').update(patch).eq('id', organizationId);
  }

  Future<List<CustomerMember>> fetchCustomerMembers(
    String organizationId,
  ) async {
    final rows = await _client.rpc(
      'list_customer_members',
      params: {'p_organization_id': organizationId},
    );
    return (rows as List)
        .map<CustomerMember>(
          (raw) => _customerMemberFromRow(Map<String, dynamic>.from(raw)),
        )
        .toList();
  }

  Future<void> createCustomerUser({
    required String organizationId,
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? notes,
  }) async {
    await _client.functions.invoke(
      'create-customer-user',
      body: {
        'organization_id': organizationId,
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'notes': notes,
      },
    );
  }

  Future<void> updateCustomerUser({
    required String organizationId,
    required String userId,
    required String fullName,
    required String email,
    String? password,
    String? phone,
    String? notes,
  }) async {
    await _client.functions.invoke(
      'create-customer-user',
      method: HttpMethod.patch,
      body: {
        'organization_id': organizationId,
        'user_id': userId,
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'notes': notes,
      },
    );
  }

  Future<void> deleteCustomerUser({
    required String organizationId,
    required String userId,
  }) async {
    await _client.functions.invoke(
      'create-customer-user',
      method: HttpMethod.delete,
      body: {'organization_id': organizationId, 'user_id': userId},
    );
  }

  Future<List<String>> fetchCustomerProjectAssignments({
    required String organizationId,
    required String customerUserId,
  }) async {
    final rows = await _client.rpc(
      'list_customer_project_assignments',
      params: {
        'p_organization_id': organizationId,
        'p_customer_user_id': customerUserId,
      },
    );
    return (rows as List)
        .map<String>(
          (raw) => Map<String, dynamic>.from(raw)['project_id'] as String,
        )
        .toList();
  }

  Future<void> setCustomerProjectAssignments({
    required String organizationId,
    required String customerUserId,
    required List<String> projectIds,
  }) async {
    await _client.rpc(
      'set_customer_project_assignments',
      params: {
        'p_organization_id': organizationId,
        'p_customer_user_id': customerUserId,
        'p_project_ids': projectIds,
      },
    );
  }

  // --------------------------------------------------------------------------
  // Dashboard / summaries
  // --------------------------------------------------------------------------
  Future<InfraDashboardSummary> dashboardSummary(String organizationId) async {
    final row = await _client
        .rpc('dashboard_summary', params: {'p_organization_id': organizationId})
        .single();
    return InfraDashboardSummary(
      totalProjects: (row['total_projects'] as num?)?.toInt() ?? 0,
      activeProjects: (row['active_projects'] as num?)?.toInt() ?? 0,
      completedProjects: (row['completed_projects'] as num?)?.toInt() ?? 0,
      delayedProjects: (row['delayed_projects'] as num?)?.toInt() ?? 0,
      totalInvestmentPaise:
          (row['total_investment_paise'] as num?)?.toInt() ?? 0,
      totalGovtSanctionedPaise:
          (row['total_govt_sanctioned_paise'] as num?)?.toInt() ?? 0,
      totalGovtReceivedPaise:
          (row['total_govt_received_paise'] as num?)?.toInt() ?? 0,
      totalExpensePaise: (row['total_expense_paise'] as num?)?.toInt() ?? 0,
      pendingGovtFundsPaise:
          (row['pending_govt_funds_paise'] as num?)?.toInt() ?? 0,
    );
  }

  Future<ProjectFinancialSummary> projectFinancialSummary(
    String projectId,
  ) async {
    final rows = await _client.rpc(
      'project_financial_summary',
      params: {'p_project_id': projectId},
    );
    final list = (rows as List?) ?? const [];
    if (list.isEmpty) return const ProjectFinancialSummary();
    final row = Map<String, dynamic>.from(list.first as Map);
    return ProjectFinancialSummary(
      totalInvestmentPaise:
          (row['total_investment_paise'] as num?)?.toInt() ?? 0,
      totalGovtSanctionedPaise:
          (row['total_govt_sanctioned_paise'] as num?)?.toInt() ?? 0,
      totalGovtReceivedPaise:
          (row['total_govt_received_paise'] as num?)?.toInt() ?? 0,
      pendingGovtPaise: (row['pending_govt_paise'] as num?)?.toInt() ?? 0,
      totalExpensePaise: (row['total_expense_paise'] as num?)?.toInt() ?? 0,
      availableBalancePaise:
          (row['available_balance_paise'] as num?)?.toInt() ?? 0,
    );
  }

  // --------------------------------------------------------------------------
  // Projects
  // --------------------------------------------------------------------------
  Future<List<InfraProject>> fetchProjects(String organizationId) async {
    final rows = await _client
        .from('infra_projects')
        .select()
        .eq('organization_id', organizationId)
        .isFilter('deleted_at', null)
        .order('updated_at', ascending: false);
    return rows
        .map<InfraProject>((r) => _projectFromRow(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<List<InfraProject>> searchProjects(
    String organizationId,
    String query,
  ) async {
    final rows = await _client.rpc(
      'search_projects',
      params: {'p_organization_id': organizationId, 'p_query': query},
    );
    return (rows as List)
        .map<InfraProject>((r) => _projectFromRow(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<String> createProject({
    required String organizationId,
    required String name,
    String? code,
    String? category,
    String? city,
    String? state,
    String? address,
    DateTime? startDate,
    DateTime? expectedEndDate,
    int estimatedCostPaise = 0,
    String? description,
  }) async {
    final id = await _client.rpc(
      'create_project',
      params: {
        'p_organization_id': organizationId,
        'p_name': name,
        'p_code': code,
        'p_category': category,
        'p_location_city': city,
        'p_location_state': state,
        'p_address': address,
        'p_start_date': startDate?.toIso8601String().split('T').first,
        'p_expected_end_date': expectedEndDate
            ?.toIso8601String()
            .split('T')
            .first,
        'p_estimated_cost_paise': estimatedCostPaise,
        'p_description': description,
      },
    );
    return id as String;
  }

  Future<void> updateProject({
    required String projectId,
    String? name,
    String? code,
    String? category,
    String? city,
    String? state,
    String? address,
    InfraProjectStatus? status,
    DateTime? startDate,
    DateTime? expectedEndDate,
    int? estimatedCostPaise,
    String? description,
  }) async {
    final patch = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (name != null) patch['name'] = name;
    if (code != null) patch['code'] = code;
    if (category != null) patch['category'] = category;
    if (city != null) patch['location_city'] = city;
    if (state != null) patch['location_state'] = state;
    if (address != null) patch['address'] = address;
    if (status != null) patch['status'] = _statusToDb(status);
    if (startDate != null) {
      patch['start_date'] = startDate.toIso8601String().split('T').first;
    }
    if (expectedEndDate != null) {
      patch['expected_end_date'] = expectedEndDate
          .toIso8601String()
          .split('T')
          .first;
    }
    if (estimatedCostPaise != null) {
      patch['total_estimated_cost_paise'] = estimatedCostPaise;
    }
    if (description != null) patch['description'] = description;
    await _client.from('infra_projects').update(patch).eq('id', projectId);
  }

  Future<void> updateProgress(String projectId, int progressPercent) async {
    await _client.rpc(
      'update_project_progress',
      params: {
        'p_project_id': projectId,
        'p_progress_percent': progressPercent,
      },
    );
  }

  /// Soft-deletes a project and cascades the soft-delete to all its child
  /// financial records (investments, government funds + receipts, expenses,
  /// notes, documents, progress) atomically via the delete_project RPC.
  Future<void> softDeleteProject(String projectId) async {
    await _client.rpc('delete_project', params: {'p_project_id': projectId});
  }

  // --------------------------------------------------------------------------
  // Investors + investments
  // --------------------------------------------------------------------------
  Future<List<Investor>> fetchInvestors(String organizationId) async {
    final rows = await _client
        .from('investors')
        .select()
        .eq('organization_id', organizationId)
        .isFilter('deleted_at', null)
        .order('name');
    return rows
        .map<Investor>((r) => _investorFromRow(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<List<Investor>> fetchProjectInvestors(String projectId) async {
    final rows = await _client
        .from('project_investments')
        .select('investors!inner(*)')
        .eq('project_id', projectId)
        .isFilter('deleted_at', null);
    final byId = <String, Investor>{};
    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw);
      final investorRaw = row['investors'];
      if (investorRaw is! Map) continue;
      final investorRow = Map<String, dynamic>.from(investorRaw);
      if (investorRow['deleted_at'] != null) continue;
      final investor = _investorFromRow(investorRow);
      byId[investor.id] = investor;
    }
    return byId.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<String> createInvestor({
    required String organizationId,
    required String name,
    String? phone,
    String? email,
    String? pan,
    String? address,
    String? notes,
  }) async {
    final row = await _client
        .from('investors')
        .insert({
          'organization_id': organizationId,
          'name': name,
          'phone': phone?.trim().isEmpty ?? true ? null : phone!.trim(),
          'email': email?.trim().isEmpty ?? true ? null : email!.trim(),
          'pan': pan?.trim().isEmpty ?? true ? null : pan!.trim(),
          'address': address?.trim().isEmpty ?? true ? null : address!.trim(),
          'notes': notes?.trim().isEmpty ?? true ? null : notes!.trim(),
        })
        .select('id')
        .single();
    return row['id'] as String;
  }

  Future<Investor> updateInvestor({
    required String investorId,
    required String name,
    String? phone,
    String? email,
    String? pan,
    String? address,
    String? notes,
  }) async {
    final row = await _client
        .from('investors')
        .update({
          'name': name.trim(),
          'phone': phone?.trim().isEmpty ?? true ? null : phone!.trim(),
          'email': email?.trim().isEmpty ?? true ? null : email!.trim(),
          'pan': pan?.trim().isEmpty ?? true ? null : pan!.trim(),
          'address': address?.trim().isEmpty ?? true ? null : address!.trim(),
          'notes': notes?.trim().isEmpty ?? true ? null : notes!.trim(),
        })
        .eq('id', investorId)
        .isFilter('deleted_at', null)
        .select()
        .single();
    return _investorFromRow(Map<String, dynamic>.from(row));
  }

  Future<void> deleteProjectInvestor({
    required String projectId,
    required String investorId,
  }) async {
    final rows = await _client
        .from('project_investments')
        .select('id')
        .eq('project_id', projectId)
        .eq('investor_id', investorId)
        .isFilter('deleted_at', null);
    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw);
      await deleteInvestment(row['id'] as String);
    }
    await archiveInvestorIfUnused(investorId);
  }

  Future<void> archiveInvestorIfUnused(String investorId) async {
    final activeRows = await _client
        .from('project_investments')
        .select('id')
        .eq('investor_id', investorId)
        .isFilter('deleted_at', null)
        .limit(1);
    if (activeRows.isNotEmpty) return;
    await _client
        .from('investors')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', investorId)
        .isFilter('deleted_at', null);
  }

  Future<List<ProjectInvestment>> fetchInvestments(String projectId) async {
    final rows = await _client
        .from('project_investments')
        .select('*, investors(name)')
        .eq('project_id', projectId)
        .isFilter('deleted_at', null)
        .order('investment_date', ascending: false);
    return rows.map<ProjectInvestment>((raw) {
      final r = Map<String, dynamic>.from(raw);
      final investor = r['investors'] is Map
          ? Map<String, dynamic>.from(r['investors'] as Map)
          : null;
      return ProjectInvestment(
        id: r['id'] as String,
        projectId: r['project_id'] as String,
        investorId: r['investor_id'] as String,
        amountPaise: (r['amount_paise'] as num?)?.toInt() ?? 0,
        investmentDate: DateTime.tryParse(
          r['investment_date']?.toString() ?? '',
        ),
        paymentMode: r['payment_mode']?.toString() ?? 'bank',
        referenceNumber: r['reference_number']?.toString(),
        notes: r['notes']?.toString(),
        investorName: investor?['name']?.toString(),
      );
    }).toList();
  }

  Future<void> addInvestment({
    required String projectId,
    required String investorId,
    required int amountPaise,
    DateTime? date,
    String paymentMode = 'bank',
    String? referenceNumber,
    String? notes,
  }) async {
    await _client.rpc(
      'add_project_investment',
      params: {
        'p_project_id': projectId,
        'p_investor_id': investorId,
        'p_amount_paise': amountPaise,
        'p_investment_date': (date ?? DateTime.now())
            .toIso8601String()
            .split('T')
            .first,
        'p_payment_mode': paymentMode,
        'p_reference_number': referenceNumber,
        'p_notes': notes,
      },
    );
  }

  Future<void> updateInvestment({
    required String investmentId,
    required String investorId,
    required int amountPaise,
    DateTime? date,
    String paymentMode = 'bank',
    String? referenceNumber,
    String? notes,
  }) async {
    await _client.rpc(
      'update_project_investment',
      params: {
        'p_investment_id': investmentId,
        'p_investor_id': investorId,
        'p_amount_paise': amountPaise,
        'p_investment_date': (date ?? DateTime.now())
            .toIso8601String()
            .split('T')
            .first,
        'p_payment_mode': paymentMode,
        'p_reference_number': referenceNumber,
        'p_notes': notes,
      },
    );
  }

  Future<void> deleteInvestment(String investmentId) async {
    await _client.rpc(
      'delete_project_investment',
      params: {'p_investment_id': investmentId},
    );
  }

  // --------------------------------------------------------------------------
  // Government funds + receipts
  // --------------------------------------------------------------------------
  Future<List<GovernmentFund>> fetchGovernmentFunds(String projectId) async {
    final rows = await _client
        .from('government_funds')
        .select()
        .eq('project_id', projectId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);
    return rows
        .map<GovernmentFund>((r) => _fundFromRow(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<void> addGovernmentFund({
    required String projectId,
    required String departmentName,
    String? schemeName,
    String? sanctionOrderNumber,
    required int amountSanctionedPaise,
    DateTime? sanctionDate,
    String? notes,
  }) async {
    await _client.rpc(
      'add_government_fund',
      params: {
        'p_project_id': projectId,
        'p_department_name': departmentName,
        'p_scheme_name': schemeName,
        'p_sanction_order_number': sanctionOrderNumber,
        'p_amount_sanctioned_paise': amountSanctionedPaise,
        'p_sanction_date': sanctionDate?.toIso8601String().split('T').first,
        'p_document_path': null,
        'p_notes': notes,
      },
    );
  }

  Future<void> updateGovernmentFund({
    required String fundId,
    required String departmentName,
    String? schemeName,
    String? sanctionOrderNumber,
    required int amountSanctionedPaise,
    DateTime? sanctionDate,
    String? notes,
  }) async {
    await _client.rpc(
      'update_government_fund',
      params: {
        'p_fund_id': fundId,
        'p_department_name': departmentName,
        'p_scheme_name': schemeName,
        'p_sanction_order_number': sanctionOrderNumber,
        'p_amount_sanctioned_paise': amountSanctionedPaise,
        'p_sanction_date': sanctionDate?.toIso8601String().split('T').first,
        'p_notes': notes,
      },
    );
  }

  Future<void> deleteGovernmentFund(String fundId) async {
    await _client.rpc('delete_government_fund', params: {'p_fund_id': fundId});
  }

  Future<void> deleteGovernmentReceipt(String receiptId) async {
    await _client.rpc(
      'delete_government_receipt',
      params: {'p_receipt_id': receiptId},
    );
  }

  Future<List<GovernmentFundReceipt>> fetchReceipts(
    String governmentFundId,
  ) async {
    final rows = await _client
        .from('government_fund_receipts')
        .select()
        .eq('government_fund_id', governmentFundId)
        .isFilter('deleted_at', null)
        .order('received_date', ascending: false);
    return rows.map<GovernmentFundReceipt>((raw) {
      final r = Map<String, dynamic>.from(raw);
      return GovernmentFundReceipt(
        id: r['id'] as String,
        governmentFundId: r['government_fund_id'] as String,
        projectId: r['project_id'] as String,
        amountPaise: (r['amount_paise'] as num?)?.toInt() ?? 0,
        receivedDate: DateTime.tryParse(r['received_date']?.toString() ?? ''),
        paymentMode: r['payment_mode']?.toString() ?? 'bank',
        referenceNumber: r['reference_number']?.toString(),
        notes: r['notes']?.toString(),
      );
    }).toList();
  }

  Future<void> addGovernmentReceipt({
    required String governmentFundId,
    required int amountPaise,
    DateTime? receivedDate,
    String paymentMode = 'bank',
    String? referenceNumber,
    String? notes,
  }) async {
    await _client.rpc(
      'add_government_fund_receipt',
      params: {
        'p_government_fund_id': governmentFundId,
        'p_amount_paise': amountPaise,
        'p_received_date': (receivedDate ?? DateTime.now())
            .toIso8601String()
            .split('T')
            .first,
        'p_payment_mode': paymentMode,
        'p_reference_number': referenceNumber,
        'p_document_path': null,
        'p_notes': notes,
      },
    );
  }

  // --------------------------------------------------------------------------
  // Expenses
  // --------------------------------------------------------------------------
  Future<List<ProjectExpense>> fetchExpenses(String projectId) async {
    final rows = await _client
        .from('project_expenses')
        .select()
        .eq('project_id', projectId)
        .isFilter('deleted_at', null)
        .order('expense_date', ascending: false);
    return rows
        .map<ProjectExpense>(
          (r) => _expenseFromRow(Map<String, dynamic>.from(r)),
        )
        .toList();
  }

  Future<void> addExpense({
    required String projectId,
    required String category,
    required int amountPaise,
    String? vendorName,
    DateTime? date,
    String paymentMode = 'cash',
    String? billNumber,
    String? notes,
  }) async {
    await _client.rpc(
      'add_project_expense',
      params: {
        'p_project_id': projectId,
        'p_category': category,
        'p_amount_paise': amountPaise,
        'p_vendor_name': vendorName,
        'p_expense_date': (date ?? DateTime.now())
            .toIso8601String()
            .split('T')
            .first,
        'p_payment_mode': paymentMode,
        'p_bill_number': billNumber,
        'p_bill_image_path': null,
        'p_notes': notes,
      },
    );
  }

  Future<void> updateExpense({
    required String expenseId,
    required String category,
    required int amountPaise,
    String? vendorName,
    DateTime? date,
    String paymentMode = 'cash',
    String? billNumber,
    String? notes,
  }) async {
    await _client.rpc(
      'update_project_expense',
      params: {
        'p_expense_id': expenseId,
        'p_category': category,
        'p_amount_paise': amountPaise,
        'p_vendor_name': vendorName,
        'p_expense_date': (date ?? DateTime.now())
            .toIso8601String()
            .split('T')
            .first,
        'p_payment_mode': paymentMode,
        'p_bill_number': billNumber,
        'p_notes': notes,
      },
    );
  }

  Future<void> deleteExpense(String expenseId) async {
    await _client.rpc(
      'delete_project_expense',
      params: {'p_expense_id': expenseId},
    );
  }

  // --------------------------------------------------------------------------
  // Notes
  // --------------------------------------------------------------------------
  Future<List<ProjectNote>> fetchNotes(String projectId) async {
    final rows = await _client
        .from('project_notes')
        .select()
        .eq('project_id', projectId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);
    return rows.map<ProjectNote>((raw) {
      final r = Map<String, dynamic>.from(raw);
      return ProjectNote(
        id: r['id'] as String,
        projectId: r['project_id'] as String,
        note: r['note']?.toString() ?? '',
        createdBy: r['created_by']?.toString(),
        createdAt: DateTime.tryParse(r['created_at']?.toString() ?? ''),
      );
    }).toList();
  }

  Future<void> addNote({
    required String organizationId,
    required String projectId,
    required String note,
  }) async {
    await _client.from('project_notes').insert({
      'organization_id': organizationId,
      'project_id': projectId,
      'note': note,
    });
  }

  // --------------------------------------------------------------------------
  // Audit logs
  // --------------------------------------------------------------------------
  Future<List<InfraAuditEntry>> fetchAuditLogs(String organizationId) async {
    final rows = await _client
        .from('project_audit_logs')
        .select('id, entity_table, action, created_at')
        .eq('organization_id', organizationId)
        .order('created_at', ascending: false)
        .limit(100);
    return rows.map<InfraAuditEntry>((raw) {
      final r = Map<String, dynamic>.from(raw);
      return InfraAuditEntry(
        id: r['id'] as String,
        entityTable: r['entity_table']?.toString() ?? '',
        action: r['action']?.toString() ?? '',
        createdAt:
            DateTime.tryParse(r['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  // --------------------------------------------------------------------------
  // Row mappers
  // --------------------------------------------------------------------------
  InfraProject _projectFromRow(Map<String, dynamic> r) {
    return InfraProject(
      id: r['id'] as String,
      organizationId: r['organization_id'] as String,
      name: r['name']?.toString() ?? '',
      code: r['code']?.toString(),
      category: r['category']?.toString(),
      locationCity: r['location_city']?.toString(),
      locationState: r['location_state']?.toString(),
      address: r['address']?.toString(),
      status: _statusFromDb(r['status']?.toString()),
      startDate: DateTime.tryParse(r['start_date']?.toString() ?? ''),
      expectedEndDate: DateTime.tryParse(
        r['expected_end_date']?.toString() ?? '',
      ),
      actualEndDate: DateTime.tryParse(r['actual_end_date']?.toString() ?? ''),
      progressPercent: (r['progress_percent'] as num?)?.toInt() ?? 0,
      totalEstimatedCostPaise:
          (r['total_estimated_cost_paise'] as num?)?.toInt() ?? 0,
      totalInvestmentPaise: (r['total_investment_paise'] as num?)?.toInt() ?? 0,
      totalGovtSanctionedPaise:
          (r['total_govt_sanctioned_paise'] as num?)?.toInt() ?? 0,
      totalGovtReceivedPaise:
          (r['total_govt_received_paise'] as num?)?.toInt() ?? 0,
      totalExpensePaise: (r['total_expense_paise'] as num?)?.toInt() ?? 0,
      description: r['description']?.toString(),
      coverImageUrl: r['cover_image_url']?.toString(),
      createdAt: DateTime.tryParse(r['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(r['updated_at']?.toString() ?? ''),
    );
  }

  Investor _investorFromRow(Map<String, dynamic> r) {
    return Investor(
      id: r['id'] as String,
      organizationId: r['organization_id'] as String,
      name: r['name']?.toString() ?? '',
      phone: r['phone']?.toString(),
      email: r['email']?.toString(),
      address: r['address']?.toString(),
      pan: r['pan']?.toString(),
      notes: r['notes']?.toString(),
    );
  }

  GovernmentFund _fundFromRow(Map<String, dynamic> r) {
    return GovernmentFund(
      id: r['id'] as String,
      projectId: r['project_id'] as String,
      departmentName: r['department_name']?.toString() ?? '',
      schemeName: r['scheme_name']?.toString(),
      sanctionOrderNumber: r['sanction_order_number']?.toString(),
      amountSanctionedPaise:
          (r['amount_sanctioned_paise'] as num?)?.toInt() ?? 0,
      amountReceivedPaise: (r['amount_received_paise'] as num?)?.toInt() ?? 0,
      sanctionDate: DateTime.tryParse(r['sanction_date']?.toString() ?? ''),
      lastReceivedDate: DateTime.tryParse(
        r['last_received_date']?.toString() ?? '',
      ),
      status: _fundStatusFromDb(r['status']?.toString()),
      documentPath: r['document_path']?.toString(),
      notes: r['notes']?.toString(),
    );
  }

  ProjectExpense _expenseFromRow(Map<String, dynamic> r) {
    return ProjectExpense(
      id: r['id'] as String,
      projectId: r['project_id'] as String,
      category: r['category']?.toString() ?? 'Miscellaneous',
      vendorName: r['vendor_name']?.toString(),
      amountPaise: (r['amount_paise'] as num?)?.toInt() ?? 0,
      expenseDate: DateTime.tryParse(r['expense_date']?.toString() ?? ''),
      paymentMode: r['payment_mode']?.toString() ?? 'cash',
      billNumber: r['bill_number']?.toString(),
      billImagePath: r['bill_image_path']?.toString(),
      notes: r['notes']?.toString(),
      createdBy: r['created_by']?.toString(),
    );
  }

  CustomerMember _customerMemberFromRow(Map<String, dynamic> r) {
    return CustomerMember(
      memberId: r['member_id'] as String,
      userId: r['user_id'] as String,
      fullName: r['full_name']?.toString(),
      email: r['email']?.toString(),
      phone: r['phone']?.toString(),
      notes: r['notes']?.toString(),
      role: OrgMemberRoleMapping.fromDb(r['role']?.toString()),
      createdAt: DateTime.tryParse(r['created_at']?.toString() ?? ''),
    );
  }

  static int parsePaise(String input) => Money.fromRupeeString(input).paise;

  static String _statusToDb(InfraProjectStatus s) => switch (s) {
    InfraProjectStatus.planning => 'planning',
    InfraProjectStatus.active => 'active',
    InfraProjectStatus.onHold => 'on_hold',
    InfraProjectStatus.completed => 'completed',
    InfraProjectStatus.cancelled => 'cancelled',
  };

  static InfraProjectStatus _statusFromDb(String? v) => switch (v) {
    'active' => InfraProjectStatus.active,
    'on_hold' => InfraProjectStatus.onHold,
    'completed' => InfraProjectStatus.completed,
    'cancelled' => InfraProjectStatus.cancelled,
    _ => InfraProjectStatus.planning,
  };

  static GovtFundStatus _fundStatusFromDb(String? v) => switch (v) {
    'partially_received' => GovtFundStatus.partiallyReceived,
    'fully_received' => GovtFundStatus.fullyReceived,
    'delayed' => GovtFundStatus.delayed,
    'cancelled' => GovtFundStatus.cancelled,
    _ => GovtFundStatus.sanctioned,
  };
}

/// Lightweight audit entry used by the audit log screen.
class InfraAuditEntry {
  const InfraAuditEntry({
    required this.id,
    required this.entityTable,
    required this.action,
    required this.createdAt,
  });

  final String id;
  final String entityTable;
  final String action;
  final DateTime createdAt;
}
