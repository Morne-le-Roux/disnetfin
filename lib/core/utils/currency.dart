import 'package:intl/intl.dart';

final NumberFormat currencyFormat = NumberFormat.simpleCurrency();

String formatCurrency(double amount, {String? currencyCode}) {
  if (currencyCode == null || currencyCode.isEmpty) {
    return currencyFormat.format(amount);
  }

  final formatter = NumberFormat.simpleCurrency(name: currencyCode);
  return formatter.format(amount);
}
