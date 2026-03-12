enum PaymentStatus {
  pending('PENDING'),
  paid('PAID'),
  overdue('OVERDUE'),
  cancelled('CANCELLED');

  final String value;
  const PaymentStatus(this.value);

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

enum PaymentType {
  installment('INSTALLMENT'),
  maintenanceFee('MAINTENANCE_FEE'),
  serviceCharge('SERVICE_CHARGE'),
  addonPayment('ADDON_PAYMENT'),
  other('OTHER');

  final String value;
  const PaymentType(this.value);

  static PaymentType fromString(String value) {
    return PaymentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PaymentType.other,
    );
  }
}

class PaymentModel {
  final String id;
  final String userId;
  final String? propertyId;
  final double amount;
  final String currency;
  final PaymentType paymentType;
  final PaymentStatus status;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final String? description;
  final String? invoiceNumber;
  final String? receiptUrl;
  final int? installmentNumber;
  final int? totalInstallments;
  final double? percentage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PropertyInfo? property;

  PaymentModel({
    required this.id,
    required this.userId,
    this.propertyId,
    required this.amount,
    required this.currency,
    required this.paymentType,
    required this.status,
    this.dueDate,
    this.paidDate,
    this.description,
    this.invoiceNumber,
    this.receiptUrl,
    this.installmentNumber,
    this.totalInstallments,
    this.percentage,
    required this.createdAt,
    required this.updatedAt,
    this.property,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      propertyId: json['propertyId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentType: PaymentType.fromString(json['paymentType'] as String),
      status: PaymentStatus.fromString(json['status'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'] as String)
          : null,
      description: json['description'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      installmentNumber: json['installmentNumber'] as int?,
      totalInstallments: json['totalInstallments'] as int?,
      percentage: json['percentage'] != null ? (json['percentage'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      property: json['property'] != null
          ? PropertyInfo.fromJson(json['property'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PropertyInfo {
  final String id;
  final String name;
  final String location;
  final String propertyType;

  PropertyInfo({
    required this.id,
    required this.name,
    required this.location,
    required this.propertyType,
  });

  factory PropertyInfo.fromJson(Map<String, dynamic> json) {
    return PropertyInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      propertyType: json['propertyType'] as String,
    );
  }
}

class PaymentSummary {
  final double total;
  final double paid;
  final double pending;
  final double overdue;
  final int paymentCount;
  final int paidCount;
  final int pendingCount;
  final int overdueCount;

  PaymentSummary({
    required this.total,
    required this.paid,
    required this.pending,
    required this.overdue,
    required this.paymentCount,
    required this.paidCount,
    required this.pendingCount,
    required this.overdueCount,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      total: (json['total'] as num).toDouble(),
      paid: (json['paid'] as num).toDouble(),
      pending: (json['pending'] as num).toDouble(),
      overdue: (json['overdue'] as num).toDouble(),
      paymentCount: json['paymentCount'] as int,
      paidCount: json['paidCount'] as int,
      pendingCount: json['pendingCount'] as int,
      overdueCount: json['overdueCount'] as int,
    );
  }
}
