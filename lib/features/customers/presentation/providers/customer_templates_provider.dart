import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/supabase/supabase_config.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/node_api_provider.dart';
import '../models/template_models.dart';

class CustomerTemplatesState {
  const CustomerTemplatesState({
    required this.isLoading,
    required this.templates,
    required this.selectedTemplateId,
    required this.renderedContent,
    required this.renderedSubject,
    required this.error,
  });

  final bool isLoading;
  final List<MessageTemplate> templates;
  final String? selectedTemplateId;
  final String? renderedContent;
  final String? renderedSubject;
  final String? error;

  factory CustomerTemplatesState.initial() => const CustomerTemplatesState(
        isLoading: false,
        templates: [],
        selectedTemplateId: null,
        renderedContent: null,
        renderedSubject: null,
        error: null,
      );

  CustomerTemplatesState copyWith({
    bool? isLoading,
    List<MessageTemplate>? templates,
    String? selectedTemplateId,
    String? renderedContent,
    String? renderedSubject,
    String? error,
  }) {
    return CustomerTemplatesState(
      isLoading: isLoading ?? this.isLoading,
      templates: templates ?? this.templates,
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
      renderedContent: renderedContent ?? this.renderedContent,
      renderedSubject: renderedSubject ?? this.renderedSubject,
      error: error,
    );
  }
}

class CustomerTemplatesNotifier extends StateNotifier<CustomerTemplatesState> {
  CustomerTemplatesNotifier(this._ref, this._customerId) : super(CustomerTemplatesState.initial()) {
    unawaited(refresh());
  }

  final Ref _ref;
  final String _customerId;

  String? _accessTokenOrNull() {
    final token = SupabaseConfig.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) return null;
    return token;
  }

  MessageTemplate _mapTemplate(Map<String, dynamic> raw) {
    return MessageTemplate(
      id: raw['id']?.toString() ?? '',
      templateName: raw['template_name']?.toString() ?? '',
      category: raw['category']?.toString() ?? '',
      content: raw['content']?.toString() ?? '',
      subject: raw['subject']?.toString(),
      tone: raw['tone']?.toString(),
      language: raw['language']?.toString(),
      variables: raw['variables'] is List ? (raw['variables'] as List).map((e) => e.toString()).toList() : const [],
      usageCount: (raw['usage_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> refresh() async {
    if (!AppConfig.useSupabaseAuth) return;
    final token = _accessTokenOrNull();
    if (token == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = _ref.read(nodeApiClientProvider);
      final res = await api.listTemplates(accessToken: token, isActive: true, pageSize: 50);
      final list = (res['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_mapTemplate)
          .toList();
      state = state.copyWith(isLoading: false, templates: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectTemplate(String templateId) {
    state = state.copyWith(
      selectedTemplateId: templateId,
      renderedContent: null,
      renderedSubject: null,
      error: null,
    );
  }

  Future<void> renderSelected({bool trackUsage = true, Map<String, dynamic>? variables}) async {
    if (!AppConfig.useSupabaseAuth) return;
    final token = _accessTokenOrNull();
    if (token == null) return;
    final templateId = state.selectedTemplateId;
    if (templateId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = _ref.read(nodeApiClientProvider);
      final res = await api.renderTemplate(
        accessToken: token,
        templateId: templateId,
        customerId: _customerId,
        variables: variables,
        trackUsage: trackUsage,
      );

      final rendered = res['rendered'] as Map<String, dynamic>? ?? const {};
      state = state.copyWith(
        isLoading: false,
        renderedSubject: rendered['subject']?.toString(),
        renderedContent: rendered['content']?.toString(),
      );

      // Refresh to reflect updated usage_count when trackUsage=true.
      if (trackUsage) {
        unawaited(refresh());
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final customerTemplatesProvider =
    StateNotifierProvider.family<CustomerTemplatesNotifier, CustomerTemplatesState, String>((ref, customerId) {
  return CustomerTemplatesNotifier(ref, customerId);
});

