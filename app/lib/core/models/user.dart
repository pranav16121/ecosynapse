import 'enums.dart';

/// Represents any actor within the EcoSynapse ecosystem
class User {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String communityId;

  /// Unique resident identifier for community display (e.g., "RES-2026-042")
  final String? residentId;

  /// Date when the user joined the ecosystem
  final DateTime? joinedDate;

  /// List of badge IDs or names earned by the user
  final List<String> badges;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.communityId,
    this.residentId,
    this.joinedDate,
    this.badges = const [],
  });

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    UserRole? role,
    String? communityId,
    String? residentId,
    DateTime? joinedDate,
    List<String>? badges,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      communityId: communityId ?? this.communityId,
      residentId: residentId ?? this.residentId,
      joinedDate: joinedDate ?? this.joinedDate,
      badges: badges ?? this.badges,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      communityId: json['communityId'] as String,
      residentId: json['residentId'] as String?,
      joinedDate: json['joinedDate'] != null
          ? DateTime.parse(json['joinedDate'] as String)
          : null,
      badges:
          (json['badges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Converts a Supabase database row from `public.users` into a [User] model
  factory User.fromSupabase(Map<String, dynamic> json, {String? authEmail}) {
    final rawRole = (json['user_type'] ?? json['role'] ?? 'resident').toString().toLowerCase();
    final role = UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == rawRole,
      orElse: () => UserRole.resident,
    );

    return User(
      id: json['id']?.toString() ?? '',
      fullName: json['name']?.toString() ?? json['fullName']?.toString() ?? 'User',
      email: json['email']?.toString() ?? authEmail ?? '',
      role: role,
      communityId: json['community_id']?.toString() ?? json['communityId']?.toString() ?? '1',
      residentId: json['flat_no']?.toString() ?? json['residentId']?.toString(),
      joinedDate: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      badges: (json['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role.name,
      'communityId': communityId,
      'residentId': residentId,
      'joinedDate': joinedDate?.toIso8601String(),
      'badges': badges,
    };
  }
}

/// Represents a residential or facility community
class Community {
  final String id;
  final String name;
  final String location;

  /// Number of residents currently active in this community
  final int? activeResidentsCount;

  Community({
    required this.id,
    required this.name,
    required this.location,
    this.activeResidentsCount,
  });

  Community copyWith({
    String? id,
    String? name,
    String? location,
    int? activeResidentsCount,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      activeResidentsCount: activeResidentsCount ?? this.activeResidentsCount,
    );
  }

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      activeResidentsCount: json['activeResidentsCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'activeResidentsCount': activeResidentsCount,
    };
  }

  /// Combined display name for community identification
  String get displayName => '$name, $location';
}
