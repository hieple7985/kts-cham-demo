import 'dart:async';
import 'dart:math';

/// Mock Realtime Service for demo purposes
/// Simulates Supabase realtime subscriptions
class MockRealtimeService {
  // Singleton
  static final MockRealtimeService _instance = MockRealtimeService._internal();
  factory MockRealtimeService() => _instance;
  MockRealtimeService._internal();

  final Map<String, List<Function(Map<String, dynamic>)>> _subscriptions = {};
  final Map<String, Timer?> _timers = {};
  final _random = Random();

  /// Subscribe to customer changes
  String subscribeToCustomers({
    required String userId,
    required Function(Map<String, dynamic>) callback,
  }) {
    final subscriptionId = 'customers-$userId-${DateTime.now().millisecondsSinceEpoch}';
    _subscriptions[subscriptionId] = [callback];

    // Simulate random updates every 30-60 seconds
    _startRandomUpdates(subscriptionId, 'customers', callback);

    return subscriptionId;
  }

  /// Subscribe to notifications
  String subscribeToNotifications({
    required String userId,
    required Function(Map<String, dynamic>) callback,
  }) {
    final subscriptionId = 'notifications-$userId-${DateTime.now().millisecondsSinceEpoch}';
    _subscriptions[subscriptionId] = [callback];

    // Simulate incoming notifications
    _startRandomNotifications(subscriptionId, callback);

    return subscriptionId;
  }

  /// Subscribe to tasks
  String subscribeToTasks({
    required String userId,
    required Function(Map<String, dynamic>) callback,
  }) {
    final subscriptionId = 'tasks-$userId-${DateTime.now().millisecondsSinceEpoch}';
    _subscriptions[subscriptionId] = [callback];

    // Simulate task updates
    _startRandomTaskUpdates(subscriptionId, callback);

    return subscriptionId;
  }

  void _startRandomUpdates(String subscriptionId, String table, Function(Map<String, dynamic>) callback) {
    _timers[subscriptionId] = Timer.periodic(
      Duration(seconds: 30 + _random.nextInt(30)),
      (_) {
        // 30% chance of generating an update
        if (_random.nextDouble() < 0.3) {
          final event = _generateRandomEvent(table);
          callback(event);
        }
      },
    );
  }

  void _startRandomNotifications(String subscriptionId, Function(Map<String, dynamic>) callback) {
    // Simulate new notification every 2-5 minutes
    _timers[subscriptionId] = Timer.periodic(
      Duration(seconds: 120 + _random.nextInt(180)),
      (_) {
        final notification = _generateNotification();
        callback({
          'event_type': 'INSERT',
          'table': 'notifications',
          'record': notification,
        });
      },
    );
  }

  void _startRandomTaskUpdates(String subscriptionId, Function(Map<String, dynamic>) callback) {
    _timers[subscriptionId] = Timer.periodic(
      Duration(seconds: 45 + _random.nextInt(45)),
      (_) {
        // 20% chance of generating a task update
        if (_random.nextDouble() < 0.2) {
          final event = _generateRandomEvent('tasks');
          callback(event);
        }
      },
    );
  }

  Map<String, dynamic> _generateRandomEvent(String table) {
    final eventTypes = ['INSERT', 'UPDATE', 'DELETE'];
    final eventType = eventTypes[_random.nextInt(eventTypes.length)];

    if (table == 'customers') {
      return _generateCustomerEvent(eventType);
    } else if (table == 'tasks') {
      return _generateTaskEvent(eventType);
    }

    return {
      'event_type': eventType,
      'table': table,
      'record': {'id': 'mock-${DateTime.now().millisecondsSinceEpoch}'},
    };
  }

  Map<String, dynamic> _generateCustomerEvent(String eventType) {
    final customers = [
      {'id': '1', 'full_name': 'Nguyễn Văn A', 'customer_stage': 'explosion_point'},
      {'id': '2', 'full_name': 'Trần Thị B', 'customer_stage': 'research'},
      {'id': '3', 'full_name': 'Lê Văn C', 'customer_stage': 'have_needs'},
      {'id': '4', 'full_name': 'Phạm Thị D', 'customer_stage': 'after_sales'},
      {'id': '5', 'full_name': 'Bùi Thị H', 'customer_stage': 'explosion_point'},
    ];

    final customer = Map<String, dynamic>.from(
      customers[_random.nextInt(customers.length)]
    );

    // Add some random changes
    if (eventType == 'UPDATE') {
      customer['last_contact_date'] = DateTime.now().toIso8601String();
      customer['updated_at'] = DateTime.now().toIso8601String();

      // Sometimes change stage
      if (_random.nextDouble() < 0.3) {
        final stages = ['receive_info', 'have_needs', 'research', 'explosion_point', 'sales', 'after_sales'];
        customer['customer_stage'] = stages[_random.nextInt(stages.length)];
      }
    }

    return {
      'event_type': eventType,
      'table': 'customers',
      'record': customer,
      'old_record': eventType == 'UPDATE' ? {...customer, 'customer_stage': 'research'} : null,
    };
  }

