import 'dart:async';

/// Mock Node API Service for demo purposes
/// Replaces the Node API backend with in-memory data
class MockNodeApiService {
  // Singleton
  static final MockNodeApiService _instance = MockNodeApiService._internal();
  factory MockNodeApiService() => _instance;
  MockNodeApiService._internal() {
    _initializeMockData();
  }

  // In-memory database
  final Map<String, dynamic> _database = {};
  String? _currentUserId;

  void _initializeMockData() {
    // Mock users
    _database['users'] = [
      {
        'id': 'user-001',
        'email': 'sales@cuca.com',
        'phone_number': '0901234567',
        'full_name': 'Minh Sale',
        'role': 'sales',
        'is_active': true,
        'avatar_url': 'https://i.pravatar.cc/150?u=user-001',
      },
      {
        'id': 'user-002',
        'email': 'admin@cuca.com',
        'phone_number': '0909999999',
        'full_name': 'Admin User',
        'role': 'admin',
        'is_active': true,
      },
    ];

    // Mock customers
    _database['customers'] = [
      {
        'id': '1',
        'full_name': 'Nguyễn Văn A',
        'phone_number': '0901234567',
        'email': 'nguyenvana@email.com',
        'address': '123 Nguyễn Huệ, Q1, TP.HCM',
        'date_of_birth': '1985-05-15',
        'customer_type': 'vip',
        'customer_stage': 'explosion_point',
        'priority': 'high',
        'tags': ['hot_lead', 'referral'],
        'next_care_date': DateTime.now().toIso8601String(),
        'last_contact_date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'notes': 'Khách hàng tiềm năng cao, đang quan tâm căn 3PN',
        'assigned_to': 'user-001',
        'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'full_name': 'Trần Thị B',
        'phone_number': '0912345678',
        'email': 'tranthib@email.com',
        'address': '456 Lê Lợi, Q1, TP.HCM',
        'date_of_birth': '1990-08-20',
        'customer_type': 'regular',
        'customer_stage': 'research',
        'priority': 'medium',
        'tags': ['facebook_ads'],
        'next_care_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'last_contact_date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'notes': 'Đang so sánh với dự án khác',
        'assigned_to': 'user-001',
        'created_at': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '3',
        'full_name': 'Lê Văn C',
        'phone_number': '0923456789',
        'customer_type': 'potential',
        'customer_stage': 'have_needs',
        'priority': 'low',
        'tags': ['walk_in'],
        'next_care_date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'last_contact_date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'notes': 'Mới tìm hiểu, chưa có nhu cầu cụ thể',
        'assigned_to': 'user-001',
        'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '4',
        'full_name': 'Phạm Thị D',
        'phone_number': '0934567890',
        'email': 'phamthid@email.com',
        'address': '789 Trần Hưng Đạo, Q5, TP.HCM',
        'date_of_birth': '1988-03-10',
        'customer_type': 'vip',
        'customer_stage': 'after_sales',
        'priority': 'high',
        'tags': ['vip', 'repeat_customer'],
        'next_care_date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'last_contact_date': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
        'notes': 'Đã mua căn A1-05, đang hoàn tất thủ tục',
        'assigned_to': 'user-001',
        'created_at': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '5',
        'full_name': 'Bùi Thị H',
        'phone_number': '0978901234',
        'email': 'buithih@email.com',
        'date_of_birth': '1992-11-25',
        'customer_type': 'regular',
        'customer_stage': 'explosion_point',
        'priority': 'high',
        'tags': ['hot_lead', 'urgent'],
        'next_care_date': DateTime.now().toIso8601String(),
        'last_contact_date': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'notes': 'Rất quan tâm, cần liên hệ gấp trong hôm nay',
        'assigned_to': 'user-001',
        'created_at': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    // Mock notifications
    _database['notifications'] = [
      {
        'id': 'notif-001',
        'user_id': 'user-001',
        'title': 'Nhắc lịch chăm sóc khách hàng',
        'body': 'Khách Nguyễn Văn A cần được liên hệ trong hôm nay',
        'notification_type': 'care_reminder',
        'status': 'pending',
        'customer_id': '1',
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'notif-002',
        'user_id': 'user-001',
        'title': 'Phân tích AI mới có sẵn',
        'body': 'Phân tích cuộc trò chuyện với khách Trần Thị B đã hoàn tất',
        'notification_type': 'ai_analysis',
        'status': 'pending',
        'customer_id': '2',
        'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
    ];

    // Mock tasks
    _database['tasks'] = [
      {
        'id': 'task-001',
        'user_id': 'user-001',
        'customer_id': '1',
        'title': 'Gọi cho Nguyễn Văn A',
        'description': 'Tư vấn về căn 3PN tầng trung',
        'status': 'pending',
        'priority': 'high',
        'due_date': DateTime.now().add(const Duration(hours: 4)).toIso8601String(),
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'task-002',
        'user_id': 'user-001',
        'customer_id': '2',
        'title': 'Gửi tài liệu cho Trần Thị B',
        'description': 'Gửi brochure và bảng giá',
        'status': 'in_progress',
        'priority': 'medium',
        'due_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'created_at': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
      },
    ];

    // Mock chat sessions
    _database['chat_sessions'] = [
      {
        'id': 'session-001',
        'customer_id': '1',
        'source': 'zalo',
        'message_count': 25,
        'start_time': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'end_time': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'imported_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'analysis_status': 'completed',
      },
      {
        'id': 'session-002',
        'customer_id': '2',
        'source': 'messenger',
        'message_count': 12,
        'start_time': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'end_time': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'imported_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'analysis_status': 'completed',
      },
    ];

    // Mock chat messages
    _database['chat_messages'] = {
      'session-001': [
        {
          'id': 'msg-001',
          'session_id': 'session-001',
          'sender': 'customer',
          'message_text': 'Chào bạn, mình thấy thông tin về dự án trên Facebook',
          'message_type': 'text',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        },
        {
          'id': 'msg-002',
          'session_id': 'session-001',
          'sender': 'agent',
          'message_text': 'Chào anh, em là Minh từ CUCA. Dự án mình đang bán căn 2-3PN giá tốt',
          'message_type': 'text',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        },
        {
          'id': 'msg-003',
          'session_id': 'session-001',
          'sender': 'customer',
          'message_text': 'Giá căn 3PN khoảng bao nhiêu ạ? Anh đang quan tâm',
          'message_type': 'text',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        },
      ],
      'session-002': [
        {
          'id': 'msg-004',
          'session_id': 'session-002',
          'sender': 'customer',
          'message_text': 'Cho mình xin thông tin dự án',
          'message_type': 'text',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
      ],
    };

    // Mock templates
    _database['templates'] = [
      {
        'id': 'template-001',
        'name': 'Chào hàng mới',
        'category': 'outreach',
        'customer_stage': 'receive_info',
        'tone': 'friendly',
        'language': 'vi',
        'content': 'Chào {customer_name}, em là {agent_name} từ CUCA. Em thấy anh/chị quan tâm đến dự án...',
        'is_active': true,
      },
      {
        'id': 'template-002',
        'name': 'Nhắc lịch hẹn',
        'category': 'followup',
        'customer_stage': 'explosion_point',
        'tone': 'professional',
        'language': 'vi',
        'content': 'Chào {customer_name}, em nhắc nhở về lịch hẹn vào {appointment_time}...',
        'is_active': true,
      },
    ];

    // Mock purchases
    _database['purchases'] = [
      {
        'id': 'purchase-001',
        'customer_id': '4',
        'unit_code': 'A1-05',
        'unit_type': '2PN',
        'area': 65.5,
        'total_price': 3500000000,
        'status': 'processing',
        'purchase_date': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        'notes': 'Đã cọc 50 triệu',
      },
    ];

    // Mock stage history
    _database['stage_history'] = [
      {
        'id': 'history-001',
        'customer_id': '1',
        'from_stage': 'research',
        'to_stage': 'explosion_point',
        'reason': 'Khách hàng đã xem căn mẫu và quan tâm',
        'changed_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
    ];
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // API Methods

  Future<Map<String, dynamic>> getMe({required String accessToken}) async {
    await _delay();
    final users = _database['users'] as List;
    return users.first as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateMySettings({
    required String accessToken,
    required Map<String, dynamic> notificationPreferences,
  }) async {
    await _delay();
    return {'status': 'success', 'notification_preferences': notificationPreferences};
  }

  Future<Map<String, dynamic>> listCustomers({
    required String accessToken,
    Map<String, String>? queryParameters,
  }) async {
    await _delay();
    List customers = List.from(_database['customers'] as List);

    // Apply filters if provided
    if (queryParameters != null) {
      if (queryParameters['search'] != null) {
        final search = queryParameters['search']!.toLowerCase();
        customers = customers.where((c) =>
          (c['full_name'] as String).toLowerCase().contains(search) ||
          (c['phone_number'] as String).contains(search)
        ).toList();
      }
      if (queryParameters['customer_stage'] != null) {
        customers = customers.where((c) =>
          c['customer_stage'] == queryParameters['customer_stage']
        ).toList();
      }
      if (queryParameters['priority'] != null) {
        customers = customers.where((c) =>
          c['priority'] == queryParameters['priority']
        ).toList();
      }
    }

    return {
      'data': customers,
      'total': customers.length,
      'page': 1,
      'page_size': customers.length,
    };
  }

  Future<Map<String, dynamic>> getCustomer({
    required String accessToken,
    required String customerId,
  }) async {
    await _delay();
    final customers = _database['customers'] as List;
    final customer = customers.firstWhere(
      (c) => c['id'] == customerId,
      orElse: () => throw Exception('Customer not found'),
    );
    return customer as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createCustomer({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    await _delay();
    final newCustomer = {
      ...body,
      'id': 'customer-${DateTime.now().millisecondsSinceEpoch}',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'assigned_to': _currentUserId ?? 'user-001',
    };
    (_database['customers'] as List).add(newCustomer);
    return newCustomer;
  }

  Future<Map<String, dynamic>> updateCustomer({
    required String accessToken,
    required String customerId,
    required Map<String, dynamic> body,
  }) async {
    await _delay();
    final customers = _database['customers'] as List;
    final index = customers.indexWhere((c) => c['id'] == customerId);
    if (index == -1) throw Exception('Customer not found');

    final updated = {...customers[index] as Map<String, dynamic>, ...body};
    customers[index] = updated;
    return updated;
  }

  Future<void> deleteCustomer({
    required String accessToken,
    required String customerId,
  }) async {
    await _delay();
    final customers = _database['customers'] as List;
    customers.removeWhere((c) => c['id'] == customerId);
  }

  Future<Map<String, dynamic>> checkDuplicateCustomerPhone({
    required String accessToken,
    required String phone,
  }) async {
    await _delay();
    final customers = _database['customers'] as List;
    final exists = customers.any((c) => c['phone_number'] == phone);
    return {'exists': exists, 'phone': phone};
  }

  Future<Map<String, dynamic>> updateCustomerStage({
    required String accessToken,
    required String customerId,
    required String toStage,
    String? reason,
  }) async {
    await _delay();
    final customers = _database['customers'] as List;
    final index = customers.indexWhere((c) => c['id'] == customerId);
    if (index == -1) throw Exception('Customer not found');

    final customer = customers[index] as Map<String, dynamic>;
    final fromStage = customer['customer_stage'];
    customer['customer_stage'] = toStage;
    customer['updated_at'] = DateTime.now().toIso8601String();

    // Add to history
    (_database['stage_history'] as List).add({
      'id': 'history-${DateTime.now().millisecondsSinceEpoch}',
      'customer_id': customerId,
      'from_stage': fromStage,
      'to_stage': toStage,
      'reason': reason,
      'changed_at': DateTime.now().toIso8601String(),
    });

    return customer;
  }

  Future<Map<String, dynamic>> listCustomerStageHistory({
    required String accessToken,
    required String customerId,
    int? page,
    int? pageSize,
  }) async {
    await _delay();
    final history = _database['stage_history'] as List;
    final customerHistory = history.where((h) => h['customer_id'] == customerId).toList();

    return {
      'data': customerHistory,
      'total': customerHistory.length,
      'page': page ?? 1,
      'page_size': pageSize ?? customerHistory.length,
    };
  }

  Future<Map<String, dynamic>> listNotifications({
    required String accessToken,
    String? status,
    String? notificationType,
    int? page,
    int? pageSize,
  }) async {
    await _delay();
    List notifications = List.from(_database['notifications'] as List);

    if (_currentUserId != null) {
      notifications = notifications.where((n) => n['user_id'] == _currentUserId).toList();
    }

    if (status != null) {
      notifications = notifications.where((n) => n['status'] == status).toList();
    }
    if (notificationType != null) {
      notifications = notifications.where((n) => n['notification_type'] == notificationType).toList();
    }

    return {
      'data': notifications,
      'total': notifications.length,
      'page': page ?? 1,
      'page_size': pageSize ?? notifications.length,
    };
  }

  Future<Map<String, dynamic>> listTasks({
    required String accessToken,
    String? status,
    String? customerId,
    int? page,
    int? pageSize,
  }) async {
    await _delay();
    List tasks = List.from(_database['tasks'] as List);

    if (_currentUserId != null) {
      tasks = tasks.where((t) => t['user_id'] == _currentUserId).toList();
    }

    if (status != null) {
      tasks = tasks.where((t) => t['status'] == status).toList();
    }
    if (customerId != null) {
      tasks = tasks.where((t) => t['customer_id'] == customerId).toList();
    }

    return {
      'data': tasks,
      'total': tasks.length,
      'page': page ?? 1,
      'page_size': pageSize ?? tasks.length,
    };
  }

  Future<Map<String, dynamic>> listCustomerInteractions({
    required String accessToken,
    required String customerId,
    int? page,
    int? pageSize,
  }) async {
    await _delay();
    return {
      'data': [],
      'total': 0,
      'page': 1,
      'page_size': 10,
    };
  }

  Future<Map<String, dynamic>> createInteraction({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    await _delay();
    return {
      'id': 'interaction-${DateTime.now().millisecondsSinceEpoch}',
      ...body,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> importChatSession({
    required String accessToken,
    required String customerId,
    String? payloadText,
    Object? payloadJson,
  }) async {
    await _delay();
    final sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    // Parse messages
    List<dynamic> messages = [];
    if (payloadJson is List) {
      messages = payloadJson;
    } else if (payloadText != null) {
      // Simple parsing for demo
      final lines = payloadText.split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].trim().isNotEmpty) {
          messages.add({
            'sender': i % 2 == 0 ? 'customer' : 'agent',
            'message_text': lines[i].trim(),
            'message_type': 'text',
            'timestamp': now.toIso8601String(),
          });
        }
      }
    }

    // Store session
    (_database['chat_sessions'] as List).add({
      'id': sessionId,
      'customer_id': customerId,
      'source': 'imported',
      'message_count': messages.length,
      'start_time': now.toIso8601String(),
      'end_time': now.toIso8601String(),
      'imported_at': now.toIso8601String(),
      'analysis_status': 'pending',
    });

    // Store messages
    final messageList = <Map<String, dynamic>>[];
    for (var i = 0; i < messages.length; i++) {
      final msg = {
        'id': 'msg-$sessionId-$i',
        'session_id': sessionId,
        ...messages[i] as Map<String, dynamic>,
        'timestamp': now.toIso8601String(),
      };
      messageList.add(msg);
    }
    final messagesMap = _database['chat_messages'] as Map<String, dynamic>;
    messagesMap[sessionId] = messageList;

    return {
      'session': {
        'id': sessionId,
        'customer_id': customerId,
        'message_count': messages.length,
      },
      'warnings': <String>[],
    };
  }

  Future<Map<String, dynamic>> listChatSessions({
    required String accessToken,
    required String customerId,
    int? page,
    int? pageSize,
  }) async {
    await _delay();
    final sessions = _database['chat_sessions'] as List;
    final customerSessions = sessions
        .where((s) => s['customer_id'] == customerId)
        .toList();

    return {
      'data': customerSessions,
      'total': customerSessions.length,
      'page': page ?? 1,
      'page_size': pageSize ?? customerSessions.length,
    };
  }

  Future<Map<String, dynamic>> listChatMessages({
    required String accessToken,
    required String sessionId,
    int? page,
    int? pageSize,
  }) async {
    await _delay();
    final messagesMap = _database['chat_messages'] as Map<String, dynamic>;
    final messages = messagesMap[sessionId] as List? ?? [];

    return {
      'data': messages,
      'total': messages.length,
      'page': page ?? 1,
      'page_size': pageSize ?? messages.length,
    };
  }

  Future<Map<String, dynamic>> submitAiAnalysisFeedback({
    required String accessToken,
    required String analysisId,
    required String feedback,
    String? feedbackNotes,
  }) async {
    await _delay();
    return {
      'id': analysisId,
      'feedback': feedback,
      'feedback_notes': feedbackNotes,
      'submitted_at': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> listTemplates({
    required String accessToken,
    String? search,
    String? category,
    String? customerStage,
    String? tone,
    String? language,
    bool? isActive,
    int? page,
    int? pageSize,
  }) async {
    await _delay();
    List templates = List.from(_database['templates'] as List);

    if (isActive != null) {
      templates = templates.where((t) => t['is_active'] == isActive).toList();
    }
    if (category != null) {
      templates = templates.where((t) => t['category'] == category).toList();
    }
    if (customerStage != null) {
      templates = templates.where((t) => t['customer_stage'] == customerStage).toList();
    }

    return {
      'data': templates,
      'total': templates.length,
      'page': page ?? 1,
      'page_size': pageSize ?? templates.length,
    };
  }

  Future<Map<String, dynamic>> renderTemplate({
    required String accessToken,
    required String templateId,
    required String customerId,
    Map<String, dynamic>? variables,
    bool trackUsage = false,
  }) async {
    await _delay();
    final templates = _database['templates'] as List;
    final template = templates.firstWhere(
      (t) => t['id'] == templateId,
      orElse: () => throw Exception('Template not found'),
    ) as Map<String, dynamic>;

    String content = template['content'] as String;
    // Simple variable replacement
    variables?.forEach((key, value) {
      content = content.replaceAll('{$key}', value.toString());
    });

    return {
      'rendered_content': content,
      'template_id': templateId,
    };
  }

  Future<Map<String, dynamic>> listCustomerTasks({
    required String accessToken,
    required String customerId,
    int? page,
    int? pageSize,
  }) async {
    await _delay();
    final tasks = _database['tasks'] as List;
    final customerTasks = tasks
        .where((t) => t['customer_id'] == customerId)
        .toList();

    return {
      'data': customerTasks,
      'total': customerTasks.length,
      'page': page ?? 1,
      'page_size': pageSize ?? customerTasks.length,
    };
  }

  Future<Map<String, dynamic>> createTask({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    await _delay();
    final newTask = {
      ...body,
      'id': 'task-${DateTime.now().millisecondsSinceEpoch}',
      'user_id': _currentUserId ?? 'user-001',
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    };
    (_database['tasks'] as List).add(newTask);
    return newTask;
  }

  Future<Map<String, dynamic>> updateTaskStatus({
    required String accessToken,
    required String taskId,
    required String status,
  }) async {
    await _delay();
    final tasks = _database['tasks'] as List;
    final index = tasks.indexWhere((t) => t['id'] == taskId);
    if (index == -1) throw Exception('Task not found');

    (tasks[index] as Map<String, dynamic>)['status'] = status;
    return tasks[index] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listCustomerPurchases({
    required String accessToken,
    required String customerId,
    int? page,
    int? pageSize,
  }) async {
    await _delay();
    final purchases = _database['purchases'] as List;
    final customerPurchases = purchases
        .where((p) => p['customer_id'] == customerId)
        .toList();

    return {
      'data': customerPurchases,
      'total': customerPurchases.length,
      'page': page ?? 1,
      'page_size': pageSize ?? customerPurchases.length,
    };
  }

  Future<Map<String, dynamic>> createPurchase({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    await _delay();
    final newPurchase = {
      ...body,
      'id': 'purchase-${DateTime.now().millisecondsSinceEpoch}',
      'status': 'pending',
      'purchase_date': DateTime.now().toIso8601String(),
    };
    (_database['purchases'] as List).add(newPurchase);
    return newPurchase;
  }
}
