import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:loan_app/firebase_options.dart';
import 'package:loan_app/routers/app_router.dart';
import 'package:loan_app/themes/app_theme.dart';
import 'package:loan_app/utils/local_storage.dart';
import 'package:loan_app/utils/service/android_notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalStorage.init();
  await _handleInitialMessage();
  await AndroidNotificationHelper.instance.init();

  await dotenv.load();
  _setupDevicePreference();
  runApp(const MyApp());
}

Future<void> _handleInitialMessage() async {
  final RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
  String? payload = message?.data['payload'];
  debugPrint('Notification 1');
  if (payload != null) {
    appRouter.go(payload);
    // adminRouter.
  }
}

void _setupDevicePreference() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(systemNavigationBarIconBrightness: Brightness.dark),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

final GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey<ScaffoldMessengerState>();

final GlobalKey<OverlayState> overlayState = GlobalKey<OverlayState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationProvider: appRouter.routeInformationProvider,
      routeInformationParser: appRouter.routeInformationParser,
      routerDelegate: appRouter.routerDelegate,
      theme: theme(),
    );
  }
}