  Map<String, dynamic> _generateTaskEvent(String eventType) {
    final tasks = [
      {'id': 'task-001', 'title': 'Gọi cho Nguyễn Văn A', 'status': 'pending'},
      {'id': 'task-002', 'title': 'Gửi tài liệu cho Trần Thị B', 'status': 'in_progress'},
    ];

    final task = Map<String, dynamic>.from(
      _random.nextDouble() < 0.5 ? tasks[0] : tasks[1]
    );

    if (eventType == 'UPDATE') {
      // Sometimes complete a task
      if (_random.nextDouble() < 0.5) {
        task['status'] = 'completed';
        task['completed_at'] = DateTime.now().toIso8601String();
      }
    }

    return {
      'event_type': eventType,
      'table': 'tasks',
      'record': task,
    };
  }

  Map<String, dynamic> _generateNotification() {
    final notificationTypes = [
      {
        'type': 'care_reminder',
        'title': 'Nhắc lịch chăm sóc',
        'body': 'Khách hàng cần được liên hệ trong hôm nay',
      },
      {
        'type': 'ai_analysis',
        'title': 'Phân tích AI mới',
        'body': 'Phân tích cuộc trò chuyện đã hoàn tất',
      },
      {
        'type': 'task_due',
        'title': 'Task đến hạn',
        'body': 'Một task của bạn sẽ đến hạn trong 1 giờ',
      },
      {
        'type': 'customer_update',
        'title': 'Cập nhật khách hàng',
        'body': 'Khách hàng vừa trả lời tin nhắn mới',
      },
    ];

    final type = notificationTypes[_random.nextInt(notificationTypes.length)];
    final customers = ['Nguyễn Văn A', 'Trần Thị B', 'Lê Văn C', 'Phạm Thị D'];
    final customerName = customers[_random.nextInt(customers.length)];

    return {
      'id': 'notif-${DateTime.now().millisecondsSinceEpoch}',
      'user_id': 'user-001',
      'title': type['title'],
      'body': type['body'].replaceFirst('khách hàng', customerName),
      'notification_type': type['type'],
      'status': 'pending',
      'customer_id': '${_random.nextInt(5) + 1}',
      'customer_name': customerName,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Unsubscribe from a channel
  void unsubscribe(String subscriptionId) {
    _subscriptions.remove(subscriptionId);
    _timers[subscriptionId]?.cancel();
    _timers.remove(subscriptionId);
  }

  /// Unsubscribe all channels
  void unsubscribeAll() {
    for (final timer in _timers.values) {
      timer?.cancel();
    }
    _subscriptions.clear();
    _timers.clear();
  }

  /// Simulate a manual trigger (for demo purposes)
  void triggerEvent(String table, Map<String, dynamic> data) {
    final subscriptions = _subscriptions.values;
    for (final callbacks in subscriptions) {
      for (final callback in callbacks) {
        callback({
          'event_type': 'INSERT',
          'table': table,
          'record': data,
        });
      }
    }
  }

  /// Dispose the service
  void dispose() {
    unsubscribeAll();
  }
}

/// Mock Realtime Channel for compatibility
class MockRealtimeChannel {
  final String channelName;
  final Map<String, Function(Map<String, dynamic>)> _callbacks = {};

  MockRealtimeChannel(this.channelName);

  MockRealtimeChannel onPostgresChanges({
    required String event,
    required String schema,
    required String table,
    Map<String, dynamic>? filter,
    required Function(Map<String, dynamic>) callback,
  }) {
    _callbacks['${table}_$event'] = callback;
    return this;
  }

  Future<void> subscribe() async {
    // Simulate subscription delay
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> unsubscribe() async {
    _callbacks.clear();
  }

  /// For testing: trigger a callback manually
  void trigger(Map<String, dynamic> data) {
    for (final callback in _callbacks.values) {
      callback(data);
    }
  }
}

/// Mock Realtime Client
class MockRealtimeClient {
  static final MockRealtimeClient _instance = MockRealtimeClient._internal();
  factory MockRealtimeClient() => _instance;
  MockRealtimeClient._internal();

  final Map<String, MockRealtimeChannel> _channels = {};

  MockRealtimeChannel channel(String name) {
    if (!_channels.containsKey(name)) {
      _channels[name] = MockRealtimeChannel(name);
    }
    return _channels[name]!;
  }

  Future<void> close() async {
    for (final channel in _channels.values) {
      await channel.unsubscribe();
    }
    _channels.clear();
  }
}
