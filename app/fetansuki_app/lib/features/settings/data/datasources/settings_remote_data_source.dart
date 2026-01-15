import 'package:firebase_auth/firebase_auth.dart';
import 'package:fetansuki_app/features/settings/data/datasources/settings_data_source.dart';
import 'package:fetansuki_app/features/settings/domain/entities/settings_data.dart';
import 'package:fetansuki_app/features/settings/domain/entities/user_profile.dart';
import 'package:fetansuki_app/features/settings/domain/entities/setting_option.dart';
import 'package:flutter/material.dart';

class SettingsRemoteDataSource implements SettingsDataSource {
  final FirebaseAuth _firebaseAuth;

  SettingsRemoteDataSource({required FirebaseAuth firebaseAuth}) : _firebaseAuth = firebaseAuth;

  @override
  Future<SettingsData> getSettingsData() async {
    final user = _firebaseAuth.currentUser;
    
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Format joined date: "Joined Jan 25, 2025" or similar
    final creationTime = user.metadata.creationTime ?? DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final joinedDate = 'Joined ${months[creationTime.month - 1]} ${creationTime.day}, ${creationTime.year}';

    return SettingsData(
      profile: UserProfile(
        name: user.displayName ?? 'User',
        joinedDate: joinedDate,
        email: user.email ?? 'No email',
        profileImageUrl: user.photoURL,
      ),
      options: [
        const SettingOption(
          id: '1',
          label: 'Notifications',
          icon: Icons.notifications_none,
          value: 'On',
          type: SettingType.toggle,
        ),
        const SettingOption(
          id: '2',
          label: 'Language',
          icon: Icons.translate,
          value: 'English',
          type: SettingType.navigation,
        ),
        const SettingOption(
          id: '3',
          label: 'Log Out',
          icon: Icons.logout,
          type: SettingType.action,
        ),
      ],
    );
  }
}
