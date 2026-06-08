import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';
import 'package:loan_app/modules/loan/widget/custom_dropdownfield_widget.dart';
import 'package:loan_app/modules/loan/widget/custom_textfield_widget.dart';

class PersonalInfoScreen extends StatelessWidget {
  final LoanController pc = Get.put(LoanController());

  PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personal Information")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextfieldWidget(
              label: "Actual Name",
              controller: pc.actualName,
            ),
            CustomTextfieldWidget(
              label: "ID Card Number",
              controller: pc.idCardNo,
              keyboard: TextInputType.number,
            ),
            CustomTextfieldWidget(
              label: "Current Job",
              controller: pc.currentJob,
            ),
            CustomDropdownfieldWidget(
              label: "Gender",
              options: ["Male", "Female", "Other"],
              controller: pc.gender,
            ),
            CustomTextfieldWidget(
              label: "Stable Income",
              controller: pc.stableIncome,
            ),
            CustomTextfieldWidget(
              label: "Loan Purpose",
              controller: pc.loanPurpose,
            ),
            CustomTextfieldWidget(
              label: "Current Address",
              controller: pc.currentAddress,
            ),
            CustomTextfieldWidget(
              label: "Guarantor Name",
              controller: pc.guarantorName,
            ),
            CustomTextfieldWidget(
              label: "Guarantor Phone",
              controller: pc.guarantorPhone,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 30),
            // Only button needs Obx
            Obx(
              () => ElevatedButton(
                onPressed: pc.isPersonalInfoValid()
                    ? () => context.push("/bank-account")
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
