import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/supabase/supabase_config.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/node_api_provider.dart';

class CustomerAiState {
  const CustomerAiState({
    required this.isRunning,
    required this.analyses,
    required this.analysisIds,
    required this.feedbackByType,
    required this.modelName,
    required this.sessionId,
    required this.error,
  });

  final bool isRunning;
  final Map<String, Map<String, dynamic>> analyses; // analysis_type -> output_data
  final Map<String, String> analysisIds; // analysis_type -> ai_analyses.id
  final Map<String, String?> feedbackByType; // analysis_type -> feedback
  final String? modelName;
  final String? sessionId;
  final String? error;

  factory CustomerAiState.initial() => const CustomerAiState(
        isRunning: false,
        analyses: {},
        analysisIds: {},
        feedbackByType: {},
        modelName: null,
        sessionId: null,
        error: null,
      );

  CustomerAiState copyWith({
    bool? isRunning,
    Map<String, Map<String, dynamic>>? analyses,
    Map<String, String>? analysisIds,
    Map<String, String?>? feedbackByType,
    String? modelName,
    String? sessionId,
    String? error,
  }) {
    return CustomerAiState(
      isRunning: isRunning ?? this.isRunning,
      analyses: analyses ?? this.analyses,
      analysisIds: analysisIds ?? this.analysisIds,
      feedbackByType: feedbackByType ?? this.feedbackByType,
      modelName: modelName ?? this.modelName,
      sessionId: sessionId ?? this.sessionId,
      error: error,
    );
  }
}

class CustomerAiNotifier extends StateNotifier<CustomerAiState> {
  CustomerAiNotifier(this._ref, this._customerId) : super(CustomerAiState.initial());

  final Ref _ref;
  final String _customerId;

  String? _accessTokenOrNull() {
    final token = SupabaseConfig.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) return null;
    return token;
  }

  Future<void> runAnalysis({bool force = false}) async {
    if (!AppConfig.useSupabaseAuth) return;

    final token = _accessTokenOrNull();
    if (token == null) {
      state = state.copyWith(error: 'Chưa đăng nhập.');
      return;
    }

    state = state.copyWith(isRunning: true, error: null);
    try {
      final res = await SupabaseConfig.client.functions.invoke(
        'ai-chat-analysis',
        body: {
          'customer_id': _customerId,
          if (force) 'force': true,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = res.data;
      if (data is! Map<String, dynamic>) {
        state = state.copyWith(isRunning: false, error: 'AI response invalid.');
        return;
      }

      String? modelName;
      final created = data['created'];
      if (created is List && created.isNotEmpty) {
        final first = created.first;
        if (first is Map) {
          modelName = first['model_name']?.toString();
        }
      }

      final analysesList = data['analyses'];
      final byType = <String, Map<String, dynamic>>{};
      final ids = <String, String>{};
      final feedback = <String, String?>{};
      if (analysesList is List) {
        for (final raw in analysesList) {
          if (raw is! Map<String, dynamic>) continue;
          final t = raw['analysis_type']?.toString();
          final out = raw['output_data'];
          if (t == null || t.isEmpty) continue;
          final id = raw['id']?.toString();
          if (id != null && id.isNotEmpty) ids[t] = id;
          feedback[t] = raw['feedback']?.toString();
          if (out is Map<String, dynamic>) {
            byType[t] = out;
          } else {
            byType[t] = {'raw': out};
          }
        }
      }

      state = state.copyWith(
        isRunning: false,
        analyses: byType,
        analysisIds: ids,
        feedbackByType: feedback,
        modelName: modelName ?? data['model_name']?.toString(),
        sessionId: data['session_id']?.toString(),
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isRunning: false, error: e.toString());
    }
  }

  Future<void> submitFeedback({
    required String analysisId,
    required String feedback,
    String? feedbackNotes,
  }) async {
    if (!AppConfig.useSupabaseAuth) return;
    final token = _accessTokenOrNull();
    if (token == null) return;

    final api = _ref.read(nodeApiClientProvider);
    await api.submitAiAnalysisFeedback(
      accessToken: token,
      analysisId: analysisId,
      feedback: feedback,
      feedbackNotes: feedbackNotes,
    );
  }

  void setLocalFeedback({required String analysisType, required String? feedback}) {
    state = state.copyWith(
      feedbackByType: {
        ...state.feedbackByType,
        analysisType: feedback,
      },
    );
  }
}

final customerAiProvider =
    StateNotifierProvider.family<CustomerAiNotifier, CustomerAiState, String>((ref, customerId) {
  return CustomerAiNotifier(ref, customerId);
});
