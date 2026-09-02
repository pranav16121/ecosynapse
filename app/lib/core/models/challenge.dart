import 'enums.dart';

/// Represents a sustainability challenge for the community
class Challenge {
  final String id;
  final String title;
  final String description;
  final int rewardPoints;
  final DateTime deadline;
  final ChallengeType type;

  /// Target value to complete the challenge (e.g., 5.0 kg of waste reduction)
  final double? goalValue;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardPoints,
    required this.deadline,
    required this.type,
    this.goalValue,
  });

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    int? rewardPoints,
    DateTime? deadline,
    ChallengeType? type,
    double? goalValue,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      deadline: deadline ?? this.deadline,
      type: type ?? this.type,
      goalValue: goalValue ?? this.goalValue,
    );
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      rewardPoints: json['rewardPoints'] as int,
      deadline: DateTime.parse(json['deadline'] as String),
      type: ChallengeType.values.firstWhere((e) => e.name == json['type']),
      goalValue: (json['goalValue'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rewardPoints': rewardPoints,
      'deadline': deadline.toIso8601String(),
      'type': type.name,
      'goalValue': goalValue,
    };
  }
}

/// Tracks a user's participation and progress in a specific challenge
class ChallengeParticipation {
  final String id;
  final String challengeId;
  final String userId;

  /// Current progress towards the challenge goal (0.0 to 1.0)
  final double currentProgress;

  final ChallengeStatus status;

  ChallengeParticipation({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.currentProgress,
    required this.status,
  });

  ChallengeParticipation copyWith({
    String? id,
    String? challengeId,
    String? userId,
    double? currentProgress,
    ChallengeStatus? status,
  }) {
    return ChallengeParticipation(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      userId: userId ?? this.userId,
      currentProgress: currentProgress ?? this.currentProgress,
      status: status ?? this.status,
    );
  }

  factory ChallengeParticipation.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipation(
      id: json['id'] as String,
      challengeId: json['challengeId'] as String,
      userId: json['userId'] as String,
      currentProgress: (json['currentProgress'] as num).toDouble(),
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challengeId': challengeId,
      'userId': userId,
      'currentProgress': currentProgress,
      'status': status.name,
    };
  }
}
