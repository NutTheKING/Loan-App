import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/homescreen/controller/home_screen_controller.dart';
import 'package:loan_app/modules/homescreen/widgets/tips_transaction_widget.dart';
import 'package:loan_app/modules/homescreen/widgets/visa_card_widget.dart';
import 'package:loan_app/routers/app_router.dart';

class BankHome extends StatelessWidget {
  const BankHome({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xffdde6ea),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double cardPadding = width * 0.045;
                double iconSize = width * 0.075;
                double circleSize = width * 0.22;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.015),

                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            child: Icon(Icons.person_outline, size: iconSize),
                            onTap: () => context.push('/profile'),
                          ),
                          Text(
                            "GOTyme",
                            style: TextStyle(fontSize: width * 0.06, fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.notifications_none, size: iconSize),
                        ],
                      ),

                      SizedBox(height: height * 0.02),

                      // Account Title
                      Text(
                        "My account →",
                        style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: height * 0.005),

                      // Balance
                      Row(
                        children: [
                          Text(
                            "₱6.00",
                            style: TextStyle(fontSize: width * 0.12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: width * 0.02),
                          Icon(Icons.remove_red_eye_outlined, size: iconSize),
                        ],
                      ),

                      SizedBox(height: height * 0.03),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _circleButton("Deposit", Icons.add, circleSize, iconSize),
                          _circleButton("Send / Transfer", Icons.call_made, circleSize, iconSize),
                          _circleButton("Scan QR", Icons.qr_code_scanner, circleSize, iconSize),
                        ],
                      ),

                      SizedBox(height: height * 0.03),

                      // Cards section
                      _cardContainer(
                        padding: cardPadding,
                        child: Center(
                          child: Text(
                            "Explore Go Rewards",
                            style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      _cardContainer(
                        padding: cardPadding,
                        child: Row(
                          children: [
                            Icon(Icons.savings, size: iconSize * 1.4, color: Colors.blue),
                            SizedBox(width: width * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Open a Go Save account",
                                    style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: height * 0.005),
                                  Text("Earn 3.5% interest yearly →", style: TextStyle(fontSize: width * 0.035)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      _cardContainer(
                        padding: cardPadding,
                        child: Row(
                          children: [
                            Icon(Icons.watch_later_outlined, size: iconSize * 1.4, color: Colors.blue),
                            SizedBox(width: width * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "USD Time Deposit",
                                    style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: height * 0.005),
                                  Text("Buy USD, save for a fixed term →", style: TextStyle(fontSize: width * 0.035)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: height * 0.025),

                      // Feature Buttons (Responsive)
                      Row(
                        children: [
                          Expanded(
                            child: _cardContainer(
                              padding: cardPadding,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.phone_android, size: iconSize, color: Colors.blue),
                                  SizedBox(width: width * 0.02),
                                  Text("Buy load", style: TextStyle(fontSize: width * 0.04)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: width * 0.03),
                          Expanded(
                            child: _cardContainer(
                              padding: cardPadding,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt, size: iconSize, color: Colors.blue),
                                  SizedBox(width: width * 0.02),
                                  Text("Pay bills", style: TextStyle(fontSize: width * 0.04)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.03),
                      DebitCardWidget(),
                      TipsAndTransactions(),
                    ],
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: () => appRouter.push('/loan'),
                child: Container(
                  width: width * 0.22,
                  height: width * 0.22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [Colors.black, Colors.blue, Colors.cyan]),
                  ),
                  child: Center(
                    child: Text(
                      "GO",
                      style: TextStyle(fontSize: width * 0.08, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Circle Buttons
  Widget _circleButton(String label, IconData icon, double size, double iconSize) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle),
          child: Icon(icon, size: iconSize * 1.2, color: Colors.black87),
        ),
        SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  // Card container
  Widget _cardContainer({required Widget child, required double padding}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }
}
