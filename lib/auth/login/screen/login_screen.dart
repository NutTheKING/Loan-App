import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/auth/login/controller/login_controller.dart';
import 'package:loan_app/widgets/brand_logo.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final SignInController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<SignInController>()) {
      Get.delete<SignInController>(force: true);
    }
    controller = Get.put(SignInController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<SignInController>()) {
      Get.delete<SignInController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 18 * (1 - value)),
                  child: child,
                ),
              ),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(child: BrandLogo(width: 238, height: 82)),
                    const SizedBox(height: 20),
                    Text(
                      'LOAN SERVICES',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customer and back-office access',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 34),
                    TextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [],
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => TextField(
                        controller: controller.passwordController,
                        obscureText: controller.hidePassword.value,
                        autofillHints: const [],
                        autocorrect: false,
                        enableSuggestions: false,
                        onSubmitted: (_) => _signIn(context),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => controller.hidePassword.toggle(),
                            icon: Icon(
                              controller.hidePassword.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      final canSignIn =
                          controller.isValid && !controller.loading.value;
                      return OutlinedButton.icon(
                        onPressed: canSignIn ? () => _signIn(context) : null,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          disabledBackgroundColor: colors.onSurface.withValues(
                            alpha: 0.12,
                          ),
                          disabledForegroundColor: colors.onSurface.withValues(
                            alpha: 0.38,
                          ),
                          side: BorderSide.none,
                        ),
                        icon: controller.loading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login_rounded),
                        label: const Text('Sign in'),
                      );
                    }),
                    const SizedBox(height: 18),
                    OutlinedButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Create customer account'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'One account can be active on one device at a time.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn(BuildContext context) async {
    final user = await controller.signIn();
    if (user != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome back, ${user.fullName}.')),
      );
      context.go(user.canAccessAdmin ? '/admin' : '/home');
    }
  }
}
