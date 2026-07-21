import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/auth/login/controller/login_controller.dart';

class SignInScreen extends StatelessWidget {
  final SignInController sc = Get.put(SignInController());

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFdde6ea),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sign in to continue",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // Email
              _textField(
                label: "Email",
                hint: "Enter your email",
                controller: sc.emailController,
                keyboard: TextInputType.emailAddress,
                onChanged: (_) {},
              ),

              const SizedBox(height: 20),

              // Password
              Obx(() {
                return TextField(
                  controller: sc.passwordController,
                  obscureText: sc.hidePassword.value,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        sc.hidePassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        sc.hidePassword.value = !sc.hidePassword.value;
                      },
                    ),
                  ),
                );
              }),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 20),

              // Sign In Button
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: sc.isValid && !sc.loading.value
                        ? () async {
                            final signedIn = await sc.signIn();
                            if (signedIn && context.mounted) {
                              context.go("/home");
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: sc.loading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign In", style: TextStyle(fontSize: 18)),
                  ),
                );
              }),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
