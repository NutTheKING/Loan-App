import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:loan_app/core/network/api_client.dart';
import 'package:loan_app/routers/app_router.dart';
import 'package:loan_app/utils/local_storage.dart';
import 'package:loan_app/utils/service/android_notification_helper.dart';

class PushNotificationService {
  PushNotificationService._();

  static final instance = PushNotificationService._();
  static const _webVapidKey = String.fromEnvironment('FIREBASE_WEB_VAPID_KEY');

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  String? _registeredToken;

  Future<void> initialize() async {
    await _messageSubscription?.cancel();
    _messageSubscription = FirebaseMessaging.onMessage.listen((message) async {
      final title = message.notification?.title ?? 'Loan update';
      final body = message.notification?.body ?? '';
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await AndroidNotificationHelper.instance.showNotification(
          title,
          body,
          payload: message.data['payload'],
        );
      } else {
        Get.snackbar(title, body, snackPosition: SnackPosition.TOP);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen(_openMessage);
  }

  Future<void> registerDevice() async {
    try {
      final accessToken = await LocalStorage.getStringValue(
        key: LocalStorage.accessTokenKey,
      );
      if (accessToken.isEmpty) {
        return;
      }
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await _messaging.getToken(
        vapidKey: kIsWeb && _webVapidKey.isNotEmpty ? _webVapidKey : null,
      );
      if (token == null || token.isEmpty) {
        return;
      }
      await _registerToken(token);
      await _tokenSubscription?.cancel();
      _tokenSubscription = _messaging.onTokenRefresh.listen(_registerToken);
    } catch (error) {
      debugPrint('Push notification registration skipped: $error');
    }
  }

  Future<void> unregisterDevice() async {
    final token = _registeredToken;
    if (token == null) {
      return;
    }
    try {
      await ApiClient.instance.postEmpty(
        '/devices/unregister',
        data: {'token': token},
      );
    } catch (_) {
      // Signing out must still succeed while offline.
    }
    _registeredToken = null;
  }

  Future<void> _registerToken(String token) async {
    await ApiClient.instance.post(
      '/devices',
      data: {'token': token, 'platform': _platform},
    );
    _registeredToken = token;
  }

  String get _platform {
    if (kIsWeb) {
      return 'web';
    }
    return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
  }

  void _openMessage(RemoteMessage message) {
    final payload = message.data['payload'];
    if (payload is String && payload.isNotEmpty) {
      appRouter.go(payload);
    }
  }
}
