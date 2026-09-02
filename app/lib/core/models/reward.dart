import 'enums.dart';

/// Represents an item in the EcoPoints reward catalog
class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String category;

  /// Identifier for the UI icon (e.g., "coffee", "shopping_basket")
  final String icon;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.category,
    required this.icon,
  });

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    int? pointsCost,
    String? category,
    String? icon,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsCost: pointsCost ?? this.pointsCost,
      category: category ?? this.category,
      icon: icon ?? this.icon,
    );
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pointsCost: json['pointsCost'] as int,
      category: json['category'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsCost': pointsCost,
      'category': category,
      'icon': icon,
    };
  }
}

/// Record of a reward redemption by a specific user
class RewardRedemption {
  final String id;
  final String rewardId;
  final String userId;

  /// Unique voucher or claim code generated upon redemption
  final String redemptionCode;

  final DateTime timestamp;
  final RewardStatus status;

  RewardRedemption({
    required this.id,
    required this.rewardId,
    required this.userId,
    required this.redemptionCode,
    required this.timestamp,
    required this.status,
  });

  RewardRedemption copyWith({
    String? id,
    String? rewardId,
    String? userId,
    String? redemptionCode,
    DateTime? timestamp,
    RewardStatus? status,
  }) {
    return RewardRedemption(
      id: id ?? this.id,
      rewardId: rewardId ?? this.rewardId,
      userId: userId ?? this.userId,
      redemptionCode: redemptionCode ?? this.redemptionCode,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  factory RewardRedemption.fromJson(Map<String, dynamic> json) {
    return RewardRedemption(
      id: json['id'] as String,
      rewardId: json['rewardId'] as String,
      userId: json['userId'] as String,
      redemptionCode: json['redemptionCode'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: RewardStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rewardId': rewardId,
      'userId': userId,
      'redemptionCode': redemptionCode,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
    };
  }
}
