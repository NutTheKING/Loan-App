import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/themes/app_color.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final Rx<dynamic> rxValue;
  final TextInputType keyboard;
  final IconData? prefixIcon;
  final bool obscure;
  final int maxLines;

  const CustomInputField({
    super.key,
    required this.label,
    required this.rxValue,
    this.keyboard = TextInputType.text,
    this.prefixIcon,
    this.obscure = false,
    this.maxLines = 1,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.rxValue.value.toString());

    // Sync Rx → TextField
    ever(widget.rxValue, (v) {
      if (controller.text != v.toString()) {
        controller.text = v.toString();
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.cool,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.strength.withValues(alpha: .3)),
        ),
        child: TextField(
          controller: controller,
          keyboardType: widget.keyboard,
          obscureText: widget.obscure,
          maxLines: widget.maxLines,
          style: const TextStyle(fontSize: 16, color: AppColors.strength),
          decoration: InputDecoration(
            labelText: widget.label,
            border: InputBorder.none,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.impact)
                : null,
            labelStyle: const TextStyle(
              color: AppColors.strength,
              fontWeight: FontWeight.w500,
            ),
          ),
          onChanged: (v) {
            if (widget.rxValue is RxString) {
              widget.rxValue.value = v;
            } else if (widget.rxValue is RxInt) {
              widget.rxValue.value = int.tryParse(v) ?? 0;
            } else if (widget.rxValue is RxDouble) {
              widget.rxValue.value = double.tryParse(v) ?? 0.0;
            } else {
              widget.rxValue.value = v;
            }
          },
        ),
      ),
    );
  }
}
