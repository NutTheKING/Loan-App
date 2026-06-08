import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/homescreen/controller/home_screen_controller.dart';
import 'package:loan_app/modules/homescreen/widget/custom_circle_action.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController c = Get.put(HomeController());
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFdde6ea), // your exact color
      appBar: AppBar(
        backgroundColor: const Color(0xFFdde6ea),
        elevation: 0,
        title: Image.asset('assets/gotyme_logo.png', width: 120, fit: BoxFit.contain),
        actions: [
          IconButton(
            onPressed: () => GoRouter.of(context).go('/notifications'),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('My account →', style: TextStyle(fontSize: width * 0.045)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Obx(
                    () => Text(
                      '₱${c.balance.value.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: width * 0.12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.remove_red_eye_outlined),
                ],
              ),
              const SizedBox(height: 20),
              // Three action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomeCircleAction(icon:Icons.add, label: 'Deposit'),
                  CustomeCircleAction(icon: Icons.call_made,label: 'Send'),
                  CustomeCircleAction(icon: Icons.qr_code_scanner,label: 'Scan'),
                ],
              ),
              const SizedBox(height: 20),
              // Explore / Cards... (use the earlier card code or embed widgets)
              // Tips & transactions - you already requested those; include there
              // A button to navigate to Loan
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).push('/loan'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                child: const Text('Go to Loan'),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).go('/profile'),
        child: const Icon(Icons.person_outline),
      ),
    );
  }

}
