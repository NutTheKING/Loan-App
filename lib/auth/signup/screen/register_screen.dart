import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/auth/signup/controller/register_controller.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController c = Get.put(RegisterController());
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFdde6ea),
      appBar: AppBar(title: Text('register'.tr)),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: c.fullNameController,
                decoration: InputDecoration(labelText: 'full_name'.tr),
              ),
              TextField(
                controller: c.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'email'.tr),
              ),
              TextField(
                controller: c.idNumberController,
                decoration: InputDecoration(labelText: 'id_number'.tr),
              ),
              TextField(
                controller: c.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  helperText: 'Use at least 12 characters.',
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => ElevatedButton(
                  onPressed: c.isLoading.value || !c.isValid
                      ? null
                      : () async {
                          final registered = await c.submit();
                          if (registered && context.mounted) {
                            context.go('/home');
                          }
                        },
                  child: c.isLoading.value
                      ? const CircularProgressIndicator()
                      : Text('submit'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
