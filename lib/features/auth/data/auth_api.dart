import 'package:loan_app/core/auth/auth_session.dart';
import 'package:loan_app/core/auth/presence_service.dart';
import 'package:loan_app/core/network/api_client.dart';
import 'package:loan_app/core/network/api_exception.dart';
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
    required String phone,
    required String password,
    required String idNumber,
    required DateTime dateOfBirth,
    required String gender,
    required String address,
    required bool acceptedTerms,
  }) async {
    final response = await _client.post(
      '/auth/register',
      data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'idNumber': idNumber,
        'dateOfBirth': dateOfBirth.toIso8601String().split('T').first,
        'gender': gender,
        'address': address,
        'acceptedTerms': acceptedTerms,
      },
    );
    return _storeSession(AuthSession.fromJson(response));
  }

  Future<void> signOut() async {
    PresenceService.instance.stop();
    final refreshToken = await LocalStorage.getStringValue(
      key: LocalStorage.refreshTokenKey,
    );
    try {
      await PushNotificationService.instance.unregisterDevice().timeout(
        const Duration(seconds: 3),
      );
    } catch (_) {
      // Push cleanup must never block sign-out.
    }
    _client.beginSignOut();
    await LocalStorage.clearSession();
    try {
      if (refreshToken.isEmpty) {
        return;
      }
      try {
        await _client.postEmpty(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
          skipAuthorization: true,
          skipTokenRefresh: true,
        );
      } catch (_) {
        // The local session is already cleared when the API is unavailable.
      }
    } finally {
      _client.endSignOut();
    }
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
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await LocalStorage.clearSession();
        return null;
      }
      rethrow;
    } catch (_) {
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
