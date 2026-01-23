import 'dart:async';

/// Mock Supabase Config for Demo
///
/// This demo uses mock data and services instead of real Supabase backend.
/// No API keys or credentials needed.
class SupabaseConfig {
  static bool _initialized = false;

  static Future<void> initialize() async {
    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 100));
    _initialized = true;
    print('Demo mode: Using mock Supabase (no real backend)');
  }

  static bool get isInitialized => _initialized;

  /// Mock auth client for demo
  static MockSupabaseAuthClient get auth => MockSupabaseAuthClient._instance;
}

/// Mock Supabase Auth Client
class MockSupabaseAuthClient {
  static final MockSupabaseAuthClient _instance = MockSupabaseAuthClient._internal();
  factory MockSupabaseAuthClient() => _instance;
  MockSupabaseAuthClient._internal();

  MockSession? currentSession;
  MockUser? currentUser;

  void signInWithMockUser({
    required String id,
    required String email,
    required String phoneNumber,
    required String fullName,
  }) {
    currentUser = MockUser(
      id: id,
      email: email,
      phoneNumber: phoneNumber,
      fullName: fullName,
    );
    currentSession = MockSession(
      accessToken: 'mock-access-token-${DateTime.now().millisecondsSinceEpoch}',
      user: currentUser!.toMap(),
    );
  }
}

class MockSession {
  final String accessToken;
  final Map<String, dynamic> user;

  MockSession({required this.accessToken, required this.user});
}

class MockUser {
  final String id;
  final String email;
  final String? phoneNumber;
  final String fullName;

  MockUser({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.fullName,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'phone_number': phoneNumber,
    'full_name': fullName,
    'user': toMap(),
  };
}
