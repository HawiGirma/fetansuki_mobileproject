import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:fetansuki_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:fetansuki_app/features/settings/presentation/widgets/profile_card.dart';
import 'package:fetansuki_app/features/settings/presentation/widgets/profile_header.dart';
import 'package:fetansuki_app/features/settings/presentation/widgets/settings_list.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsDataAsync = ref.watch(settingsDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF), 
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(settingsDataProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const ProfileHeader(),
                
                settingsDataAsync.when(
                  data: (data) => Column(
                    children: [
                      const SizedBox(height: 20),
                      ProfileCard(profile: data.profile),
                      const SizedBox(height: 40),
                      SettingsList(
                        options: data.options,
                        onOptionTap: (option) {
                          if (option.label == 'Log Out') {
                            ref.read(authNotifierProvider.notifier).logout();
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                  loading: () => const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: $error'),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(settingsDataProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}