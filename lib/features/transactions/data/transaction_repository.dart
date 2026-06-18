import 'package:disnetfin/core/config/app_config.dart';
import 'package:disnetfin/features/transactions/domain/transaction_item.dart';
import 'package:pocketbase/pocketbase.dart';

class TransactionRepository {
  const TransactionRepository(this._client);

  final PocketBase _client;

  Future<List<TransactionItem>> fetchTransactions() async {
    final result = await _client
        .collection(AppConfig.transactionsCollection)
        .getFullList(sort: '-created');

    return result
        .map((record) {
          final createdRaw = record.toJson()['created']?.toString() ?? '';
          return TransactionItem.fromPocketBaseData(
            id: record.id,
            data: record.data,
            created: DateTime.tryParse(createdRaw) ?? DateTime.now(),
          );
        })
        .toList(growable: false);
  }
}
