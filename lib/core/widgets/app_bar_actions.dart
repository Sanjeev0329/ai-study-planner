import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../utils/auth_actions.dart';

class AppBarMenuButton extends ConsumerWidget {
  const AppBarMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      color: AppColors.bgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'logout') AuthActions.logout(context, ref);
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: AppColors.hard),
              SizedBox(width: 12),
              Text('Log out'),
            ],
          ),
        ),
      ],
    );
  }
}
