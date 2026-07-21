import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:loan_app/core/config/app_config.dart';
import 'package:loan_app/utils/local_storage.dart';

class ErrorModel {
  const ErrorModel({this.statusCode, this.bodyString});

  final int? statusCode;
  final dynamic bodyString;
}

enum METHODE { get, post, delete, update }

class ApiBaseHelper {
  Future<dynamic> onNetworkRequesting({
    required String url,
    Map<String, String>? header,
    Map<String, dynamic>? body,
    required METHODE? methode,
    required bool isAuthorize,
    String baseUrl = '',
  }) async {
    final resolvedBaseUrl =
        (baseUrl.isNotEmpty ? baseUrl : AppConfig.apiBaseUrl).replaceFirst(
          RegExp(r'/+$'),
          '',
        );
    final token = await LocalStorage.getStringValue(
      key: LocalStorage.accessTokenKey,
    );
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (isAuthorize && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?header,
    };
    final requestUrl = Uri.parse(
      '$resolvedBaseUrl/${url.replaceFirst(RegExp(r'^/+'), '')}',
    );
    debugPrint('API request: $requestUrl');

    try {
      final response = switch (methode) {
        METHODE.get => await http.get(requestUrl, headers: requestHeaders),
        METHODE.post => await http.post(
          requestUrl,
          headers: requestHeaders,
          body: jsonEncode(body ?? {}),
        ),
        METHODE.delete => await http.delete(
          requestUrl,
          headers: requestHeaders,
        ),
        METHODE.update => await http.put(
          requestUrl,
          headers: requestHeaders,
          body: jsonEncode(body ?? {}),
        ),
        null => throw const ErrorModel(
          bodyString: 'An HTTP method is required.',
        ),
      };
      return _returnResponse(response);
    } on ErrorModel {
      rethrow;
    } catch (error) {
      return Future.error(error);
    }
  }

  dynamic _returnResponse(http.Response response) {
    final responseBody = response.body.isEmpty
        ? null
        : _decodeResponse(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    }
    return Future.error(
      ErrorModel(statusCode: response.statusCode, bodyString: responseBody),
    );
  }

  dynamic _decodeResponse(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return body;
    }
  }
}
