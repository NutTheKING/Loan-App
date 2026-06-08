import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/homescreen/controller/home_screen_controller.dart';
import 'package:loan_app/modules/homescreen/widget/custom_card_container.dart';
import 'package:loan_app/modules/homescreen/widget/custom_circle_button.dart';
import 'package:loan_app/modules/homescreen/widget/tips_transaction_widget.dart';
import 'package:loan_app/modules/homescreen/widget/visa_card_widget.dart';
import 'package:loan_app/modules/notification/controller/notification_controller.dart';
import 'package:loan_app/routers/app_router.dart';

class BankHome extends StatelessWidget {
  const BankHome({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final notificationController = Get.put(NotificationController());
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
                          GestureDetector(
                            onTap: () {
                              appRouter.push('/notifications', extra: notificationController);
                            },
                            child: Icon(Icons.notifications_none, size: 28),
                          ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomCircleButton(
                            label: "Deposit",
                            icon: Icons.add,
                            size: circleSize / 1.5,
                            iconSize: iconSize,
                            onTap: () {
                              context.push('/deposits');
                            },
                          ),
                          CustomCircleButton(
                            label: "Send / Transfer",
                            icon: Icons.call_made,
                            size: circleSize / 1.5,
                            iconSize: iconSize,
                            onTap: () {
                              context.push('/withdraws');
                            },
                          ),
                          CustomCircleButton(
                            label: "Scan QR",
                            icon: Icons.qr_code_scanner,
                            size: circleSize / 1.5,
                            iconSize: iconSize,
                            onTap: () {},
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.03),

                      // DebitCardWidget(),
                      SizedBox(height: height * 0.02),
                      // Cards section
                      CustomeCardWidget(
                        onTap: () => context.push('/explore-rewards'),
                        padding: cardPadding,
                        child: Center(
                          child: Text(
                            "Explore Go Rewards",
                            style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      CustomeCardWidget(
                        onTap: () => context.push('/go-save-account'),
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

                      CustomeCardWidget(
                        onTap: () => context.push('/exchange-rate'),
                        padding: cardPadding,
                        child: Row(
                          children: [
                            Icon(Icons.currency_exchange_outlined, size: iconSize * 1.4, color: Colors.blue),
                            SizedBox(width: width * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Exchange Rate",
                                    style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: height * 0.005),
                                  Text(
                                    "The price of one currency expressed",
                                    style: TextStyle(fontSize: width * 0.035),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      // Feature Buttons (Responsive)
                      Row(
                        children: [
                          Expanded(
                            child: CustomeCardWidget(
                              onTap: () {},
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
                          SizedBox(width: width * 0.02),
                          Expanded(
                            child: CustomeCardWidget(
                              onTap: () {},
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
                      SizedBox(height: height * 0.02),
                      DebitCardWidget(),
                      SizedBox(height: height * 0.02),
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
}
