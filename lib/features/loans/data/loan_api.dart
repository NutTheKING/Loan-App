import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loan_app/core/network/api_client.dart';

class LoanApi {
  LoanApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<String> submitApplication(Map<String, Object> application) async {
    final response = await _client.post('/loans', data: application);
    final loan = Map<String, dynamic>.from(response['loan'] as Map);
    return loan['id'] as String;
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
    return _client.postMultipart(
      '/loans/$loanId/documents',
      FormData.fromMap({
        'kind': kind,
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    );
  }
}
