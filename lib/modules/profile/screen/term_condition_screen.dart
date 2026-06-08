import 'package:flutter/material.dart';
import 'package:loan_app/modules/profile/widget/custom_selectionTitle_widget.dart';
import 'package:loan_app/modules/profile/widget/custom_selection_text_widget.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f7),
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        centerTitle: true,
        elevation: 0,
      ),

      body: Column(
        children: [
          // ---------- TOP HEADER ----------
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: const Text(
              "Please read the agreement carefully before applying for your loan.",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSelectionTitleWidgets(
                    icon: Icons.people_alt,
                    title: "Eligibility Requirements",
                  ),
                  CustomSelectionTextWidget(
                    text:
                        "• Applicant must be at least 18 years old.\n"
                        "• Must provide valid government-issued ID.\n"
                        "• Must have stable income and contact number.",
                  ),

                  CustomSelectionTitleWidgets(
                    icon: Icons.percent_rounded,
                    title: "Interest & Fees",
                  ),
                  CustomSelectionTextWidget(
                    text:
                        "• Monthly interest rate is 0.5%.\n"
                        "• Service fee may apply depending on loan amount.\n"
                        "• All charges will be shown before confirming your loan.",
                  ),

                  CustomSelectionTitleWidgets(
                    icon: Icons.schedule,
                    title: "Loan Period & Repayment",
                  ),
                  CustomSelectionTextWidget(
                    text:
                        "• Available loan terms: 4, 12, 24, 36 months.\n"
                        "• Payment must be made on or before the due date.\n"
                        "• Multiple payment methods are available inside the app.",
                  ),

                  CustomSelectionTitleWidgets(
                    icon: Icons.warning_amber_rounded,
                    title: "Late Payment Policy",
                  ),
                  CustomSelectionTextWidget(
                    text:
                        "• Late repayment will incur penalty fees.\n"
                        "• Repeated late payments may affect future loan eligibility.",
                  ),

                  CustomSelectionTitleWidgets(
                    icon: Icons.lock,
                    title: "Privacy & Data Usage",
                  ),
                  CustomSelectionTextWidget(
                    text:
                        "• We securely protect your information.\n"
                        "• Your data will NOT be sold or shared without consent.\n"
                        "• Used only for loan evaluation and verification.",
                  ),

                  CustomSelectionTitleWidgets(
                    icon: Icons.check_circle,
                    title: "Agreement",
                  ),
                  CustomSelectionTextWidget(
                    text:
                        "By clicking 'I Agree', you confirm that you:\n"
                        "• Understand all terms and loan conditions.\n"
                        "• Authorize us to verify your information.\n"
                        "• Accept your responsibilities as a borrower.",
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          // ---------- BOTTOM BUTTON ----------
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "I Agree",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
