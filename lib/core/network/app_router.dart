import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/age_gate_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/games/screens/games_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/partner/screens/partner_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/games/screens/compatibility_quiz_screen.dart';
import '../../features/games/screens/fantasy_cards_screen.dart';
import '../../features/games/screens/spin_wheel_screen.dart';
import '../../features/games/screens/truth_or_dare_screen.dart';
import '../../features/consultation/screens/consultation_screen.dart';
import '../../features/partner/screens/chat_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/notifications_screen.dart';
import '../../features/profile/screens/privacy_policy_screen.dart';
import '../../features/profile/screens/help_faq_screen.dart';
import '../../features/profile/screens/about_screen.dart';
import '../widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (ctx, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.ageGate,
      builder: (ctx, state) => const AgeGateScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (ctx, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (ctx, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.compatibilityQuiz,
      builder: (ctx, state) => const CompatibilityQuizScreen(),
    ),
    GoRoute(
      path: AppRoutes.truthOrDare,
      builder: (ctx, state) => const TruthOrDareScreen(),
    ),
    GoRoute(
      path: AppRoutes.fantasyCards,
      builder: (ctx, state) => const FantasyCardsScreen(),
    ),
    GoRoute(
      path: AppRoutes.spinWheel,
      builder: (ctx, state) => const SpinWheelScreen(),
    ),
    GoRoute(
      path: AppRoutes.consultation,
      builder: (ctx, state) => const ConsultationScreen(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (ctx, state) {
        final connectionId = state.pathParameters['connectionId']!;
        return ChatScreen(connectionId: connectionId);
      },
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (ctx, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (ctx, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      builder: (ctx, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: AppRoutes.helpFaq,
      builder: (ctx, state) => const HelpFaqScreen(),
    ),
    GoRoute(
      path: AppRoutes.about,
      builder: (ctx, state) => const AboutScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (ctx, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (ctx, state) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.games,
          pageBuilder: (ctx, state) => const NoTransitionPage(child: GamesScreen()),
        ),
        GoRoute(
          path: AppRoutes.explore,
          pageBuilder: (ctx, state) => const NoTransitionPage(child: ExploreScreen()),
        ),
        GoRoute(
          path: AppRoutes.partner,
          pageBuilder: (ctx, state) => const NoTransitionPage(child: PartnerScreen()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (ctx, state) => const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
  ],
);
