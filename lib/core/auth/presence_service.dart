import 'dart:async';

import 'package:loan_app/core/network/api_client.dart';

class PresenceService {
  PresenceService._();

  static final PresenceService instance = PresenceService._();

  Timer? _timer;

  void start() {
    _timer?.cancel();
    unawaited(_ping());
    _timer = Timer.periodic(
      const Duration(seconds: 45),
      (_) => unawaited(_ping()),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _ping() async {
    try {
      await ApiClient.instance.post('/auth/presence');
    } catch (_) {
      // Presence is best-effort and must never interrupt app usage.
    }
  }
}
