import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../config/supabase/supabase_config.dart';
import '../config/app_config.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/customers/presentation/providers/customers_provider.dart';
import '../../features/home/presentation/providers/home_reminders_provider.dart';

class RealtimeSyncController {
  RealtimeSyncController(this._ref) {
    _authListener = _ref.listen<AuthState>(
      authProvider,
      (previous, next) => _syncFromAuth(next),
      fireImmediately: true,
    );
  }

  final Ref _ref;

  ProviderSubscription<AuthState>? _authListener;
  final List<RealtimeChannel> _channels = [];
  String? _userId;

  Timer? _customersRefreshDebounce;
  Timer? _homeRefreshDebounce;

  String? _profileUserIdFromAuthState(AuthState authState) {
    final root = authState.user;
    if (root == null) return null;

    final nested = root['user'];
    if (nested is Map<String, dynamic>) {
      final id = nested['id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    }

    final id = root['id']?.toString();
    if (id != null && id.isNotEmpty) return id;

    return null;
  }

  void _syncFromAuth(AuthState authState) {
    if (!AppConfig.useSupabaseAuth || !authState.isAuthenticated) {
      stop();
      return;
    }

    // IMPORTANT:
    // - Supabase JWT `sub` is the auth user id (auth.users.id)
    // - Our DB tables (customers.assigned_to, notifications.user_id, tasks.user_id) reference public.users.id
    // So realtime filters must use the public profile id, not auth user id.
    final profileUserId = _profileUserIdFromAuthState(authState);
    if (profileUserId == null) {
      stop();
      return;
    }

    if (_userId == profileUserId && _channels.isNotEmpty) return;

    stop();
    _userId = profileUserId;
    _start(profileUserId);
  }

  void _start(String userId) {
    final client = SupabaseConfig.client;

    void scheduleCustomersRefresh() {
      _customersRefreshDebounce?.cancel();
      _customersRefreshDebounce = Timer(const Duration(milliseconds: 300), () {
        unawaited(_ref.read(customersProvider.notifier).refresh());
      });
    }

    void scheduleHomeRefresh() {
      _homeRefreshDebounce?.cancel();
      _homeRefreshDebounce = Timer(const Duration(milliseconds: 300), () {
        unawaited(_ref.read(homeRemindersProvider.notifier).refresh());
      });
    }

    final customersChannel = client
        .channel('public:customers:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'customers',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'assigned_to',
            value: userId,
          ),
          callback: (_) => scheduleCustomersRefresh(),
        );

    final notificationsChannel = client
        .channel('public:notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => scheduleHomeRefresh(),
        );

    final tasksChannel = client
        .channel('public:tasks:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => scheduleHomeRefresh(),
        );

    _channels.addAll([customersChannel, notificationsChannel, tasksChannel]);

    for (final ch in _channels) {
      ch.subscribe();
    }
  }

  void stop() {
    _customersRefreshDebounce?.cancel();
    _customersRefreshDebounce = null;
    _homeRefreshDebounce?.cancel();
    _homeRefreshDebounce = null;

    for (final ch in _channels) {
      unawaited(ch.unsubscribe());
    }
    _channels.clear();
    _userId = null;
  }

  void dispose() {
    stop();
    _authListener?.close();
    _authListener = null;
  }
}

final realtimeSyncProvider = Provider<RealtimeSyncController>((ref) {
  final controller = RealtimeSyncController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});
