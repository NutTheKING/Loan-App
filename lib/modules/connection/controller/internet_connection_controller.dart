import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetConnectionController extends GetxController {
  final isConnected = true.obs;

  late StreamSubscription connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _checkConnection();

    connectivitySubscription = Connectivity().onConnectivityChanged.listen((_) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    try {
      // Check internet using DNS lookup
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 2));

      isConnected.value = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      isConnected.value = false;
    }
  }

  @override
  void onClose() {
    connectivitySubscription.cancel();
    super.onClose();
  }
}
