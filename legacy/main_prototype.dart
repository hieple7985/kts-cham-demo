import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:customer_care_app/prototype/1_auth/auth_entry.dart';
import 'package:customer_care_app/core/theme/app_theme.dart'; // Reusing existing app theme

void main() {
  runApp(const PrototypeApp());
}

class PrototypeApp extends StatelessWidget {
  const PrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'CUCA Prototype',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const WelcomeScreen(), // Entry point S1.1
        );
      },
    );
  }
}
