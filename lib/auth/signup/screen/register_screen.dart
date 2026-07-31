import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/auth/signup/controller/register_controller.dart';
import 'package:loan_app/widgets/brand_logo.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final RegisterController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<RegisterController>()) {
      Get.delete<RegisterController>(force: true);
    }
    controller = Get.put(RegisterController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<RegisterController>()) {
      Get.delete<RegisterController>();
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
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: AutofillGroup(
                child: Obx(() {
                  final step = controller.currentStep.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    if (step > 0) {
                                      controller.previousStep();
                                    } else {
                                      context.go('/login');
                                    }
                                  },
                            icon: const Icon(Icons.arrow_back_rounded),
                            tooltip: step > 0
                                ? 'Previous step'
                                : 'Back to sign in',
                          ),
                          const Spacer(),
                          const BrandLogo(width: 158, height: 56),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'Create your customer account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Register once, then apply for and track your loans securely.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      _ProgressHeader(currentStep: step),
                      const SizedBox(height: 16),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            switchInCurve: Curves.easeOutCubic,
                            child: KeyedSubtree(
                              key: ValueKey(step),
                              child: _stepContent(step),
                            ),
                          ),
                        ),
                      ),
                      if (controller.errorMessage.value.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _ErrorMessage(message: controller.errorMessage.value),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          if (step > 0) ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.previousStep,
                                child: const Text('Back'),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            flex: step > 0 ? 2 : 1,
                            child: FilledButton.icon(
                              onPressed:
                                  controller.canContinue &&
                                      !controller.isLoading.value
                                  ? () => _continue(context)
                                  : null,
                              icon: controller.isLoading.value
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      step == 2
                                          ? Icons.person_add_alt_1_rounded
                                          : Icons.arrow_forward_rounded,
                                    ),
                              label: Text(
                                controller.isLoading.value
                                    ? 'Creating account...'
                                    : step == 2
                                    ? 'Create account'
                                    : 'Continue',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => context.go('/login'),
                        child: const Text('Already registered? Sign in'),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepContent(int step) {
    switch (step) {
      case 0:
        return _AccountStep(controller: controller);
      case 1:
        return _IdentityStep(
          controller: controller,
          onSelectDate: () => _selectDate(context),
        );
      default:
        return _SecurityStep(controller: controller);
    }
  }

  Future<void> _continue(BuildContext context) async {
    if (controller.currentStep.value < 2) {
      controller.nextStep();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.fact_check_outlined),
        title: const Text('Create this account?'),
        content: Text(
          'We will create a loan customer account for '
          '${controller.fullNameController.text.trim()} using '
          '${controller.emailController.text.trim()}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Review'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Create account'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final registered = await controller.submit();
    if (!context.mounted) return;
    if (registered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created. You are now signed in.'),
        ),
      );
      context.go('/home');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.errorMessage.value.isEmpty
              ? 'Registration could not be completed.'
              : controller.errorMessage.value,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final latestEligibleDate = DateTime(
      today.year - 18,
      today.month,
      today.day,
    );
    final selected = await showDatePicker(
      context: context,
      initialDate: controller.dateOfBirth.value ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: latestEligibleDate,
      helpText: 'Select your date of birth',
    );
    if (selected != null) {
      controller.setDateOfBirth(selected);
    }
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.currentStep});

  final int currentStep;

  static const titles = ['Account', 'Identity', 'Security'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP ${currentStep + 1} OF 3  ·  ${titles[currentStep].toUpperCase()}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 5,
                margin: EdgeInsets.only(right: index == 2 ? 0 : 7),
                decoration: BoxDecoration(
                  color: index <= currentStep
                      ? colors.primary
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountStep extends StatelessWidget {
  const _AccountStep({required this.controller});

  final RegisterController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _StepTitle(
        title: 'Your account details',
        subtitle: 'Use contact details that belong to the loan applicant.',
      ),
      const SizedBox(height: 20),
      TextField(
        controller: controller.fullNameController,
        textCapitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.name],
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Full legal name',
          prefixIcon: Icon(Icons.person_outline_rounded),
        ),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        textInputAction: TextInputAction.next,
        autocorrect: false,
        decoration: const InputDecoration(
          labelText: 'Email address',
          prefixIcon: Icon(Icons.email_outlined),
        ),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: controller.phoneController,
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumber],
        decoration: const InputDecoration(
          labelText: 'Mobile number',
          hintText: '+63 900 000 0000',
          prefixIcon: Icon(Icons.phone_outlined),
          helperText: 'Enter at least 7 digits, including area code if needed.',
        ),
      ),
    ],
  );
}

