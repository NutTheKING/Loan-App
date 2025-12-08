import 'package:go_router/go_router.dart';
import 'package:loan_app/auth/login/screen/login_screen.dart';
import 'package:loan_app/auth/signup/screen/register_screen.dart';
import 'package:loan_app/auth/splash/screen/splash_screen.dart';
import 'package:loan_app/modules/homescreen/screen/bank_home_screen.dart';
import 'package:loan_app/modules/loan/screen/add_more_loan_screen.dart';
import 'package:loan_app/modules/loan/screen/bank_account_screen.dart';
import 'package:loan_app/modules/loan/screen/loan_screen.dart';
import 'package:loan_app/modules/loan/screen/signature_screen.dart';
import 'package:loan_app/modules/loan/screen/submit_personal_info_screen.dart';
import 'package:loan_app/modules/loan/screen/upload_id_card_screen.dart';
import 'package:loan_app/modules/notification/model/notification_model.dart';
import 'package:loan_app/modules/notification/screen/notification_screen.dart';
import 'package:loan_app/modules/profile/screen/profile_screen.dart';
import 'package:loan_app/modules/withdraw_loan/screen/withdraw_loan_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: '/', name: 'splash', builder: (context, state) => const SplashView()),
    GoRoute(path: '/login', name: 'login', builder: (context, state) => SignInScreen()),
    GoRoute(path: '/register', name: 'register', builder: (context, state) => const RegisterView()),
    GoRoute(path: '/home', name: 'home', builder: (context, state) => const BankHome()),
    GoRoute(path: '/profile', name: 'profile', builder: (context, state) => AccountProfileScreen()),
    GoRoute(path: '/loan', name: 'loan', builder: (context, state) => const LoanView()),
    GoRoute(path: '/loan/add', name: 'addLoan', builder: (ccontext, state) => const AddMoreLoanView()),
    GoRoute(path: '/withdraw', name: 'withdraw', builder: (context, state) => const WithdrawView()),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) {
        return NotificationScreen();
      },
    ),

    GoRoute(path: '/personal-info', name: 'peronal_information', builder: (context, state) => PersonalInfoScreen()),
    GoRoute(path: '/bank-account', name: 'bank_account', builder: (context, state) => BankAccountScreen()),
    GoRoute(path: '/upload-id', name: 'upload_id', builder: (context, state) => UploadScreen()),
    GoRoute(
      path: "/signature",
      builder: (context, state) {
        final data = state.extra as Map;
        return SignatureScreen(loanAmount: data["amount"], period: data["period"]);
      },
    ),
  ],
);
