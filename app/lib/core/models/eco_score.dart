/// Encapsulates the multi-dimensional sustainability metric for a user or community
class EcoScore {
  /// Calculated aggregate score (0 to 100)
  final int overallScore;

  /// Percentage of correctly segregated items (0.0 to 1.0)
  final double segregationAccuracy;

  /// Percentage of recyclable waste actually recycled (0.0 to 1.0)
  final double recyclingRate;

  /// Percentage of waste weight reduced compared to the baseline (0.0 to 1.0)
  final double wasteReduction;

  /// Net change in the score compared to the previous month
  final int monthlyChange;

  EcoScore({
    required this.overallScore,
    required this.segregationAccuracy,
    required this.recyclingRate,
    required this.wasteReduction,
    required this.monthlyChange,
  });

  EcoScore copyWith({
    int? overallScore,
    double? segregationAccuracy,
    double? recyclingRate,
    double? wasteReduction,
    int? monthlyChange,
  }) {
    return EcoScore(
      overallScore: overallScore ?? this.overallScore,
      segregationAccuracy: segregationAccuracy ?? this.segregationAccuracy,
      recyclingRate: recyclingRate ?? this.recyclingRate,
      wasteReduction: wasteReduction ?? this.wasteReduction,
      monthlyChange: monthlyChange ?? this.monthlyChange,
    );
  }

  factory EcoScore.fromJson(Map<String, dynamic> json) {
    return EcoScore(
      overallScore: json['overallScore'] as int,
      segregationAccuracy: (json['segregationAccuracy'] as num).toDouble(),
      recyclingRate: (json['recyclingRate'] as num).toDouble(),
      wasteReduction: (json['wasteReduction'] as num).toDouble(),
      monthlyChange: json['monthlyChange'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallScore': overallScore,
      'segregationAccuracy': segregationAccuracy,
      'recyclingRate': recyclingRate,
      'wasteReduction': wasteReduction,
      'monthlyChange': monthlyChange,
    };
  }

  /// Human-readable rating based on the overall score
  String get rating {
    if (overallScore >= 80) return 'Excellent';
    if (overallScore >= 60) return 'Good';
    if (overallScore >= 40) return 'Fair';
    return 'Needs Improvement';
  }
}
