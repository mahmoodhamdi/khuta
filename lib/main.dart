import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'cubit/auth/auth_cubit.dart';
import 'cubit/auth/auth_state.dart';
import 'cubit/onboarding/onboarding_cubit.dart';
import 'cubit/theme/theme_cubit.dart';
import 'firebase_options.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SharedPreferences for theme and onboarding
  final prefs = await SharedPreferences.getInstance();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit()),
          BlocProvider(create: (context) => ThemeCubit(prefs: prefs)),
          BlocProvider(create: (context) => OnboardingCubit(prefs: prefs)),
        ],
        child: const KhutaApp(),
      ),
    ),
  );
}

class KhutaApp extends StatelessWidget {
  const KhutaApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Check login status when app starts
    context.read<AuthCubit>().checkLoginStatus();

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'Khuta',
          debugShowCheckedModeBanner: false,

          // Localization
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

          // Theme
          theme: AppTheme.lightTheme(context),
          darkTheme: AppTheme.darkTheme(context),
          themeMode: themeState is ThemeDark
              ? ThemeMode.dark
              : ThemeMode.light, // Home
          home: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, onboardingState) {
              // Show onboarding for first-time users
              if (onboardingState is OnboardingRequired) {
                return const OnboardingScreen();
              }

              // After onboarding is completed, proceed with normal flow
              return BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading || state is AuthInitial) {
                    return const SplashScreen();
                  } else if (state is AuthSuccess) {
                    return const MainScreen();
                  } else {
                    return const SplashScreen();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
