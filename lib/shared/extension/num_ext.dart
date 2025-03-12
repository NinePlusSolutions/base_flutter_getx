import 'package:intl/intl.dart';

extension NumExt on num {
  String formatCurrency() {
    final formatter = NumberFormat.simpleCurrency();
    return formatter.format(this);
  }

  String formatNumber() {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(this);
  }
}
