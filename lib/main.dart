import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'config/supabase/supabase_config.dart';
import 'core/config/app_config.dart';
import 'core/config/app_prefs.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/auth_gate.dart';

/// Main entry point for CUCA CRM Demo
///
/// This demo version uses mock data and services.
/// No API keys or backend setup required - just run!
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppPrefs.init();

  // Initialize mock Supabase (no real backend)
  await SupabaseConfig.initialize();

  // Auto-login with demo user for seamless experience
  SupabaseConfig.auth.signInWithMockUser(
    id: 'demo-user-001',
    email: 'demo@cuca.com',
    phoneNumber: '0901234567',
    fullName: 'Minh Sale',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'CUCA CRM Demo',
          theme: AppTheme.lightTheme,
          home: const AuthGate(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
