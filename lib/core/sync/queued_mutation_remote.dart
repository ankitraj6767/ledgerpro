class QueuedMutationRequest {
  const QueuedMutationRequest({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.payload,
  });

  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final Map<String, dynamic> payload;
}

abstract interface class QueuedMutationRemote {
  Future<void> applyQueuedMutation(QueuedMutationRequest mutation);
}

class SyncConflictException implements Exception {
  const SyncConflictException(this.message);

  final String message;

  @override
  String toString() => 'Sync conflict: $message';
}
