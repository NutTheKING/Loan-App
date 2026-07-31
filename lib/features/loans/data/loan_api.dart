import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loan_app/core/network/api_client.dart';

class LoanApi {
  LoanApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<Map<String, dynamic>> currentProduct() async {
    final response = await _client.get('/loan-products/current');
    return Map<String, dynamic>.from(response['product'] as Map);
  }

  Future<LoanApplicationAvailability> applicationAvailability() async {
    final response = await _client.get('/dashboard');
    return LoanApplicationAvailability.fromJson(response);
  }

  Future<String> submitApplication(Map<String, Object> application) async {
    final response = await _client.post('/loans', data: application);
    final loan = Map<String, dynamic>.from(response['loan'] as Map);
    return loan['id'] as String;
  }

  Future<void> completeApplication(String loanId) async {
    await _client.post('/loans/$loanId/submit');
  }

  Future<void> uploadImage({
    required String loanId,
    required String kind,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    await _uploadBytes(
      loanId: loanId,
      kind: kind,
      filename: file.name,
      bytes: bytes,
    );
  }

  Future<void> uploadSignature({
    required String loanId,
    required Uint8List bytes,
  }) {
    return _uploadBytes(
      loanId: loanId,
      kind: 'SIGNATURE',
      filename: 'signature.png',
      bytes: bytes,
    );
  }

  Future<void> _uploadBytes({
    required String loanId,
    required String kind,
    required String filename,
    required Uint8List bytes,
  }) {
    final extension = filename.toLowerCase().split('.').last;
    final mediaType = switch (extension) {
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'webp' => MediaType('image', 'webp'),
      _ => MediaType('image', 'png'),
    };
    return _client.postMultipart(
      '/loans/$loanId/documents',
      FormData.fromMap({
        'kind': kind,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: mediaType,
        ),
      }),
    );
  }
}

class LoanApplicationAvailability {
  const LoanApplicationAvailability({
    required this.canApply,
    this.reason,
    this.message,
    this.loanId,
    this.loanNumber,
    this.status,
  });

  final bool canApply;
  final String? reason;
  final String? message;
  final String? loanId;
  final String? loanNumber;
  final String? status;

  factory LoanApplicationAvailability.fromJson(Map<String, dynamic> json) {
    final blockValue = json['loanApplicationBlock'];
    final block = blockValue is Map
        ? Map<String, dynamic>.from(blockValue)
        : const <String, dynamic>{};
    return LoanApplicationAvailability(
      canApply: json['canApplyForLoan'] != false,
      reason: block['reason'] as String?,
      message: block['message'] as String?,
      loanId: block['loanId'] as String?,
      loanNumber: block['loanNumber'] as String?,
      status: block['status'] as String?,
    );
  }
}
