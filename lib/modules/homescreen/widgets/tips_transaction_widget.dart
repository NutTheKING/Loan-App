import 'package:flutter/material.dart';

class TipsAndTransactions extends StatelessWidget {
  const TipsAndTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SECTION TITLE: Tips & promos
          Text(
            "Tips and promos",
            style: TextStyle(fontSize: width * 0.055, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: height * 0.02),

          // TIPS HORIZONTAL SCROLLER
          SizedBox(
            height: height * 0.12,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                tipItem("assets/tip1.jpg", "Let's get started", width),
                tipItem("assets/tip2.jpg", "Better saving", width),
                tipItem("assets/tip3.jpg", "Better sending", width),
                tipItem("assets/tip4.jpg", "Better shopping", width),
                tipItem("assets/tip5.jpg", "Better service", width),
              ],
            ),
          ),

          SizedBox(height: height * 0.035),

          // SECTION TITLE: Recent Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Transactions",
                style: TextStyle(fontSize: width * 0.053, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.008),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black54),
                ),
                child: Text(
                  "All",
                  style: TextStyle(fontSize: width * 0.04, color: Colors.black87),
                ),
              ),
            ],
          ),

          SizedBox(height: height * 0.02),

          // Transactions list
          transactionTile(
            icon: Icons.star_border,
            title: "Go Rewards points earned",
            amount: "+49.10",
            color: Colors.green,
            width: width,
            isCredit: true,
          ),

          Divider(height: height * 0.04, color: Colors.grey[300]),

          transactionTile(
            icon: Icons.credit_card,
            title: "ROBINSONS SUPT IMUS",
            amount: "-₱ 245.50",
            color: Colors.red,
            width: width,
          ),

          Divider(height: height * 0.04, color: Colors.grey[300]),

          transactionTile(
            icon: Icons.download,
            title: "Robinsons Supermarket RP Imus",
            amount: "+₱ 500.00",
            color: Colors.green,
            width: width,
            isCredit: true,
          ),

          SizedBox(height: height * 0.04),

          // Bottom GO logo
          SizedBox(height: height * 0.05),
        ],
      ),
    );
  }

  // ---- Tip Item Widget ----
  Widget tipItem(String imagePath, String label, double width) {
    return Container(
      margin: EdgeInsets.only(right: width * 0.04),
      child: Column(
        children: [
          Container(
            width: width * 0.18,
            height: width * 0.18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: width * 0.02),
          Text(
            label,
            style: TextStyle(fontSize: width * 0.03, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // ---- Transaction Tile Widget ----
  Widget transactionTile({
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
    required double width,
    bool isCredit = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: width * 0.065, color: Colors.black87),
        SizedBox(width: width * 0.035),

        // Title
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: width * 0.043, color: Colors.black87),
          ),
        ),

        // Amount
        Text(
          amount,
          style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
