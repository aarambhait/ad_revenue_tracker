import 'package:intl/intl.dart';

class AppFormatter {
  static String currency(double amount, String currencyCode) {
    String symbol;
    switch (currencyCode.toUpperCase()) {
      case 'EUR':
        symbol = '€';
        break;
      case 'GBP':
        symbol = '£';
        break;
      case 'INR':
        symbol = '₹';
        break;
      case 'NPR':
        symbol = '₨';
        break;
      case 'USD':
      default:
        symbol = '\$';
        break;
    }

    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String number(int value) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(value);
  }

  static String compactNumber(double value) {
    final formatter = NumberFormat.compact();
    return formatter.format(value);
  }

  static String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
