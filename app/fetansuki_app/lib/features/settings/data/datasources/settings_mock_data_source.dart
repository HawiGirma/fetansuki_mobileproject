import 'package:flutter/material.dart';
import 'package:fetansuki_app/features/settings/data/datasources/settings_data_source.dart';
import 'package:fetansuki_app/features/settings/domain/entities/setting_option.dart';
import 'package:fetansuki_app/features/settings/domain/entities/settings_data.dart';
import 'package:fetansuki_app/features/settings/domain/entities/user_profile.dart';

class SettingsMockDataSource implements SettingsDataSource {
  @override
  Future<SettingsData> getSettingsData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const SettingsData(
      profile: UserProfile(
        name: 'Puerto Rico',
        joinedDate: 'Joined 25,2025',
        phoneNumber: '+251 1234 567 89',
        // In a real app, this would be a URL. For mock, we'll handle icon display in the UI if url is null/empty or use a specific asset.
      ),
      options: [
        SettingOption(
          id: '1',
          label: 'Notifications',
          icon: Icons.notifications_none,
          value: 'On',
          type: SettingType.toggle,
        ),
        SettingOption(
          id: '2',
          label: 'Language',
          icon: Icons.translate,
          value: 'English',
          type: SettingType.navigation,
        ),
        SettingOption(
          id: '3',
          label: 'Log Out',
          icon: Icons.logout,
          type: SettingType.action,
        ),
      ],
    );
  }
}
