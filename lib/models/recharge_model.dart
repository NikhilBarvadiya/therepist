import 'package:intl/intl.dart';

class RechargePlan {
  final String id;
  final String title;
  final String description;
  final double amount;
  final int validityDays;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RechargePlan({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.validityDays,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RechargePlan.fromJson(Map<String, dynamic> json) {
    return RechargePlan(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      validityDays: json['validity_days'] ?? 0,
      status: json['status'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'validity_days': validityDays,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class DoctorRechargePayment {
  final String id;
  final String doctorId;
  final dynamic rechargePlanId;
  final RechargePlanSnapshot planSnapshot;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final String status;
  final Map<String, dynamic> extraDetails;
  final DateTime activationStart;
  final DateTime activationEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  DoctorRechargePayment({
    required this.id,
    required this.doctorId,
    required this.rechargePlanId,
    required this.planSnapshot,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    required this.extraDetails,
    required this.activationStart,
    required this.activationEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoctorRechargePayment.fromJson(Map<String, dynamic> json) {
    return DoctorRechargePayment(
      id: json['_id'] ?? json['id'] ?? '',
      doctorId: json['doctorId'] ?? '',
      rechargePlanId: json['rechargePlanId'],
      planSnapshot: RechargePlanSnapshot.fromJson(json['planSnapshot'] ?? json['planSnapshot'] ?? {}),
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      transactionId: json['transactionId'] ?? '',
      status: json['status'] ?? 'paid',
      extraDetails: Map<String, dynamic>.from(json['extraDetails'] ?? {}),
      activationStart: json['activationStart'] != null ? DateTime.parse(json['activationStart']) : DateTime.now(),
      activationEnd: json['activationEnd'] != null ? DateTime.parse(json['activationEnd']) : DateTime.now(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  String get formattedDate => DateFormat('MMM dd, yyyy').format(createdAt);

  String get formattedTime => DateFormat('hh:mm a').format(createdAt);
}

class RechargePlanSnapshot {
  final String title;
  final int validityDays;
  final double amount;

  RechargePlanSnapshot({required this.title, required this.validityDays, required this.amount});

  factory RechargePlanSnapshot.fromJson(Map<String, dynamic> json) {
    return RechargePlanSnapshot(title: json['title'] ?? '', validityDays: json['validity_days'] ?? 0, amount: (json['amount'] ?? 0).toDouble());
  }
}

class WalletSummary {
  final double totalBalance;
  final double totalEarned;
  final double totalSpent;
  final double availableBalance;
  final DateTime lastUpdated;

  WalletSummary({required this.totalBalance, required this.totalEarned, required this.totalSpent, required this.availableBalance, required this.lastUpdated});

  factory WalletSummary.fromPayments(List<DoctorRechargePayment> payments) {
    final paidPayments = payments.where((p) => p.status == 'paid').toList();
    final totalEarned = paidPayments.fold(0.0, (sum, p) => sum + p.amount);
    final cancelledPayments = payments.where((p) => p.status == 'cancelled').toList();
    final totalSpent = cancelledPayments.fold(0.0, (sum, p) => sum + p.amount);

    return WalletSummary(totalBalance: totalEarned, totalEarned: totalEarned, totalSpent: totalSpent, availableBalance: totalEarned - totalSpent, lastUpdated: DateTime.now());
  }
}

class CreateRechargeRequest {
  final String rechargePlanId;
  final String paymentMethod;
  final String transactionId;
  final Map<String, dynamic>? extraDetails;

  CreateRechargeRequest({required this.rechargePlanId, required this.paymentMethod, required this.transactionId, this.extraDetails});

  Map<String, dynamic> toJson() {
    return {'rechargePlanId': rechargePlanId, 'paymentMethod': paymentMethod, 'transactionId': transactionId, if (extraDetails != null) 'extraDetails': extraDetails};
  }
}
