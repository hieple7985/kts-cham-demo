import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../models/settings_state.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;

  SettingsNotifier(this._ref)
      : super(
          // Start with empty defaults, will be updated by auth state
          SettingsState(
            profile: const UserProfile(
              fullName: '',
              email: '',
              phone: '',
              businessName: '',
            ),
            notifyCare: true,
            notifyDailySummary: true,
            notifyAiSuggestions: false,
            quietHours: const QuietHours(
              enabled: false,
              start: TimeOfDay(hour: 22, minute: 0),
              end: TimeOfDay(hour: 7, minute: 0),
            ),
            subscription: SubscriptionInfo(
              planName: 'Free',
              expireAt: DateTime.now().add(const Duration(days: 365)),
            ),
            language: 'vi',
            timezone: 'Asia/Ho_Chi_Minh',
            ),
          ) {
    // Load real user data from auth provider
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final authState = _ref.read(authProvider);
    final user = authState.user;

    if (user != null && authState.isAuthenticated) {
      final profile = UserProfile(
        fullName: (user['full_name'] as String?) ?? '',
        email: (user['email'] as String?) ?? '',
        phone: (user['phone_number'] as String?) ??
            (user['phone'] as String?) ?? '',
        businessName: (user['business_name'] as String?) ??
            (user['company_name'] as String?) ??
            'Chưa cập nhật',
      );
      state = state.copyWith(profile: profile);
    }
  }

  void updateProfile(UserProfile profile) => state = state.copyWith(profile: profile);

  void setNotifyCare(bool v) => state = state.copyWith(notifyCare: v);
  void setNotifyDailySummary(bool v) => state = state.copyWith(notifyDailySummary: v);
  void setNotifyAiSuggestions(bool v) => state = state.copyWith(notifyAiSuggestions: v);

  void setQuietEnabled(bool v) => state = state.copyWith(quietHours: state.quietHours.copyWith(enabled: v));
  void setQuietStart(TimeOfDay t) => state = state.copyWith(quietHours: state.quietHours.copyWith(start: t));
  void setQuietEnd(TimeOfDay t) => state = state.copyWith(quietHours: state.quietHours.copyWith(end: t));

  void setLanguage(String v) => state = state.copyWith(language: v);
  void setTimezone(String v) => state = state.copyWith(timezone: v);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});
