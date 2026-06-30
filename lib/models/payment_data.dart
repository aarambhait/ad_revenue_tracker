class PaymentData {
  final String date;
  final double amount;
  final String status;
  final String referenceNumber;
  final String paymentMethod;

  PaymentData({
    required this.date,
    required this.amount,
    required this.status,
    required this.referenceNumber,
    required this.paymentMethod,
  });
}
