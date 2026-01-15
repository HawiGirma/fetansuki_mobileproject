class UserProfile {
  final String name;
  final String joinedDate;
  final String email;
  final String? profileImageUrl;

  const UserProfile({
    required this.name,
    required this.joinedDate,
    required this.email,
    this.profileImageUrl,
  });
}
