import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fetansuki_app/features/notifications/data/repositories/notification_repository.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'FetanSuki',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1), // Dark blue
            ),
          ),
          Row(
            children: [
              notificationsAsync.when(
                data: (notifications) {
                  final notificationCount = notifications.length;
                  return IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: notificationCount > 0
                        ? Badge(
                            label: Text('$notificationCount'),
                            child: const Icon(Icons.notifications_outlined),
                          )
                        : const Icon(Icons.notifications_outlined),
                    color: const Color(0xFF0F3C7E),
                  );
                },
                loading: () => IconButton(
                  onPressed: () => context.push('/notifications'),
                  icon: const Icon(Icons.notifications_outlined),
                  color: const Color(0xFF0F3C7E),
                ),
                error: (_, __) => IconButton(
                  onPressed: () => context.push('/notifications'),
                  icon: const Icon(Icons.notifications_outlined),
                  color: const Color(0xFF0F3C7E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
