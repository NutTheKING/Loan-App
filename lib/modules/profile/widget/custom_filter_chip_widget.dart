import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomFilterChipWidget extends StatelessWidget {
  final String? label;
  final RxString selectedValue;
  final Color? selectedColor;
  final Color? unselectedColor;

  const CustomFilterChipWidget({
    super.key,
    required this.label,
    required this.selectedValue,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isSelected = selectedValue.value == label;

      return ChoiceChip(
        label: Text(
          label ?? '',
          style: TextStyle(
            color: isSelected ? (selectedColor ?? Colors.blue.shade700) : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => selectedValue.value = label ?? '',
        backgroundColor: unselectedColor ?? Colors.grey.shade200,
        selectedColor: selectedColor ?? Colors.blue.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? (selectedColor ?? Colors.blue.shade700) : Colors.transparent,
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      );
    });
  }
}
