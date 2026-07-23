import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loan_app/routers/app_router.dart';

const _notificationIcon = '@mipmap/ic_launcher';

class AndroidNotificationHelper {
  AndroidNotificationHelper._();
  static final instance = AndroidNotificationHelper._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ///ID for All Notification (Unique)
  int _id = 0;

  ///Android Notificaion Icon Setup
  final AndroidInitializationSettings _initializationSettingsAndroid =
      const AndroidInitializationSettings(_notificationIcon);

  Future<void> init() async {
    await _requestNotificationPermission();
    await _initLocalNotificationSetting();
  }

  Future<void> _initLocalNotificationSetting() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(android: _initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        String? payload = details.payload;
        debugPrint('Notification $payload');
        if (payload != null && payload.isNotEmpty) {
          appRouter.go(payload);
          // adminRouter.
        }
      },
    );
  }

  Future<NotificationSettings> _requestNotificationPermission() async {
    return await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  ///Show local notification
  Future<void> showNotification(
    String? title,
    String? body, {
    String? payload,
  }) async {
    _id++;

    NotificationDetails androidNotificationDetail = const NotificationDetails(
      android: AndroidNotificationDetails(
        'android_notification_plugin',
        'channel_name',
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,

        // icon: '',
        // color: Color(0xff4B250F),
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      _id,
      title,
      body,
      androidNotificationDetail,
      payload: payload,
    );
  }
}
