class Payment {
  final String id;
  final String orderId;
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;
  final double amount;
  final String provider;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
    required this.amount,
    required this.provider,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'],
    orderId: json['orderId'],
    razorpayPaymentId: json['razorpay_paymentId'],
    razorpayOrderId: json['razorpay_orderId'],
    razorpaySignature: json['razorpay_signature'],
    amount: (json['amount'] as num).toDouble(),
    provider: json['provider'],
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'razorpay_paymentId': razorpayPaymentId,
    'razorpay_orderId': razorpayOrderId,
    'razorpay_signature': razorpaySignature,
    'amount': amount,
    'provider': provider,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
