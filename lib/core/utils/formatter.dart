import 'package:intl/intl.dart';

class AppFormatter {
  // Static currency conversion rates (Base: USD)
  static const Map<String, double> _conversionRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.78,
    'INR': 83.50,
    'NPR': 133.60,
  };

  // Convert USD to display currency
  static double convert(double amount, String toCurrency) {
    final rate = _conversionRates[toCurrency.toUpperCase()] ?? 1.0;
    return amount * rate;
  }

  // Get localized Google AdSense payout thresholds
  static double threshold(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'EUR':
        return 70.0;
      case 'GBP':
        return 60.0;
      case 'INR':
        return 8000.0;
      case 'NPR':
        return 10000.0;
      case 'USD':
      default:
        return 100.0;
    }
  }

  static String currency(double amount, String currencyCode) {
    final convertedAmount = convert(amount, currencyCode);
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
        symbol = '₨ ';
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
    return formatter.format(convertedAmount);
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
