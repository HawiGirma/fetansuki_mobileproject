import 'package:fetansuki_app/features/settings/domain/entities/setting_option.dart';
import 'package:fetansuki_app/features/settings/domain/entities/user_profile.dart';

class SettingsData {
  final UserProfile profile;
  final List<SettingOption> options;

  const SettingsData({
    required this.profile,
    required this.options,
  });
}
