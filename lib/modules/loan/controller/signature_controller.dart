import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

class SignatureControllerX extends GetxController {
  final signatureController = SignatureController(penStrokeWidth: 3, penColor: Color(0xFF202020));

  var signed = false.obs;

  void clearSignature() {
    signatureController.clear();
    signed.value = false;
  }

  Future<void> checkIfSigned() async {
    final data = await signatureController.toPngBytes();
    signed.value = data != null && data.isNotEmpty;
  }

  Future<Uint8List?> exportSignature() async {
    return await signatureController.toPngBytes();
  }
}
