import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class InternetConnectionController extends GetxController {
  final isConnected = true.obs;
  late final StreamSubscription<List<ConnectivityResult>>
  _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _checkConnection();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionState,
    );
  }

  Future<void> _checkConnection() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    _updateConnectionState(connectivityResults);
  }

  void _updateConnectionState(List<ConnectivityResult> connectivityResults) {
    if (kIsWeb) {
      isConnected.value = true;
      return;
    }

    isConnected.value = !connectivityResults.contains(ConnectivityResult.none);
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
