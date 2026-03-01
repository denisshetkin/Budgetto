class FamilyGroup {
  const FamilyGroup({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.inviteCode,
  });

  final String id;
  final String name;
  final List<String> memberIds;
  final String inviteCode;

  FamilyGroup copyWith({
    String? id,
    String? name,
    List<String>? memberIds,
    String? inviteCode,
  }) {
    return FamilyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      memberIds: memberIds ?? this.memberIds,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}
