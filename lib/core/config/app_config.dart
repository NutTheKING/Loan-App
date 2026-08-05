import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const _compiledApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    final platformDefault = kIsWeb
        ? '${Uri.base.origin}/api/v1'
        : 'http://localhost:4000/api/v1';
    final configuredUrl = _compiledApiBaseUrl.isNotEmpty
        ? _compiledApiBaseUrl
        : dotenv.env['API_BASE_URL'] ??
              dotenv.env['base_url'] ??
              platformDefault;
    return configuredUrl.replaceFirst(RegExp(r'/+$'), '');
  }
}
