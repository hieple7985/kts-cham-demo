import 'package:flutter/material.dart';

class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.businessName,
  });

  final String fullName;
  final String email;
  final String phone;
  final String businessName;

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? businessName,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
    );
  }
}

class SubscriptionInfo {
  const SubscriptionInfo({
    required this.planName,
    required this.expireAt,
  });

  final String planName;
  final DateTime expireAt;

  int get daysLeft => expireAt.difference(DateTime.now()).inDays;
}

class QuietHours {
  const QuietHours({
    required this.enabled,
    required this.start,
    required this.end,
  });

  final bool enabled;
  final TimeOfDay start;
  final TimeOfDay end;

  QuietHours copyWith({
    bool? enabled,
    TimeOfDay? start,
    TimeOfDay? end,
  }) {
    return QuietHours(
      enabled: enabled ?? this.enabled,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}

class SettingsState {
  const SettingsState({
    required this.profile,
    required this.notifyCare,
    required this.notifyDailySummary,
    required this.notifyAiSuggestions,
    required this.quietHours,
    required this.subscription,
    required this.language,
    required this.timezone,
  });

  final UserProfile profile;
  final bool notifyCare;
  final bool notifyDailySummary;
  final bool notifyAiSuggestions;
  final QuietHours quietHours;
  final SubscriptionInfo subscription;
  final String language;
  final String timezone;

  SettingsState copyWith({
    UserProfile? profile,
    bool? notifyCare,
    bool? notifyDailySummary,
    bool? notifyAiSuggestions,
    QuietHours? quietHours,
    SubscriptionInfo? subscription,
    String? language,
    String? timezone,
  }) {
    return SettingsState(
      profile: profile ?? this.profile,
      notifyCare: notifyCare ?? this.notifyCare,
      notifyDailySummary: notifyDailySummary ?? this.notifyDailySummary,
      notifyAiSuggestions: notifyAiSuggestions ?? this.notifyAiSuggestions,
      quietHours: quietHours ?? this.quietHours,
      subscription: subscription ?? this.subscription,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
    );
  }
}

