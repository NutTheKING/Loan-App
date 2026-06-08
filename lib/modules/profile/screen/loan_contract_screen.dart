import 'package:flutter/material.dart';
import 'package:loan_app/modules/profile/widget/custom_contract_row_widget.dart';
import 'package:loan_app/modules/profile/widget/custom_contract_text_widget.dart';
import 'package:loan_app/modules/profile/widget/custom_signature_block_widget.dart';
import 'package:loan_app/modules/profile/widget/custome_selection_title_widget.dart';

class LoanContractView extends StatelessWidget {
  const LoanContractView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f5f8),
      appBar: AppBar(title: const Text("Loan Contract"), elevation: 0, backgroundColor: const Color(0xfff2f5f8)),
      body: Stack(
        children: [
          // ---------------- CONTRACT BODY ----------------
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //------------------------------------------------------
                  //                TITLE
                  //------------------------------------------------------
                  const Text("Loan Agreement Contract", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                    "Please review all terms carefully before proceeding.",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  //------------------------------------------------------
                  //                SECTION 1: BORROWER DETAILS
                  //------------------------------------------------------
                  CustomeSelectionTitleWidget(title: "Borrower Information"),
                  CustomContractRowWidget(label: "Full Name", value: "___________"),
                  CustomContractRowWidget(label: "Phone Number", value: "___________"),
                  CustomContractRowWidget(label: "ID Card", value: "___________"),
                  const SizedBox(height: 20),

                  //------------------------------------------------------
                  //                SECTION 2: LOAN DETAILS
                  //------------------------------------------------------
                  CustomeSelectionTitleWidget(title: "Loan Details"),
                  CustomContractRowWidget(label: "Loan Amount", value: "₱ _________"),
                  CustomContractRowWidget(label: "Loan Period", value: "___ Months"),
                  CustomContractRowWidget(label: "Monthly Interest", value: "0.5%"),
                  CustomContractRowWidget(label: "Total Interest", value: "₱ _________"),
                  CustomContractRowWidget(label: "Monthly Payment", value: "₱ _________"),
                  CustomContractRowWidget(label: "Disbursement Date", value: "___________"),
                  const SizedBox(height: 20),

                  //------------------------------------------------------
                  //                SECTION 3: TERMS
                  //------------------------------------------------------
                  CustomeSelectionTitleWidget(title: "Agreement Terms"),
                  CustomContractTextWidget(text: "1. The borrower agrees to repay the loan under the specified terms."),
                  CustomContractTextWidget(text: "2. Late payments may result in penalties as defined by the lender."),
                  CustomContractTextWidget(text: "3. All information provided must be true and accurate."),
                  CustomContractTextWidget(
                    text: "4. The lender reserves the right to take legal action for non-payment.",
                  ),
                  CustomContractTextWidget(text: "5. Disbursement may take up to 24 hours after approval."),
                  CustomContractTextWidget(text: "6. Interest is calculated monthly based on the outstanding balance."),

                  const SizedBox(height: 20),

                  //------------------------------------------------------
                  //                SECTION 4: SIGNATURE AREAS
                  //------------------------------------------------------
                  CustomeSelectionTitleWidget(title: "Signatures"),

                  const SizedBox(height: 10),
                  CustomSignatureBlockWidget(label:"Borrower Signature"),
                  const SizedBox(height: 25),
                  CustomSignatureBlockWidget(label:"Lender / Company Signature"),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          //------------------------------------------------------
          //                BOTTOM BUTTON: AGREE & CONTINUE
          //------------------------------------------------------
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xfff2f5f8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Next Step
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Agree & Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
