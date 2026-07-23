import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/notification/controller/notification_controller.dart';
import 'package:loan_app/modules/notification/widget/customer_notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notiController = Get.put(NotificationController());
  @override
  void initState() {
    _notiController.fetchAllNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _notiController.markAllRead,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: Obx(
        () => _notiController.getNotificationLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _notiController.fetchAllNotifications,
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ).copyWith(bottom: 30),
                  itemCount: _notiController.listNotification.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final notification =
                        _notiController.listNotification[index];
                    return CustomNotification(
                      notificationModel: notification,
                      onTap: () =>
                          _notiController.openNotification(notification),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
