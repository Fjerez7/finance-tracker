import 'package:intl/intl.dart';
import '../domain/entities/account.dart';
import '../domain/entities/category.dart';
import '../domain/entities/transaction.dart';

/// Service responsible for exporting tabular financial records into RFC 4180 CSV format.
class CsvExportService {
  /// Exports transactions into a CSV formatted string.
  static String exportTransactionsToCsv({
    required List<Transaction> transactions,
    required List<Account> accounts,
    required List<Category> categories,
  }) {
    final accountMap = {for (final a in accounts) a.id: a.name};
    final categoryMap = {for (final c in categories) c.id: c.name};
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln(
      'ID,Date,Account,Category,Type,Amount_Formatted,Amount_Cents,Description',
    );

    for (final tx in transactions) {
      final accountName = accountMap[tx.accountId] ?? 'Unknown Account';
      final categoryName =
          tx.categoryId != null
              ? (categoryMap[tx.categoryId] ?? 'Uncategorized')
              : 'N/A';
      final dateStr = dateFormat.format(tx.transactionDate);
      final typeStr = tx.type.name;
      final amountFormatted =
          (tx.amountCents / 100.0).toStringAsFixed(2);

      buffer.writeln(
        [
          _escapeCsv(tx.id),
          _escapeCsv(dateStr),
          _escapeCsv(accountName),
          _escapeCsv(categoryName),
          _escapeCsv(typeStr),
          amountFormatted,
          tx.amountCents.toString(),
          _escapeCsv(tx.description),
        ].join(','),
      );
    }

    return buffer.toString();
  }

  /// Escapes a CSV cell value per RFC 4180 rules.
  static String _escapeCsv(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }
}
