import 'package:loan_app/core/auth/auth_session.dart';
import 'package:loan_app/core/auth/presence_service.dart';
import 'package:loan_app/core/network/api_client.dart';
import 'package:loan_app/core/notifications/push_notification_service.dart';
import 'package:loan_app/utils/local_storage.dart';

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return _storeSession(AuthSession.fromJson(response));
  }

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
    required String idNumber,
  }) async {
    final response = await _client.post(
      '/auth/register',
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'idNumber': idNumber,
      },
    );
    return _storeSession(AuthSession.fromJson(response));
  }

  Future<void> signOut() async {
    PresenceService.instance.stop();
    await PushNotificationService.instance.unregisterDevice();
    final refreshToken = await LocalStorage.getStringValue(
      key: LocalStorage.refreshTokenKey,
    );
    if (refreshToken.isNotEmpty) {
      try {
        await _client.postEmpty(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } catch (_) {
        // Local credentials are cleared even when a device is offline.
      }
    }
    await LocalStorage.clearSession();
  }

  Future<bool> hasSession() async {
    return (await LocalStorage.getStringValue(
      key: LocalStorage.accessTokenKey,
    )).isNotEmpty;
  }

  Future<AuthUser?> currentUser() async {
    if (!await hasSession()) {
      return null;
    }

    try {
      final response = await _client.get('/auth/me');
      final user = AuthUser.fromJson(
        Map<String, dynamic>.from(response['user'] as Map),
      );
      await _storeUser(user);
      PresenceService.instance.start();
      return user;
    } catch (_) {
      await LocalStorage.clearSession();
      return null;
    }
  }

  Future<AuthSession> _storeSession(AuthSession session) async {
    await LocalStorage.storeData(
      key: LocalStorage.accessTokenKey,
      value: session.accessToken,
    );
    await LocalStorage.storeData(
      key: LocalStorage.refreshTokenKey,
      value: session.refreshToken,
    );
    await _storeUser(session.user);
    await PushNotificationService.instance.registerDevice();
    PresenceService.instance.start();
    return session;
  }

  Future<void> _storeUser(AuthUser user) async {
    await Future.wait([
      LocalStorage.storeData(
        key: LocalStorage.userNameKey,
        value: user.fullName,
      ),
      LocalStorage.storeData(key: LocalStorage.userEmailKey, value: user.email),
      LocalStorage.storeData(key: LocalStorage.userRoleKey, value: user.role),
      LocalStorage.storeListStringValue(
        key: LocalStorage.userPermissionsKey,
        value: user.permissions,
      ),
    ]);
  }
}
