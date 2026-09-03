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

  /// Converts a Supabase database row from `public.bins` into a [SmartBin] model
  factory SmartBin.fromSupabase(Map<String, dynamic> json) {
    final bool isOnline = json['is_online'] as bool? ?? true;
    final int overallFill = (json['overall_fill'] as num? ?? 0).toInt();
    final int dryFill = (json['dry_fill'] as num? ?? 0).toInt();
    final int wetFill = (json['wet_fill'] as num? ?? 0).toInt();

    BinStatus status;
    if (!isOnline) {
      status = BinStatus.offline;
    } else if (overallFill >= 90 || dryFill >= 90 || wetFill >= 90) {
      status = BinStatus.full;
    } else if (overallFill >= 75 || dryFill >= 75 || wetFill >= 75) {
      status = BinStatus.collectionSoon;
    } else {
      status = BinStatus.online;
    }

    return SmartBin(
      id: json['id']?.toString() ?? '',
      communityId: json['community_id']?.toString() ?? json['communityId']?.toString() ?? '1',
      location: json['location']?.toString() ?? json['name']?.toString() ?? 'Unknown Location',
      status: status,
      fillLevels: {
        WasteCategory.dry: dryFill,
        WasteCategory.wet: wetFill,
        WasteCategory.recyclable: overallFill,
      },
      lastCollection: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'].toString())
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
