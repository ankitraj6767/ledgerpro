import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/constants/supabase_config.dart';

final supabaseLedgerApiProvider = Provider<SupabaseLedgerApi?>((ref) {
  if (!SupabaseConfig.isConfigured) return null;
  try {
    return SupabaseLedgerApi(Supabase.instance.client);
  } catch (_) {
    return null;
  }
});

class SupabaseLedgerApi {
  const SupabaseLedgerApi(this._client);

  final SupabaseClient _client;

  Future<void> upsertParty(Map<String, dynamic> party) async {
    await _client.from('parties').upsert(party);
  }

  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    await _client.from('transactions').insert(transaction);
  }

  Future<void> upsertReminder(Map<String, dynamic> reminder) async {
    await _client.from('reminders').upsert(reminder);
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
}
