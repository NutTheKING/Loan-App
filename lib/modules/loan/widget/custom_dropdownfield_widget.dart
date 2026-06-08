import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';

class CustomDropdownfieldWidget extends StatelessWidget {
  const CustomDropdownfieldWidget({
    super.key,
    required this.label,
    required this.options,
    required this.controller,
  });

  final String label;
  final List<String> options;
  final Rx<String> controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GetX<LoanController>(
        builder: (_) {
          return DropdownButtonFormField<String>(
            initialValue: controller.value.isEmpty ? null : controller.value,
            items: options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (v) => controller.value = v ?? '',
          );
        },
      ),
    );
  }
}
