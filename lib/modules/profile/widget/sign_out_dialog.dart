import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/profile/controller/profile_controller.dart';

Future<void> confirmSignOut(
  BuildContext context,
  ProfileController controller,
) async {
  if (controller.isSigningOut.value) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.logout_rounded),
      title: const Text('Sign out?'),
      content: const Text(
        'You will need your email and password to access this account again.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Stay signed in'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Sign out'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  await controller.signOut();
  if (!context.mounted) return;

  context.go('/login');
  if (Get.isRegistered<ProfileController>()) {
    Get.delete<ProfileController>(force: true);
  }
}
