import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/connection/controller/internet_connection_controller.dart';
import 'package:loan_app/modules/connection/screen/no_internet_page.dart';
import 'package:loan_app/routers/app_router.dart';

class AppRouterWrapper extends StatelessWidget {
  AppRouterWrapper({super.key});

  final connection = Get.find<InternetConnectionController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!connection.isConnected.value) {
        return const NoInternetPage();
      }

      return MaterialApp.router(routerConfig: appRouter);
    });
  }
}

//
