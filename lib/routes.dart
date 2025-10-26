import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/goal_planner_screen.dart';
import 'screens/buddyhub_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/life_skills_screen.dart';
import 'screens/perform_smartly_screen.dart';
import 'screens/pathways_screen.dart';
import 'screens/hotlines_screen.dart';
import 'screens/housing_screen.dart';
import 'screens/support_screen.dart';
import 'screens/smart_buddy_screen.dart';
import 'screens/mood_trend_history.dart';
import 'screens/email_verification_screen.dart';
import 'screens/password_change_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => const SplashScreen(),
  '/welcome': (_) => const WelcomeScreen(),
  '/login': (_) => const LoginScreen(),
  '/register': (_) => const RegisterScreen(),
  '/home': (_) => const HomeScreen(),
  '/goals': (_) => const GoalPlannerScreen(),
  '/buddyHub': (_) => const BuddyHubScreen(),
  '/journal': (_) => const JournalScreen(),
  '/profile': (_) => const ProfileScreen(),
  '/lifeSkills': (_) => const LifeSkillsScreen(),
  '/performSmartly': (_) => const PerformSmartlyScreen(),
  '/pathways': (_) => const PathwaysScreen(),
  '/hotlines': (_) => const HotlinesScreen(),
  '/housing': (_) => const HousingScreen(),
  '/support': (_) => const SupportScreen(),
  '/smartBuddy': (_) => const SmartBuddyScreen(),
  '/moodHistory': (_) => const MoodTrendHistoryScreen(),
  '/emailVerification': (_) => const EmailVerificationScreen(userEmail: ''),
  '/passwordChange': (_) => const PasswordChangeScreen(userEmail: ''),
};