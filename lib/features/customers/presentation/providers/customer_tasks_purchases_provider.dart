import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/supabase/supabase_config.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/node_api_provider.dart';
import '../../../../core/network/node_api_client.dart';
import '../models/customer_tasks_purchases_models.dart';
import 'customers_provider.dart';

class CustomerTasksPurchasesState {
  const CustomerTasksPurchasesState({
    required this.isLoadingTasks,
    required this.tasks,
    required this.isLoadingPurchases,
    required this.purchases,
    required this.error,
  });

  final bool isLoadingTasks;
  final List<CustomerTaskItem> tasks;
  final bool isLoadingPurchases;
  final List<CustomerPurchaseItem> purchases;
  final String? error;

  factory CustomerTasksPurchasesState.initial() =>
      const CustomerTasksPurchasesState(
        isLoadingTasks: false,
        tasks: [],
        isLoadingPurchases: false,
        purchases: [],
        error: null,
      );

  CustomerTasksPurchasesState copyWith({
    bool? isLoadingTasks,
    List<CustomerTaskItem>? tasks,
    bool? isLoadingPurchases,
    List<CustomerPurchaseItem>? purchases,
    String? error,
  }) {
    return CustomerTasksPurchasesState(
      isLoadingTasks: isLoadingTasks ?? this.isLoadingTasks,
      tasks: tasks ?? this.tasks,
      isLoadingPurchases: isLoadingPurchases ?? this.isLoadingPurchases,
      purchases: purchases ?? this.purchases,
      error: error,
    );
  }
}

class CustomerTasksPurchasesNotifier
    extends StateNotifier<CustomerTasksPurchasesState> {
  CustomerTasksPurchasesNotifier(this._ref, this._customerId)
      : super(CustomerTasksPurchasesState.initial()) {
    unawaited(refreshAll());
  }

  final Ref _ref;
  final String _customerId;

  String? _accessTokenOrNull() {
    final token = SupabaseConfig.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) return null;
    return token;
  }

  CustomerTaskItem _mapTask(Map<String, dynamic> raw) {
    return CustomerTaskItem(
      id: raw['id']?.toString() ?? '',
      taskType: raw['task_type']?.toString() ?? 'follow_up',
      title: raw['title']?.toString() ?? '',
      status: raw['status']?.toString() ?? 'pending',
      priority: raw['priority']?.toString() ?? 'medium',
      dueDate: raw['due_date']?.toString() ?? '',
      description: raw['description']?.toString(),
    );
  }

  CustomerPurchaseItem _mapPurchase(Map<String, dynamic> raw) {
    return CustomerPurchaseItem(
      id: raw['id']?.toString() ?? '',
      productName: raw['product_name']?.toString() ?? '',
      finalPrice: (raw['final_price'] as num?)?.toDouble() ??
          (raw['price'] as num?)?.toDouble() ??
          0,
      paymentStatus: raw['payment_status']?.toString() ?? 'pending',
      purchaseDate: raw['purchase_date']?.toString() ?? '',
      notes: raw['notes']?.toString(),
    );
  }

  Future<void> refreshAll() async {
    await Future.wait([
      refreshTasks(),
      refreshPurchases(),
    ]);
  }

  Future<void> refreshTasks() async {
    if (!AppConfig.useSupabaseAuth) return;
    final token = _accessTokenOrNull();
    if (token == null) return;

    state = state.copyWith(isLoadingTasks: true, error: null);
    try {
      final api = _ref.read(nodeApiClientProvider);
      final res = await api.listCustomerTasks(
          accessToken: token, customerId: _customerId, pageSize: 50);
      final list = (res['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_mapTask)
          .toList();
      state = state.copyWith(isLoadingTasks: false, tasks: list);
    } catch (e) {
      state = state.copyWith(isLoadingTasks: false, error: e.toString());
    }
  }

  Future<void> refreshPurchases() async {
    if (!AppConfig.useSupabaseAuth) return;
    final token = _accessTokenOrNull();
    if (token == null) return;

    state = state.copyWith(isLoadingPurchases: true, error: null);
    try {
      final api = _ref.read(nodeApiClientProvider);
      final res = await api.listCustomerPurchases(
          accessToken: token, customerId: _customerId, pageSize: 50);
      final list = (res['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_mapPurchase)
          .toList();
      state = state.copyWith(isLoadingPurchases: false, purchases: list);
    } catch (e) {
      state = state.copyWith(isLoadingPurchases: false, error: e.toString());
    }
  }

  Future<void> createTask({
    required String taskType,
    required String title,
    required String dueDate,
    String? description,
    String priority = 'medium',
  }) async {
    final token = _accessTokenOrNull();
    if (token == null) return;

    final api = _ref.read(nodeApiClientProvider);
    await api.createTask(
      accessToken: token,
      body: {
        'customer_id': _customerId,
        'task_type': taskType,
        'title': title,
        'due_date': dueDate,
        'priority': priority,
        if (description != null) 'description': description,
      },
    );
    await refreshTasks();
  }

  Future<void> markTaskCompleted(String taskId) async {
    final token = _accessTokenOrNull();
    if (token == null) return;
    final api = _ref.read(nodeApiClientProvider);
    await api.updateTaskStatus(
        accessToken: token, taskId: taskId, status: 'completed');
    await refreshTasks();
  }

  Future<void> createPurchase({
    required String productName,
    required double price,
    required String purchaseDate,
    String paymentStatus = 'pending',
    String? notes,
  }) async {
    final token = _accessTokenOrNull();
    if (token == null) return;

    final api = _ref.read(nodeApiClientProvider);
    try {
      await api.createPurchase(
        accessToken: token,
        body: {
          'customer_id': _customerId,
          'product_name': productName,
          'purchase_date': purchaseDate,
          'price': price,
          'payment_status': paymentStatus,
          if (notes != null) 'notes': notes,
        },
      );
      await refreshPurchases();
      await _ref.read(customersProvider.notifier).fetchById(_customerId);
    } on NodeApiException catch (e) {
      throw Exception(e.message);
    }
  }
}

final customerTasksPurchasesProvider = StateNotifierProvider.family<
    CustomerTasksPurchasesNotifier, CustomerTasksPurchasesState, String>(
  (ref, customerId) => CustomerTasksPurchasesNotifier(ref, customerId),
);
