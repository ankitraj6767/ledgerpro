enum SyncEntityType {
  business,
  book,
  party,
  transaction,
  attachment,
  reminder,
  organization,
  organizationMember,
  infraProject,
  investor,
  projectInvestment,
  governmentFund,
  governmentFundReceipt,
  projectExpense,
  projectNote,
  projectDocument,
  customerProjectAssignment,
  projectProgressUpdate,
  reportCache,
}

enum SyncMutationAction { create, update, archive, upload }

enum SyncMutationStatus { pending, inFlight, failed, synced }

class PendingMutation {
  const PendingMutation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.createdAt,
    this.status = SyncMutationStatus.pending,
    this.attempts = 0,
    this.lastError,
  });

  final String id;
  final SyncEntityType entityType;
  final String entityId;
  final SyncMutationAction action;
  final DateTime createdAt;
  final SyncMutationStatus status;
  final int attempts;
  final String? lastError;

  PendingMutation copyWith({
    SyncMutationStatus? status,
    int? attempts,
    String? lastError,
  }) {
    return PendingMutation(
      id: id,
      entityType: entityType,
      entityId: entityId,
      action: action,
      createdAt: createdAt,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: lastError,
    );
  }
}

class SyncQueue {
  SyncQueue([Iterable<PendingMutation> initial = const []])
    : _items = [...initial];

  final List<PendingMutation> _items;

  List<PendingMutation> get items => List.unmodifiable(_items);

  void enqueue(PendingMutation mutation) {
    final existingIndex = _items.indexWhere((item) => item.id == mutation.id);
    if (existingIndex >= 0) {
      _items[existingIndex] = mutation;
      return;
    }
    _items.add(mutation);
  }

  void markInFlight(String id) => _replace(
    id,
    (item) => item.copyWith(status: SyncMutationStatus.inFlight),
  );

  void markSynced(String id) => _replace(
    id,
    (item) => item.copyWith(status: SyncMutationStatus.synced, lastError: null),
  );

  void markFailed(String id, String message) => _replace(
    id,
    (item) => item.copyWith(
      status: SyncMutationStatus.failed,
      attempts: item.attempts + 1,
      lastError: message,
    ),
  );

  List<PendingMutation> retryableOrder() {
    final copy = _items
        .where(
          (item) =>
              item.status == SyncMutationStatus.pending ||
              item.status == SyncMutationStatus.failed,
        )
        .toList();
    copy.sort((a, b) {
      final priority = _priority(
        a.entityType,
      ).compareTo(_priority(b.entityType));
      if (priority != 0) return priority;
      return a.createdAt.compareTo(b.createdAt);
    });
    return copy;
  }

  void _replace(String id, PendingMutation Function(PendingMutation) update) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _items[index] = update(_items[index]);
  }

  int _priority(SyncEntityType type) {
    return switch (type) {
      SyncEntityType.business => 0,
      SyncEntityType.book => 1,
      SyncEntityType.party => 2,
      SyncEntityType.transaction => 3,
      SyncEntityType.attachment => 4,
      SyncEntityType.reminder => 5,
      SyncEntityType.organization => 6,
      SyncEntityType.organizationMember => 7,
      SyncEntityType.infraProject => 8,
      SyncEntityType.investor => 9,
      SyncEntityType.projectInvestment => 10,
      SyncEntityType.governmentFund => 11,
      SyncEntityType.governmentFundReceipt => 12,
      SyncEntityType.projectExpense => 13,
      SyncEntityType.projectNote => 14,
      SyncEntityType.projectDocument => 15,
      SyncEntityType.customerProjectAssignment => 16,
      SyncEntityType.projectProgressUpdate => 17,
      SyncEntityType.reportCache => 18,
    };
  }
}
