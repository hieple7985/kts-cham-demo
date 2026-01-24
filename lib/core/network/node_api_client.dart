import 'dart:convert';

import 'package:http/http.dart' as http;

class NodeApiException implements Exception {
  final int statusCode;
  final String message;

  const NodeApiException(this.statusCode, this.message);

  @override
  String toString() => 'NodeApiException($statusCode): $message';
}

class NodeApiClient {
  NodeApiClient({required String baseUrl})
      : _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');

  final String _baseUrl;

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalized')
        .replace(queryParameters: queryParameters);
  }

  Map<String, String> _headers(String accessToken) => {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>> _requestJson({
    required String method,
    required String path,
    required String accessToken,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    Set<int> ok = const {200},
  }) async {
    final uri = _uri(path, queryParameters);
    final req = http.Request(method, uri);
    req.headers.addAll(_headers(accessToken));
    if (body != null) {
      req.body = jsonEncode(body);
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (ok.contains(res.statusCode)) {
      if (res.body.isEmpty) return <String, dynamic>{};
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    if (res.statusCode == 404) {
      final json = res.body.isEmpty ? null : jsonDecode(res.body);
      final msg = json is Map<String, dynamic>
          ? (json['error']?.toString() ?? 'Not found')
          : 'Not found';
      throw NodeApiException(404, msg);
    }

    String message = res.body.isEmpty ? 'Request failed' : res.body;
    try {
      final json = jsonDecode(res.body);
      if (json is Map<String, dynamic>) {
        message = json['error']?.toString() ?? message;
      }
    } catch (_) {
      // ignore json parse errors
    }

    throw NodeApiException(res.statusCode, message);
  }

  Future<void> _requestEmpty({
    required String method,
    required String path,
    required String accessToken,
    Map<String, String>? queryParameters,
    Set<int> ok = const {204},
  }) async {
    final uri = _uri(path, queryParameters);
    final req = http.Request(method, uri);
    req.headers.addAll(_headers(accessToken));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (ok.contains(res.statusCode)) return;
    throw NodeApiException(
        res.statusCode, res.body.isEmpty ? 'Request failed' : res.body);
  }

  Future<Map<String, dynamic>> getMe({required String accessToken}) async {
    return _requestJson(
        method: 'GET',
        path: '/users/me',
        accessToken: accessToken,
        ok: const {200});
  }

  Future<Map<String, dynamic>> updateMySettings({
    required String accessToken,
    required Map<String, dynamic> notificationPreferences,
  }) async {
    return _requestJson(
      method: 'PUT',
      path: '/users/me/settings',
      accessToken: accessToken,
      body: {
        'notification_preferences': notificationPreferences,
      },
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> listCustomers({
    required String accessToken,
    Map<String, String>? queryParameters,
  }) async {
    return _requestJson(
      method: 'GET',
      path: '/customers',
      accessToken: accessToken,
      queryParameters: queryParameters,
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> getCustomer({
    required String accessToken,
    required String customerId,
  }) async {
    return _requestJson(
      method: 'GET',
      path: '/customers/$customerId',
      accessToken: accessToken,
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> createCustomer({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    return _requestJson(
      method: 'POST',
      path: '/customers',
      accessToken: accessToken,
      body: body,
      ok: const {201},
    );
  }

  Future<Map<String, dynamic>> updateCustomer({
    required String accessToken,
    required String customerId,
    required Map<String, dynamic> body,
  }) async {
    return _requestJson(
      method: 'PUT',
      path: '/customers/$customerId',
      accessToken: accessToken,
      body: body,
      ok: const {200},
    );
  }

  Future<void> deleteCustomer({
    required String accessToken,
    required String customerId,
  }) async {
    return _requestEmpty(
      method: 'DELETE',
      path: '/customers/$customerId',
      accessToken: accessToken,
      ok: const {204},
    );
  }

  Future<Map<String, dynamic>> checkDuplicateCustomerPhone({
    required String accessToken,
    required String phone,
  }) async {
    return _requestJson(
      method: 'GET',
      path: '/customers/check-duplicate',
      accessToken: accessToken,
      queryParameters: {'phone': phone},
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> updateCustomerStage({
    required String accessToken,
    required String customerId,
    required String toStage,
    String? reason,
  }) async {
    return _requestJson(
      method: 'PUT',
      path: '/customers/$customerId/stage',
      accessToken: accessToken,
      body: {
        'to_stage': toStage,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> listCustomerStageHistory({
    required String accessToken,
    required String customerId,
    int? page,
    int? pageSize,
  }) async {
    return _requestJson(
      method: 'GET',
      path: '/customers/$customerId/stage-history',
      accessToken: accessToken,
      queryParameters: {
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> listNotifications({
    required String accessToken,
    String? status,
    String? notificationType,
    int? page,
    int? pageSize,
  }) async {
    return _requestJson(
      method: 'GET',
      path: '/notifications',
      accessToken: accessToken,
      queryParameters: {
        if (status != null) 'status': status,
        if (notificationType != null) 'notification_type': notificationType,
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> listTasks({
    required String accessToken,
    String? status,
    String? customerId,
    int? page,
    int? pageSize,
  }) async {
    return _requestJson(
      method: 'GET',
      path: '/tasks',
      accessToken: accessToken,
      queryParameters: {
        if (status != null) 'status': status,
        if (customerId != null) 'customer_id': customerId,
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> listCustomerInteractions({
    required String accessToken,
    required String customerId,
    int? page,
    int? pageSize,
  }) async {
    return _requestJson(
      method: 'GET',
      path: '/customers/$customerId/interactions',
      accessToken: accessToken,
      queryParameters: {
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> createInteraction({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    return _requestJson(
      method: 'POST',
      path: '/interactions',
      accessToken: accessToken,
      body: body,
      ok: const {201},
    );
  }

  Future<Map<String, dynamic>> importChatSession({
    required String accessToken,
    required String customerId,
    String? payloadText,
    Object? payloadJson,
  }) async {
    return _requestJson(
      method: 'POST',
      path: '/customers/$customerId/chat-sessions',
      accessToken: accessToken,
      body: {
        if (payloadText != null) 'payload_text': payloadText,
        if (payloadJson != null) 'payload_json': payloadJson,
      },
      ok: const {201},
    );
  }

  Future<Map<String, dynamic>> listChatSessions({
    required String accessToken,
    required String customerId,
    int? page,
    int? pageSize,
  }) async {
    return _requestJson(
      method: 'GET',
      path: '/customers/$customerId/chat-sessions',
      accessToken: accessToken,
      queryParameters: {
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> listChatMessages({
    required String accessToken,
    required String sessionId,
    int? page,
    int? pageSize,
  }) async {
    return _requestJson(
      method: 'GET',
      path: '/chat-sessions/$sessionId/messages',
      accessToken: accessToken,
      queryParameters: {
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> submitAiAnalysisFeedback({
    required String accessToken,
    required String analysisId,
    required String feedback, // correct | incorrect | partially_correct
    String? feedbackNotes,
  }) async {
    return _requestJson(
      method: 'POST',
      path: '/ai-analyses/$analysisId/feedback',
      accessToken: accessToken,
      body: {
        'feedback': feedback,
        if (feedbackNotes != null) 'feedback_notes': feedbackNotes,
      },
      ok: const {200},
    );
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
    return _requestJson(
      method: 'GET',
      path: '/templates',
      accessToken: accessToken,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (category != null) 'category': category,
        if (customerStage != null) 'customer_stage': customerStage,
        if (tone != null) 'tone': tone,
        if (language != null) 'language': language,
        if (isActive != null) 'is_active': isActive ? 'true' : 'false',
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> renderTemplate({
    required String accessToken,
    required String templateId,
    required String customerId,
    Map<String, dynamic>? variables,
    bool trackUsage = false,
  }) async {
    return _requestJson(
      method: 'POST',
      path: '/templates/$templateId/render',
      accessToken: accessToken,
      body: {
        'customer_id': customerId,
        if (variables != null) 'variables': variables,
        'track_usage': trackUsage,
      },
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> listCustomerTasks({
    required String accessToken,
    required String customerId,
    int? page,
    int? pageSize,
  }) async {
    return _requestJson(
      method: 'GET',
      path: '/customers/$customerId/tasks',
      accessToken: accessToken,
      queryParameters: {
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> createTask({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    return _requestJson(
      method: 'POST',
      path: '/tasks',
      accessToken: accessToken,
      body: body,
      ok: const {201},
    );
  }

  Future<Map<String, dynamic>> updateTaskStatus({
    required String accessToken,
    required String taskId,
    required String status,
  }) async {
    return _requestJson(
      method: 'PUT',
      path: '/tasks/$taskId/status',
      accessToken: accessToken,
      body: {'status': status},
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> listCustomerPurchases({
    required String accessToken,
    required String customerId,
    int? page,
    int? pageSize,
  }) async {
    return _requestJson(
      method: 'GET',
      path: '/customers/$customerId/purchases',
      accessToken: accessToken,
      queryParameters: {
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
      ok: const {200},
    );
  }

  Future<Map<String, dynamic>> createPurchase({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    return _requestJson(
      method: 'POST',
      path: '/purchases',
      accessToken: accessToken,
      body: body,
      ok: const {201},
    );
  }
}
