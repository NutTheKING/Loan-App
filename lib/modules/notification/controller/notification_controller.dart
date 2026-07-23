import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/core/network/api_client.dart';
import 'package:loan_app/core/network/api_exception.dart';
import 'package:loan_app/modules/notification/model/notification_model.dart';
import 'package:loan_app/routers/app_router.dart';

class NotificationController extends GetxController {
  NotificationController({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  final ApiClient _client;
  final listNotification = <NotificationModel>[].obs;
  final getNotificationLoading = false.obs;
  final unreadCount = 0.obs;
  final _seenIds = <String>{};
  Timer? _pollTimer;
  bool _loadedOnce = false;

  @override
  void onInit() {
    super.onInit();
    fetchAllNotifications();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => fetchAllNotifications(showAlert: true),
    );
  }

  Future<List<NotificationModel>> fetchAllNotifications({
    bool showAlert = false,
  }) async {
    if (getNotificationLoading.value) {
      return listNotification;
    }
    getNotificationLoading(true);
    try {
      final value = await _client.get('/notifications');
      final notifications = (value['notifications'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                NotificationModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
      if (_loadedOnce && showAlert) {
        final newItems = notifications.where(
          (notification) =>
              notification.id != null &&
              notification.readAt == null &&
              !_seenIds.contains(notification.id),
        );
        for (final notification in newItems.take(2)) {
          Get.snackbar(
            notification.title ?? 'Loan update',
            notification.body ?? '',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF101828),
            colorText: Colors.white,
            onTap: (_) => openNotification(notification),
          );
        }
      }
      listNotification.assignAll(notifications);
      unreadCount.value =
          (value['unreadCount'] as num?)?.toInt() ??
          notifications
              .where((notification) => notification.readAt == null)
              .length;
      _seenIds.addAll(
        notifications
            .map((notification) => notification.id)
            .whereType<String>(),
      );
      _loadedOnce = true;
      return notifications;
    } on ApiException {
      return listNotification;
    } finally {
      getNotificationLoading(false);
    }
  }

  Future<void> openNotification(NotificationModel notification) async {
    if (notification.id != null && notification.readAt == null) {
      await _client.patchEmpty('/notifications/${notification.id}/read');
      notification.readAt = DateTime.now().toIso8601String();
      unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
      listNotification.refresh();
    }
    final payload = notification.payload;
    if (payload != null && payload.isNotEmpty) {
      appRouter.go(payload);
    }
  }

  Future<void> markAllRead() async {
    await _client.patchEmpty('/notifications/read-all');
    final readAt = DateTime.now().toIso8601String();
    for (final notification in listNotification) {
      notification.readAt ??= readAt;
    }
    unreadCount.value = 0;
    listNotification.refresh();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }
}
