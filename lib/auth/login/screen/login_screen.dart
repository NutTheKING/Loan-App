import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/auth/login/controller/login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController c = Get.put(AuthController());
    // final width = MediaQuery.of(context).size.width;

    return Scaffold(
      // backgroundColor: const Color(0xFFdde6ea),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text('login'.tr, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextField(
                onChanged: (v) => c.email.value = v,
                decoration: InputDecoration(labelText: 'email'.tr),
              ),
              SizedBox(height: 12),
              Column(
                children: [
                  TextField(
                    onChanged: (v) => c.password.value = v,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'password'.tr),
                  ),
                  ElevatedButton(
                    onPressed: c.isLoading.value ? null : c.login,
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                    child: c.isLoading.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text('login'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => GoRouter.of(context).go('/register'),
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
