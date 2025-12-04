import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'splash_title': 'Welcome',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Full name',
      'dob': 'Date of birth',
      'id_number': 'ID number',
      'upload_profile': 'Upload profile',
      'submit': 'Submit',
      'home': 'Home',
      'profile': 'Profile',
      'loan': 'Loan',
      'logout': 'Logout',
      'notifications': 'Notifications',
      'withdraw_request': 'Withdraw Request',
      // ... add more keys as needed
    },
    'fil_PH': {
      'splash_title': 'Maligayang pagdating',
      'login': 'Mag-login',
      'register': 'Magrehistro',
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Buong pangalan',
      'dob': 'Petsa ng kapanganakan',
      'id_number': 'ID number',
      'upload_profile': 'Mag-upload ng profile',
      'submit': 'Isumite',
      'home': 'Bahay',
      'profile': 'Profile',
      'loan': 'Uutang',
      'logout': 'Mag-logout',
      'notifications': 'Mga Abiso',
      'withdraw_request': 'Hiling na Pag-withdraw',
    },
  };
}
