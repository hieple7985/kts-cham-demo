import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/app_prefs.dart';
import '../../../home/presentation/screens/app_shell_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_welcome_screen.dart';
import '../providers/auth_provider.dart';
import 'welcome_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _bootstrapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bootstrapped) return;
    _bootstrapped = true;

    if (AppConfig.useSupabaseAuth) {
      Future.microtask(() => ref.read(authProvider.notifier).bootstrap());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (!AppConfig.useSupabaseAuth) {
      return const WelcomeScreen();
    }

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.isAuthenticated) {
      return AppPrefs.didOnboard
          ? const AppShellScreen()
          : const OnboardingWelcomeScreen();
    }

    if (authState.error != null && authState.error!.trim().isNotEmpty) {
      return WelcomeScreen(errorMessage: authState.error);
    }

    return const WelcomeScreen();
  }
}
