import 'package:flutter/material.dart';
import 'package:fetansuki_app/features/settings/domain/entities/setting_option.dart';

class SettingsList extends StatelessWidget {
  final List<SettingOption> options;
  final Function(SettingOption) onOptionTap;

  const SettingsList({
    super.key,
    required this.options,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 56),
        itemBuilder: (context, index) {
          final option = options[index];
          return ListTile(
            leading: Icon(
              option.icon,
              color: Colors.black87,
            ),
            title: Text(
              option.label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            trailing: _buildTrailing(option),
            onTap: () => onOptionTap(option),
          );
        },
      ),
    );
  }

  Widget? _buildTrailing(SettingOption option) {
    if (option.value != null) {
      return Text(
        option.value!,
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      );
    }
    return null;
  }
}
