import 'enums.dart';

/// Represents a recycling facility or partner
class Recycler {
  final String id;
  final String name;

  /// Type of materials processed (e.g., "Plastic", "Organic")
  final String type;

  final String location;

  Recycler({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
  });

  Recycler copyWith({
    String? id,
    String? name,
    String? type,
    String? location,
  }) {
    return Recycler(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
    );
  }

  factory Recycler.fromJson(Map<String, dynamic> json) {
    return Recycler(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'type': type, 'location': location};
  }
}

/// Record of a specific batch of material processed by a recycler
class RecyclingBatch {
  final String id;
  final String recyclerId;
  final WasteCategory category;
  final double weightKg;

  /// Quality or purity level of the batch (0 to 100)
  final int purityPercent;

  final DateTime timestamp;

  RecyclingBatch({
    required this.id,
    required this.recyclerId,
    required this.category,
    required this.weightKg,
    required this.purityPercent,
    required this.timestamp,
  });

  RecyclingBatch copyWith({
    String? id,
    String? recyclerId,
    WasteCategory? category,
    double? weightKg,
    int? purityPercent,
    DateTime? timestamp,
  }) {
    return RecyclingBatch(
      id: id ?? this.id,
      recyclerId: recyclerId ?? this.recyclerId,
      category: category ?? this.category,
      weightKg: weightKg ?? this.weightKg,
      purityPercent: purityPercent ?? this.purityPercent,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory RecyclingBatch.fromJson(Map<String, dynamic> json) {
    return RecyclingBatch(
      id: json['id'] as String,
      recyclerId: json['recyclerId'] as String,
      category: WasteCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      weightKg: (json['weightKg'] as num).toDouble(),
      purityPercent: json['purityPercent'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recyclerId': recyclerId,
      'category': category.name,
      'weightKg': weightKg,
      'purityPercent': purityPercent,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
