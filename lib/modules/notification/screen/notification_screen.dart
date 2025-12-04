import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/notification/controller/notification_controller.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController nc = Get.put(NotificationController());
    return Scaffold(
      appBar: AppBar(title: Text('notifications'.tr)),
      body: Obx(
        () => ListView.builder(
          itemCount: nc.messages.length,
          itemBuilder: (context, i) {
            final msg = nc.messages[i];
            return ListTile(
              title: Text(msg.notification?.title ?? 'No title'),
              subtitle: Text(msg.notification?.body ?? 'No body'),
            );
          },
        ),
      ),
    );
  }
}
