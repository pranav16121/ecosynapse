import 'enums.dart';

/// Request for a waste collection, typically triggered when a bin is full
class CollectionRequest {
  final String id;
  final String binId;
  final String communityId;
  final CollectionStatus status;
  
  /// Priority level (e.g., 1 for Low, 5 for Critical/Full)
  final int priority;
  
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? completedAt;

  CollectionRequest({
    required this.id,
    required this.binId,
    required this.communityId,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.scheduledAt,
    this.completedAt,
  });

  CollectionRequest copyWith({
    String? id,
    String? binId,
    String? communityId,
    CollectionStatus? status,
    int? priority,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? completedAt,
  }) {
    return CollectionRequest(
      id: id ?? this.id,
      binId: binId ?? this.binId,
      communityId: communityId ?? this.communityId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory CollectionRequest.fromJson(Map<String, dynamic> json) {
    return CollectionRequest(
      id: json['id'] as String,
      binId: json['binId'] as String,
      communityId: json['communityId'] as String,
      status: CollectionStatus.values.firstWhere((e) => e.name == json['status']),
      priority: json['priority'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledAt: json['scheduledAt'] != null 
          ? DateTime.parse(json['scheduledAt'] as String) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'binId': binId,
      'communityId': communityId,
      'status': status.name,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

/// Record of a completed waste collection event
class CollectionEvent {
  final String id;
  final String requestId;
  final String collectorId;
  
  /// Total weight of waste collected in this event
  final double totalWeightKg;
  
  final DateTime timestamp;

  CollectionEvent({
    required this.id,
    required this.requestId,
    required this.collectorId,
    required this.totalWeightKg,
    required this.timestamp,
  });

  CollectionEvent copyWith({
    String? id,
    String? requestId,
    String? collectorId,
    double? totalWeightKg,
    DateTime? timestamp,
  }) {
    return CollectionEvent(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      collectorId: collectorId ?? this.collectorId,
      totalWeightKg: totalWeightKg ?? this.totalWeightKg,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory CollectionEvent.fromJson(Map<String, dynamic> json) {
    return CollectionEvent(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      collectorId: json['collectorId'] as String,
      totalWeightKg: (json['totalWeightKg'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'collectorId': collectorId,
      'totalWeightKg': totalWeightKg,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
