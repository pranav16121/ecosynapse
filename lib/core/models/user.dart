enum UserRole { resident, admin, collector, recycler }

class User {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String communityId;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.communityId,
  });
}

class Community {
  final String id;
  final String name;
  final String location;

  Community({required this.id, required this.name, required this.location});
}
