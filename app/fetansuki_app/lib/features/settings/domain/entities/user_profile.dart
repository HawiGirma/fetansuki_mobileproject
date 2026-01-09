class UserProfile {
  final String name;
  final String joinedDate;
  final String phoneNumber;
  final String? profileImageUrl;

  const UserProfile({
    required this.name,
    required this.joinedDate,
    required this.phoneNumber,
    this.profileImageUrl,
  });
}
