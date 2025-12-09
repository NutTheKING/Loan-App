import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:loan_app/firebase_options.dart';
import 'package:loan_app/modules/connection/controller/internet_connection_controller.dart';
import 'package:loan_app/modules/connection/screen/no_internet_page.dart';
import 'package:loan_app/modules/connection/services/connectivity_wrapper.dart';
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
  Get.put(InternetConnectionController());
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
    final connection = Get.find<InternetConnectionController>();

    return Obx(() {
      if (!connection.isConnected.value) {
        return MaterialApp(debugShowCheckedModeBanner: false, home: NoInternetPage());
      }

      return GestureDetector(
        onTap: () => unFocus(context),
        child: GetMaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: theme(),
          routeInformationProvider: appRouter.routeInformationProvider,
          routeInformationParser: appRouter.routeInformationParser,
          routerDelegate: appRouter.routerDelegate,
        ),
      );
    });
    // return ConnectivityWrapper(
    //   child: GetMaterialApp.router(
    //     debugShowCheckedModeBanner: false,
    //     routeInformationProvider: appRouter.routeInformationProvider,
    //     routeInformationParser: appRouter.routeInformationParser,
    //     routerDelegate: appRouter.routerDelegate,
    //     theme: theme(),
    //   ),
    // );
  }
}

void unFocus(BuildContext context) {
  final FocusScopeNode currentFocus = FocusScope.of(context);
  // if (!currentFocus.hasPrimaryFocus) {
  //   currentFocus.unfocus();
  // }
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    FocusManager.instance.primaryFocus!.unfocus();
  }
}
