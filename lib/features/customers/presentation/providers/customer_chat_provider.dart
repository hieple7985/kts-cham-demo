import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/supabase/supabase_config.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/node_api_provider.dart';
import '../models/customer_chat_models.dart';

class CustomerChatState {
  const CustomerChatState({
    required this.sessions,
    required this.isLoadingSessions,
    required this.selectedSessionId,
    required this.messages,
    required this.isLoadingMessages,
    required this.lastImportWarnings,
  });

  final List<ChatSessionSummary> sessions;
  final bool isLoadingSessions;
  final String? selectedSessionId;
  final List<ChatMessageItem> messages;
  final bool isLoadingMessages;
  final List<String> lastImportWarnings;

  factory CustomerChatState.initial() => const CustomerChatState(
        sessions: [],
        isLoadingSessions: false,
        selectedSessionId: null,
        messages: [],
        isLoadingMessages: false,
        lastImportWarnings: [],
      );

  CustomerChatState copyWith({
    List<ChatSessionSummary>? sessions,
    bool? isLoadingSessions,
    String? selectedSessionId,
    List<ChatMessageItem>? messages,
    bool? isLoadingMessages,
    List<String>? lastImportWarnings,
  }) {
    return CustomerChatState(
      sessions: sessions ?? this.sessions,
      isLoadingSessions: isLoadingSessions ?? this.isLoadingSessions,
      selectedSessionId: selectedSessionId ?? this.selectedSessionId,
      messages: messages ?? this.messages,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      lastImportWarnings: lastImportWarnings ?? this.lastImportWarnings,
    );
  }
}

class CustomerChatNotifier extends StateNotifier<CustomerChatState> {
  CustomerChatNotifier(this._ref, this._customerId)
      : super(CustomerChatState.initial()) {
    refreshSessions();
  }

  final Ref _ref;
  final String _customerId;

  String? _accessTokenOrNull() {
    final token = SupabaseConfig.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) return null;
    return token;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  ChatSessionSummary _mapSession(dynamic raw) {
    final m = raw as Map<String, dynamic>;
    return ChatSessionSummary(
      id: m['id']?.toString() ?? '',
      source: m['source']?.toString() ?? 'unknown',
      messageCount: (m['message_count'] as num?)?.toInt() ?? 0,
      startTime: _parseDate(m['start_time']),
      endTime: _parseDate(m['end_time']),
      importedAt: _parseDate(m['imported_at']),
      analysisStatus: m['analysis_status']?.toString(),
    );
  }

  ChatMessageItem _mapMessage(dynamic raw) {
    final m = raw as Map<String, dynamic>;
    return ChatMessageItem(
      id: m['id']?.toString() ?? '',
      sender: m['sender']?.toString() ?? 'customer',
      messageText: m['message_text']?.toString() ?? '',
      timestamp: _parseDate(m['timestamp']) ?? DateTime.now(),
      messageType: m['message_type']?.toString() ?? 'text',
    );
  }

  Future<void> refreshSessions() async {
    if (!AppConfig.useSupabaseAuth) return;
    final token = _accessTokenOrNull();
    if (token == null) return;

    state = state.copyWith(isLoadingSessions: true);
    try {
      final api = _ref.read(nodeApiClientProvider);
      final res = await api.listChatSessions(
          accessToken: token, customerId: _customerId, pageSize: 50);
      final list = (res['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_mapSession)
          .toList();
      state = state.copyWith(sessions: list, isLoadingSessions: false);
    } catch (_) {
      state = state.copyWith(isLoadingSessions: false);
    }
  }

  Future<void> importFromText(String payloadText) async {
    if (!AppConfig.useSupabaseAuth) return;
    final token = _accessTokenOrNull();
    if (token == null) return;

    final api = _ref.read(nodeApiClientProvider);
    final res = await api.importChatSession(
      accessToken: token,
      customerId: _customerId,
      payloadText: payloadText,
    );

    final warnings = (res['warnings'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    state = state.copyWith(lastImportWarnings: warnings);
    await refreshSessions();

    final session = res['session'];
    if (session is Map<String, dynamic>) {
      final id = session['id']?.toString();
      if (id != null && id.isNotEmpty) {
        await openSession(id);
      }
    }
  }

  Future<void> importFromJson(Object payloadJson) async {
    if (!AppConfig.useSupabaseAuth) return;
    final token = _accessTokenOrNull();
    if (token == null) return;

    final api = _ref.read(nodeApiClientProvider);
    final res = await api.importChatSession(
      accessToken: token,
      customerId: _customerId,
      payloadJson: payloadJson,
    );

    final warnings = (res['warnings'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    state = state.copyWith(lastImportWarnings: warnings);
    await refreshSessions();

    final session = res['session'];
    if (session is Map<String, dynamic>) {
      final id = session['id']?.toString();
      if (id != null && id.isNotEmpty) {
        await openSession(id);
      }
    }
  }

  Future<void> openSession(String sessionId) async {
    if (!AppConfig.useSupabaseAuth) return;
    final token = _accessTokenOrNull();
    if (token == null) return;

    state = state.copyWith(
        selectedSessionId: sessionId,
        isLoadingMessages: true,
        messages: const []);
    try {
      final api = _ref.read(nodeApiClientProvider);
      final res = await api.listChatMessages(
          accessToken: token, sessionId: sessionId, pageSize: 200);
      final list = (res['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_mapMessage)
          .toList();
      state = state.copyWith(messages: list, isLoadingMessages: false);
    } catch (_) {
      state = state.copyWith(isLoadingMessages: false);
    }
  }
}

final customerChatProvider = StateNotifierProvider.family<CustomerChatNotifier,
    CustomerChatState, String>((ref, customerId) {
  return CustomerChatNotifier(ref, customerId);
});
