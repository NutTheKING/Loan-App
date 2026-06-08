import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';

class CustomTextfieldWidget extends StatelessWidget {
  const CustomTextfieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.keyboard = TextInputType.text,
  });

  final String label;
  final Rx<dynamic> controller;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GetX<LoanController>(
        builder: (_) {
          return TextField(
            keyboardType: keyboard,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (v) {
              if (controller is RxString) controller.value = v;
              if (controller is RxDouble)
                controller.value = double.tryParse(v) ?? 0;
            },
            controller: TextEditingController(
              text: controller.value is String
                  ? controller.value
                  : controller.value.toString(),
            ),
          );
        },
      ),
    );
  }
}