class _IdentityStep extends StatelessWidget {
  const _IdentityStep({required this.controller, required this.onSelectDate});

  final RegisterController controller;
  final VoidCallback onSelectDate;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _StepTitle(
        title: 'Identity and eligibility',
        subtitle:
            'These details help verify your customer profile. You must be 18 or older.',
      ),
      const SizedBox(height: 20),
      TextField(
        controller: controller.idNumberController,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Government ID number',
          prefixIcon: Icon(Icons.badge_outlined),
        ),
      ),
      const SizedBox(height: 14),
      InkWell(
        onTap: onSelectDate,
        borderRadius: BorderRadius.circular(18),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Date of birth',
            prefixIcon: Icon(Icons.cake_outlined),
            suffixIcon: Icon(Icons.calendar_month_outlined),
          ),
          child: Text(
            controller.dateOfBirth.value == null
                ? 'Select date'
                : DateFormat(
                    'dd MMMM yyyy',
                  ).format(controller.dateOfBirth.value!),
          ),
        ),
      ),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        initialValue: controller.gender.value.isEmpty
            ? null
            : controller.gender.value,
        decoration: const InputDecoration(
          labelText: 'Gender',
          prefixIcon: Icon(Icons.people_outline_rounded),
        ),
        items: const ['Male', 'Female', 'Other']
            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: controller.setGender,
      ),
      const SizedBox(height: 14),
      TextField(
        controller: controller.addressController,
        textCapitalization: TextCapitalization.sentences,
        maxLines: 2,
        decoration: const InputDecoration(
          labelText: 'Current residential address',
          prefixIcon: Icon(Icons.home_outlined),
        ),
      ),
    ],
  );
}

class _SecurityStep extends StatelessWidget {
  const _SecurityStep({required this.controller});

  final RegisterController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _StepTitle(
        title: 'Secure your account',
        subtitle: 'Create a strong password and review your consent.',
      ),
      const SizedBox(height: 20),
      TextField(
        controller: controller.passwordController,
        obscureText: controller.hidePassword.value,
        autofillHints: const [AutofillHints.newPassword],
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          helperText: 'Use at least 12 characters.',
          suffixIcon: IconButton(
            onPressed: controller.hidePassword.toggle,
            icon: Icon(
              controller.hidePassword.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: controller.confirmPasswordController,
        obscureText: controller.hideConfirmPassword.value,
        autofillHints: const [AutofillHints.newPassword],
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: 'Confirm password',
          prefixIcon: const Icon(Icons.verified_user_outlined),
          errorText:
              controller.confirmPasswordController.text.isNotEmpty &&
                  !controller.passwordMatches
              ? 'Passwords do not match.'
              : null,
          suffixIcon: IconButton(
            onPressed: controller.hideConfirmPassword.toggle,
            icon: Icon(
              controller.hideConfirmPassword.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      CheckboxListTile(
        value: controller.acceptedTerms.value,
        onChanged: controller.setAcceptedTerms,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text('I confirm my information is accurate.'),
        subtitle: const Text(
          'I accept the terms, privacy notice, and electronic account communication.',
        ),
      ),
      const SizedBox(height: 6),
      const _SecurityNote(),
    ],
  );
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.phonelink_lock_outlined),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'For account safety, signing in on a new device ends the previous device session.',
          ),
        ),
      ],
    ),
  );
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    ),
  );
}
