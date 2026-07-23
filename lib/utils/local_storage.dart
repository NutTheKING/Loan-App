import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const userNameKey = 'user_name';
  static const userEmailKey = 'user_email';
  static const userRoleKey = 'user_role';
  static const userPermissionsKey = 'user_permissions';

  static SharedPreferences? _prefs;

  // initial SharedPreferences

  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();

    return _prefs!;
  }

  // store data to local storage

  static Future<void> storeData({String? key, dynamic value}) async {
    final preferences = _requirePreferences();
    if (value.runtimeType == String) {
      await preferences.setString(key!, value);
    } else if (value.runtimeType == int) {
      await preferences.setInt(key!, value);
    } else if (value.runtimeType == bool) {
      await preferences.setBool(key!, value);
    } else if (value.runtimeType == double) {
      await preferences.setDouble(key!, value);
    } else {
      await preferences.setStringList(key!, value);
    }
  }

  // function for get data from local storage

  static Future<int> getIntValue({String? key}) async {
    return (_requirePreferences().getInt(key!) ?? 0);
  }

  static Future<String> getStringValue({String? key}) async {
    return (_requirePreferences().getString(key!) ?? '');
  }

  static Future<bool> getBooleanValue({String? key}) async {
    return (_requirePreferences().getBool(key!) ?? false);
  }

  static Future<double> getDoubleValue({String? key}) async {
    return (_requirePreferences().getDouble(key!) ?? 0.0);
  }

  static Future<List<String>> getListStringValue({required String key}) async {
    return _requirePreferences().getStringList(key) ?? [];
  }

  static Future<void> storeListStringValue({
    required String key,
    required List<String> value,
  }) async {
    await _requirePreferences().setStringList(key, value);
  }

  static Future<void> removeData(String key) =>
      _requirePreferences().remove(key);

  static Future<void> clearSession() async {
    await Future.wait([
      removeData(accessTokenKey),
      removeData(refreshTokenKey),
      removeData(userNameKey),
      removeData(userEmailKey),
      removeData(userRoleKey),
      removeData(userPermissionsKey),
    ]);
  }

  static SharedPreferences _requirePreferences() {
    final preferences = _prefs;
    if (preferences == null) {
      throw StateError(
        'LocalStorage.init() must be called before accessing stored values.',
      );
    }
    return preferences;
  }
}
