import 'package:flutter/material.dart';
import 'package:loan_app/modules/notification/model/notification_model.dart';

class CustomNotification extends StatelessWidget {
  const CustomNotification({
    super.key,
    required this.notificationModel,
    required this.onTap,
  });

  final NotificationModel notificationModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final unread = notificationModel.readAt == null;
    return Material(
      color: unread
          ? colors.primaryContainer.withValues(alpha: .45)
          : colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                child: const Icon(Icons.notifications_active_outlined),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notificationModel.title ?? 'Loan update',
                      style: TextStyle(
                        fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(notificationModel.body ?? ''),
                  ],
                ),
              ),
              if (unread)
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: colors.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
