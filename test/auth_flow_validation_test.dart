import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loan_app/auth/login/controller/login_controller.dart';
import 'package:loan_app/auth/signup/controller/register_controller.dart';
import 'package:loan_app/utils/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  test('registration accepts an applicant on their eighteenth birthday', () {
    final today = DateTime(2026, 7, 31);

    expect(
      RegisterController.isAdult(DateTime(2008, 7, 31), today: today),
      isTrue,
    );
    expect(
      RegisterController.isAdult(DateTime(2008, 8, 1), today: today),
      isFalse,
    );
  });

  test('registration phone validation counts digits only', () {
    expect(RegisterController.isPhoneValid('+63 912 345 6789'), isTrue);
    expect(RegisterController.isPhoneValid('12-34'), isFalse);
  });

  test('registration continue state reacts to account fields', () {
    final controller = RegisterController()..onInit();

    controller.fullNameController.text = 'Test Customer';
    controller.emailController.text = 'customer@example.com';
    controller.phoneController.text = '+63 912 345 6789';

    expect(controller.canContinue, isTrue);
    controller.nextStep();
    expect(controller.currentStep.value, 1);
    expect(controller.canContinue, isFalse);

    controller.onClose();
  });

  test('login submits existing passwords regardless of signup policy', () {
    final controller = SignInController()..onInit();

    controller.emailController.text = 'customer@example.com';
    controller.passwordController.text = 'legacy';

    expect(controller.isValid, isTrue);
    controller.onClose();
  });

  test('clearing a session removes customer authentication data', () async {
    SharedPreferences.setMockInitialValues({
      LocalStorage.accessTokenKey: 'access-token',
      LocalStorage.refreshTokenKey: 'refresh-token',
      LocalStorage.userNameKey: 'Test Customer',
      LocalStorage.userEmailKey: 'customer@example.com',
      LocalStorage.userRoleKey: 'CUSTOMER',
      LocalStorage.userPermissionsKey: ['loans.create'],
    });
    await LocalStorage.init();

    await LocalStorage.clearSession();

    expect(LocalStorage.hasActiveSession, isFalse);
    expect(LocalStorage.storedRole, isEmpty);
    expect(LocalStorage.storedPermissions, isEmpty);
  });
}
