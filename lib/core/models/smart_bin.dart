import 'enums.dart';

/// Represents a physical EcoSynapse smart waste bin
class SmartBin {
  final String id;
  final String communityId;
  final String location;
  final BinStatus status;
  
  /// Percentage fill level for each waste category (0-100)
  final Map<WasteCategory, int> fillLevels;
  
  /// Timestamp of the last successful collection
  final DateTime? lastCollection;

  SmartBin({
    required this.id,
    required this.communityId,
    required this.location,
    required this.status,
    required this.fillLevels,
    this.lastCollection,
  });

  SmartBin copyWith({
    String? id,
    String? communityId,
    String? location,
    BinStatus? status,
    Map<WasteCategory, int>? fillLevels,
    DateTime? lastCollection,
  }) {
    return SmartBin(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      location: location ?? this.location,
      status: status ?? this.status,
      fillLevels: fillLevels ?? this.fillLevels,
      lastCollection: lastCollection ?? this.lastCollection,
    );
  }

  factory SmartBin.fromJson(Map<String, dynamic> json) {
    return SmartBin(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      location: json['location'] as String,
      status: BinStatus.values.firstWhere((e) => e.name == json['status']),
      fillLevels: (json['fillLevels'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          WasteCategory.values.firstWhere((e) => e.name == key),
          value as int,
        ),
      ),
      lastCollection: json['lastCollection'] != null
          ? DateTime.parse(json['lastCollection'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communityId': communityId,
      'location': location,
      'status': status.name,
      'fillLevels': fillLevels.map((key, value) => MapEntry(key.name, value)),
      'lastCollection': lastCollection?.toIso8601String(),
    };
  }

  /// True if any compartment is over 90% full
  bool get isFull => fillLevels.values.any((level) => level >= 90);

  /// Returns the highest fill percentage across all compartments
  int get maxFillLevel => fillLevels.values.isEmpty 
      ? 0 
      : fillLevels.values.reduce((a, b) => a > b ? a : b);
}
