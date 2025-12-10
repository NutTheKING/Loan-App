import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f7),
      appBar: AppBar(title: const Text("Terms & Conditions"), centerTitle: true, elevation: 0),

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
                  _sectionTitle(Icons.people_alt, "Eligibility Requirements"),
                  _sectionText(
                    "• Applicant must be at least 18 years old.\n"
                    "• Must provide valid government-issued ID.\n"
                    "• Must have stable income and contact number.",
                  ),

                  _sectionTitle(Icons.percent_rounded, "Interest & Fees"),
                  _sectionText(
                    "• Monthly interest rate is 0.5%.\n"
                    "• Service fee may apply depending on loan amount.\n"
                    "• All charges will be shown before confirming your loan.",
                  ),

                  _sectionTitle(Icons.schedule, "Loan Period & Repayment"),
                  _sectionText(
                    "• Available loan terms: 4, 12, 24, 36 months.\n"
                    "• Payment must be made on or before the due date.\n"
                    "• Multiple payment methods are available inside the app.",
                  ),

                  _sectionTitle(Icons.warning_amber_rounded, "Late Payment Policy"),
                  _sectionText(
                    "• Late repayment will incur penalty fees.\n"
                    "• Repeated late payments may affect future loan eligibility.",
                  ),

                  _sectionTitle(Icons.lock, "Privacy & Data Usage"),
                  _sectionText(
                    "• We securely protect your information.\n"
                    "• Your data will NOT be sold or shared without consent.\n"
                    "• Used only for loan evaluation and verification.",
                  ),

                  _sectionTitle(Icons.check_circle, "Agreement"),
                  _sectionText(
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
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("I Agree", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- SECTION TITLE ----------
  Widget _sectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 22),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---------- SECTION TEXT ----------
  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)),
    );
  }
}
