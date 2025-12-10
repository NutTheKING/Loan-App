import 'package:flutter/material.dart';

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
                  sectionTitle("Borrower Information"),
                  contractRow("Full Name", "___________"),
                  contractRow("Phone Number", "___________"),
                  contractRow("ID Card", "___________"),
                  const SizedBox(height: 20),

                  //------------------------------------------------------
                  //                SECTION 2: LOAN DETAILS
                  //------------------------------------------------------
                  sectionTitle("Loan Details"),
                  contractRow("Loan Amount", "₱ _________"),
                  contractRow("Loan Period", "___ Months"),
                  contractRow("Monthly Interest", "0.5%"),
                  contractRow("Total Interest", "₱ _________"),
                  contractRow("Monthly Payment", "₱ _________"),
                  contractRow("Disbursement Date", "___________"),
                  const SizedBox(height: 20),

                  //------------------------------------------------------
                  //                SECTION 3: TERMS
                  //------------------------------------------------------
                  sectionTitle("Agreement Terms"),
                  contractText("1. The borrower agrees to repay the loan under the specified terms."),
                  contractText("2. Late payments may result in penalties as defined by the lender."),
                  contractText("3. All information provided must be true and accurate."),
                  contractText("4. The lender reserves the right to take legal action for non-payment."),
                  contractText("5. Disbursement may take up to 24 hours after approval."),
                  contractText("6. Interest is calculated monthly based on the outstanding balance."),

                  const SizedBox(height: 20),

                  //------------------------------------------------------
                  //                SECTION 4: SIGNATURE AREAS
                  //------------------------------------------------------
                  sectionTitle("Signatures"),

                  const SizedBox(height: 10),
                  signatureBlock("Borrower Signature"),
                  const SizedBox(height: 25),
                  signatureBlock("Lender / Company Signature"),
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

  // --------------------------------------------------------------
  //                     REUSABLE WIDGETS
  // --------------------------------------------------------------

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget contractRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget contractText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
    );
  }

  Widget signatureBlock(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          height: 70,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}
