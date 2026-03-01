class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    this.provider,
  });

  final String id;
  final String name;
  final String? provider;

  UserProfile copyWith({
    String? id,
    String? name,
    String? provider,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
    );
  }
}
