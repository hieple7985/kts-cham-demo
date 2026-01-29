import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/supabase/supabase_config.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/node_api_provider.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../models/home_reminder.dart';

class HomeRemindersData {
  const HomeRemindersData({
    required this.reminders,
    required this.unreadNotifications,
    required this.overdueTasks,
  });

  final List<HomeReminder> reminders;
  final int unreadNotifications;
  final int overdueTasks;

  int get badgeCount => unreadNotifications + overdueTasks;
}

class HomeRemindersNotifier
    extends StateNotifier<AsyncValue<HomeRemindersData>> {
  HomeRemindersNotifier(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  final Ref _ref;

  String? _accessTokenOrNull() {
    final token = SupabaseConfig.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) return null;
    return token;
  }

  List<HomeReminder> _mapToReminders({
    required List<dynamic> notifications,
    required List<dynamic> tasks,
  }) {
    final customers = _ref.read(customersProvider).maybeWhen(
          data: (data) => data.customers,
          orElse: () => const [],
        );

    String nameOf(String customerId) {
      for (final c in customers) {
        if (c.id == customerId) return c.fullName;
      }
      return 'Customer';
    }

    ReminderStage stageFromPriority(dynamic priority) {
      return priority == 'high' ? ReminderStage.hot : ReminderStage.care;
    }

    final reminders = <HomeReminder>[];

    for (final raw in notifications) {
      if (raw is! Map<String, dynamic>) continue;
      final customerId = raw['customer_id']?.toString();
      if (customerId == null || customerId.isEmpty) continue;

      final id = raw['id']?.toString() ?? '';
      final title = raw['title']?.toString() ?? 'Thông báo';
      final content = raw['content']?.toString() ?? '';
      final scheduled = raw['scheduled_time']?.toString();
      final created = raw['created_at']?.toString();

      final dueAt = DateTime.tryParse(scheduled ?? '') ??
          DateTime.tryParse(created ?? '') ??
          DateTime.now();

      reminders.add(
        HomeReminder(
          id: 'notification_$id',
          customerId: customerId,
          customerName: nameOf(customerId),
          stage: stageFromPriority(raw['priority']),
          reason: content.trim().isNotEmpty ? '$title — $content' : title,
          dueAt: dueAt,
          deepLink: raw['deep_link']?.toString(),
        ),
      );
    }

    for (final raw in tasks) {
      if (raw is! Map<String, dynamic>) continue;
      final customerId = raw['customer_id']?.toString();
      if (customerId == null || customerId.isEmpty) continue;

      final id = raw['id']?.toString() ?? '';
      final title = raw['title']?.toString() ?? 'Task';
      final due = raw['due_date']?.toString();
      final created = raw['created_at']?.toString();
      final dueAt = DateTime.tryParse(due ?? '') ??
          DateTime.tryParse(created ?? '') ??
          DateTime.now();

      reminders.add(
        HomeReminder(
          id: 'task_$id',
          customerId: customerId,
          customerName: nameOf(customerId),
          stage: stageFromPriority(raw['priority']),
          reason: 'Overdue: $title',
          dueAt: dueAt,
        ),
      );
    }

    reminders.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return reminders;
  }

  Future<void> refresh() async {
    if (!AppConfig.useSupabaseAuth) {
      state = const AsyncValue.data(
        HomeRemindersData(
            reminders: [], unreadNotifications: 0, overdueTasks: 0),
      );
      return;
    }

    final token = _accessTokenOrNull();
    if (token == null) {
      state = const AsyncValue.data(
        HomeRemindersData(
            reminders: [], unreadNotifications: 0, overdueTasks: 0),
      );
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final api = _ref.read(nodeApiClientProvider);

      final notificationsRes = await api.listNotifications(
        accessToken: token,
        status: 'unread',
        pageSize: 50,
      );
      final tasksRes = await api.listTasks(
        accessToken: token,
        status: 'overdue',
        pageSize: 50,
      );

      final notifications =
          notificationsRes['data'] as List<dynamic>? ?? const [];
      final tasks = tasksRes['data'] as List<dynamic>? ?? const [];

      final notificationsMeta =
          notificationsRes['meta'] as Map<String, dynamic>? ?? const {};
      final tasksMeta = tasksRes['meta'] as Map<String, dynamic>? ?? const {};

      final unreadNotifications =
          (notificationsMeta['total'] as num?)?.toInt() ?? notifications.length;
      final overdueTasks =
          (tasksMeta['total'] as num?)?.toInt() ?? tasks.length;

      return HomeRemindersData(
        reminders: _mapToReminders(notifications: notifications, tasks: tasks),
        unreadNotifications: unreadNotifications,
        overdueTasks: overdueTasks,
      );
    });
  }
}

final homeRemindersProvider =
    StateNotifierProvider<HomeRemindersNotifier, AsyncValue<HomeRemindersData>>(
        (ref) {
  return HomeRemindersNotifier(ref);
});
