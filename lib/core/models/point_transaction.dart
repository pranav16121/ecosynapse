import 'enums.dart';

/// Represents a single ledger entry in the EcoPoints economy
class PointTransaction {
  final String id;
  final String userId;
  
  /// Amount of points (Positive for earned, negative for spent)
  final int amount;
  
  /// Precise timestamp of the transaction
  final DateTime timestamp;
  
  /// Human-readable label for the transaction (e.g., "Recycling Bonus")
  final String description;
  
  final TransactionType type;
  
  /// ID of the associated entity (e.g., WasteEvent ID, Reward ID, Challenge ID)
  final String? referenceId;
  
  /// Extensible storage for transaction context
  final Map<String, dynamic> metadata;

  PointTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.timestamp,
    required this.description,
    required this.type,
    this.referenceId,
    this.metadata = const {},
  });

  PointTransaction copyWith({
    String? id,
    String? userId,
    int? amount,
    DateTime? timestamp,
    String? description,
    TransactionType? type,
    String? referenceId,
    Map<String, dynamic>? metadata,
  }) {
    return PointTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      metadata: metadata ?? this.metadata,
    );
  }

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: json['amount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      referenceId: json['referenceId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'type': type.name,
      'referenceId': referenceId,
      'metadata': metadata,
    };
  }

  /// True if points were added to the balance
  bool get isEarned => amount > 0;
  
  /// True if points were deducted from the balance
  bool get isSpent => amount < 0;
}
