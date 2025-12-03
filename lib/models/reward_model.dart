class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String? imageUrl;
  final String category; // discount, service, product, premium
  final DateTime expiryDate;
  final DateTime createdAt;
  final String? redemptionCode;
  final bool isLimited;
  final int remainingQuantity;
  final bool isActive;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    this.imageUrl,
    required this.category,
    required this.expiryDate,
    required this.createdAt,
    this.redemptionCode,
    this.isLimited = false,
    this.remainingQuantity = 0,
    this.isActive = true,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  bool get isAvailable => isActive && !isExpired && (!isLimited || remainingQuantity > 0);

  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'pointsRequired': pointsRequired,
    'imageUrl': imageUrl,
    'category': category,
    'expiryDate': expiryDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'redemptionCode': redemptionCode,
    'isLimited': isLimited,
    'remainingQuantity': remainingQuantity,
    'isActive': isActive,
  };

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    pointsRequired: json['pointsRequired'],
    imageUrl: json['imageUrl'],
    category: json['category'],
    expiryDate: DateTime.parse(json['expiryDate']),
    createdAt: DateTime.parse(json['createdAt']),
    redemptionCode: json['redemptionCode'],
    isLimited: json['isLimited'] ?? false,
    remainingQuantity: json['remainingQuantity'] ?? 0,
    isActive: json['isActive'] ?? true,
  );
}

class RewardTransaction {
  final String id;
  final String rewardId;
  final String rewardTitle;
  final int pointsUsed;
  final DateTime redeemedAt;
  final String status; // pending, completed, expired, cancelled
  final String? redemptionCode;
  final String? notes;
  final DateTime? usedAt;

  RewardTransaction({
    required this.id,
    required this.rewardId,
    required this.rewardTitle,
    required this.pointsUsed,
    required this.redeemedAt,
    required this.status,
    this.redemptionCode,
    this.notes,
    this.usedAt,
  });

  bool get isUsed => status == 'completed';

  bool get isPending => status == 'pending';

  bool get isExpired => status == 'expired';

  Map<String, dynamic> toJson() => {
    'id': id,
    'rewardId': rewardId,
    'rewardTitle': rewardTitle,
    'pointsUsed': pointsUsed,
    'redeemedAt': redeemedAt.toIso8601String(),
    'status': status,
    'redemptionCode': redemptionCode,
    'notes': notes,
    'usedAt': usedAt?.toIso8601String(),
  };

  factory RewardTransaction.fromJson(Map<String, dynamic> json) => RewardTransaction(
    id: json['id'],
    rewardId: json['rewardId'],
    rewardTitle: json['rewardTitle'],
    pointsUsed: json['pointsUsed'],
    redeemedAt: DateTime.parse(json['redeemedAt']),
    status: json['status'],
    redemptionCode: json['redemptionCode'],
    notes: json['notes'],
    usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt']) : null,
  );
}

class PointsBalance {
  final int totalPoints;
  final int earnedPoints;
  final int spentPoints;
  final int availablePoints;
  final DateTime lastUpdated;

  PointsBalance({required this.totalPoints, required this.earnedPoints, required this.spentPoints, required this.availablePoints, required this.lastUpdated});

  Map<String, dynamic> toJson() => {
    'totalPoints': totalPoints,
    'earnedPoints': earnedPoints,
    'spentPoints': spentPoints,
    'availablePoints': availablePoints,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory PointsBalance.fromJson(Map<String, dynamic> json) => PointsBalance(
    totalPoints: json['totalPoints'],
    earnedPoints: json['earnedPoints'],
    spentPoints: json['spentPoints'],
    availablePoints: json['availablePoints'],
    lastUpdated: DateTime.parse(json['lastUpdated']),
  );
}
