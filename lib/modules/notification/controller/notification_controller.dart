import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationController extends GetxController {
  var messages = <RemoteMessage>[].obs;
  var deviceToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initFCM();
  }

  Future<void> initFCM() async {
    // Get token
    final token = await FirebaseMessaging.instance.getToken();
    deviceToken.value = token ?? '';

    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      messages.add(message);
    });

    // Background/terminated handled by firebase_messaging in native layers
  }
}
