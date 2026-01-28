import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/supabase/supabase_config.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/node_api_client.dart';
import '../../../../core/network/node_api_provider.dart';
import '../../domain/models/customer_model.dart';

class CustomersData {
  const CustomersData({
    required this.customers,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  final List<Customer> customers;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  CustomersData copyWith({
    List<Customer>? customers,
    int? total,
    int? page,
    int? pageSize,
    bool? hasMore,
  }) {
    return CustomersData(
      customers: customers ?? this.customers,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class _CustomerLocalExtras {
  _CustomerLocalExtras({
    this.additionalPhones = const [],
    this.zaloLink,
    this.facebookLink,
    this.interactions = const [],
    this.transactions = const [],
    this.aiChat = const [],
  });

  final List<String> additionalPhones;
  final String? zaloLink;
  final String? facebookLink;
  final List<Interaction> interactions;
  final List<TransactionEntry> transactions;
  final List<AiChatMessage> aiChat;
}

class CustomersNotifier extends StateNotifier<AsyncValue<CustomersData>> {
  CustomersNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchFirstPage();
  }

  final Ref _ref;

  String _search = '';
  String? _customerStage;

  int _page = 1;
  int _pageSize = 20;
  int _total = 0;
  bool _hasMore = false;

  final Map<String, _CustomerLocalExtras> _extras = {};

  NodeApiClient get _api => _ref.read(nodeApiClientProvider);

  String? _accessTokenOrNull() {
    final token = SupabaseConfig.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) return null;
    return token;
  }

  String _requireAccessToken() {
    return _accessTokenOrNull() ??
        (throw const NodeApiException(
            401, 'Not authenticated. Please sign in again.'));
  }

  CustomerStage _parseStage(dynamic value) {
    switch (value) {
      case 'receive_info':
        return CustomerStage.receiveInfo;
      case 'have_needs':
        return CustomerStage.haveNeeds;
      case 'research':
        return CustomerStage.research;
      case 'explosion_point':
        return CustomerStage.explosionPoint;
      case 'sales':
        return CustomerStage.sales;
      case 'after_sales':
        return CustomerStage.afterSales;
      case 'repeat':
        return CustomerStage.repeat;
      default:
        return CustomerStage.receiveInfo;
    }
  }

  InteractionType _parseInteractionType(dynamic value) {
    switch (value) {
      case 'call':
        return InteractionType.call;
      case 'sms':
      case 'email':
        return InteractionType.message;
      case 'zalo':
        return InteractionType.zalo;
      case 'meeting':
        return InteractionType.meeting;
      case 'note':
        return InteractionType.note;
      default:
        return InteractionType.note;
    }
  }

  String? _toApiInteractionType(InteractionType type) {
    switch (type) {
      case InteractionType.call:
        return 'call';
      case InteractionType.message:
        return 'sms';
      case InteractionType.zalo:
        return 'zalo';
      case InteractionType.meeting:
        return 'meeting';
      case InteractionType.note:
        return 'note';
      case InteractionType.facebook:
        return null;
    }
  }

  String? _toApiStage(CustomerStage stage) {
    switch (stage) {
      case CustomerStage.receiveInfo:
        return 'receive_info';
      case CustomerStage.haveNeeds:
        return 'have_needs';
      case CustomerStage.research:
        return 'research';
      case CustomerStage.explosionPoint:
        return 'explosion_point';
      case CustomerStage.sales:
        return 'sales';
      case CustomerStage.afterSales:
        return 'after_sales';
      case CustomerStage.repeat:
        return 'repeat';
      case CustomerStage.lost:
        return null;
    }
  }

  String _toLegacyPhone(String raw) {
    final trimmed = raw.toString().trim();
    if (trimmed.startsWith('+84')) {
      final national = trimmed.substring(3);
      return '0$national';
    }
    return trimmed;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  DateTime? _parseDateOnly(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isNotEmpty) {
      // Backend returns YYYY-MM-DD; parse as local midnight.
      final parts = value.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.tryParse(value);
    }
    return null;
  }

  Customer _mapCustomer(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const NodeApiException(500, 'Invalid customer payload');
    }

    final id = raw['id']?.toString() ?? '';
    final stage = _parseStage(raw['customer_stage']);
    final extras = _extras[id];

    final primaryPhone = _toLegacyPhone(raw['phone_number'] ?? '');
    final secondary = raw['secondary_phone']?.toString();
    final additionalPhones = [
      if (secondary != null && secondary.trim().isNotEmpty)
        _toLegacyPhone(secondary),
      ...(extras?.additionalPhones ?? const <String>[]),
    ];

    return Customer(
      id: id,
      fullName: raw['full_name']?.toString() ?? '',
      phoneNumber: primaryPhone,
      additionalPhones: additionalPhones,
      email: raw['email']?.toString(),
      stage: stage,
      tags: (raw['tags'] is List)
          ? (raw['tags'] as List).map((e) => e.toString()).toList()
          : const [],
      source: raw['source']?.toString(),
      notes: raw['notes']?.toString(),
      lastContactDate: _parseDate(raw['last_contact_date']),
      nextCareDate: _parseDate(raw['next_care_date']),
      totalSpent: (raw['total_spent'] as num?)?.toDouble(),
      lastPurchaseDate: _parseDateOnly(raw['last_purchase_date']),
      zaloLink: extras?.zaloLink,
      facebookLink: extras?.facebookLink,
      interactions: extras?.interactions ?? const [],
      transactions: extras?.transactions ?? const [],
      aiChat: extras?.aiChat ?? const [],
    );
  }

  StageChange _mapStageHistory(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const NodeApiException(500, 'Invalid stage history payload');
    }

    return StageChange(
      id: raw['id']?.toString() ?? '',
      from: _parseStage(raw['from_stage']),
      to: _parseStage(raw['to_stage']),
      reason: raw['reason']?.toString(),
      timestamp: _parseDate(raw['created_at']) ?? DateTime.now(),
    );
  }

  Interaction _mapInteraction(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const NodeApiException(500, 'Invalid interaction payload');
    }

    final subject = raw['subject']?.toString();
    final content = raw['content']?.toString();

    final merged = [
      if (subject != null && subject.trim().isNotEmpty) subject.trim(),
      if (content != null && content.trim().isNotEmpty) content.trim(),
    ].join('\n');

    return Interaction(
      id: raw['id']?.toString() ?? '',
      type: _parseInteractionType(raw['interaction_type']),
      content: merged.isNotEmpty ? merged : '(no content)',
      timestamp: _parseDate(raw['interaction_date']) ?? DateTime.now(),
    );
  }

  CustomersData _dataOrEmpty() {
    return state.value ??
        const CustomersData(
          customers: [],
          total: 0,
          page: 1,
          pageSize: 20,
          hasMore: false,
        );
  }

  CustomersData _mockCustomersData() {
    final now = DateTime.now();
    final customers = <Customer>[
      Customer(
        id: 'demo_1',
        fullName: 'Nguyễn Văn Minh',
        phoneNumber: '0912345678',
        stage: CustomerStage.research,
        tags: const ['VIP', 'Facebook'],
        notes: 'Demo mode (no auth): dùng để xem UI.',
        lastContactDate: now.subtract(const Duration(days: 1)),
        source: 'Facebook',
        additionalPhones: const ['0900111222'],
      ),
      Customer(
        id: 'demo_2',
        fullName: 'Trần Thị B',
        phoneNumber: '0987654321',
        stage: CustomerStage.haveNeeds,
        tags: const ['Zalo'],
        notes: 'Demo mode (no auth): dữ liệu giả lập.',
        nextCareDate: now.add(const Duration(days: 1)),
        source: 'Zalo',
      ),
    ];

    _total = customers.length;
    _page = 1;
    _pageSize = customers.length;
    _hasMore = false;

    return CustomersData(
      customers: customers,
      total: _total,
      page: _page,
      pageSize: _pageSize,
      hasMore: _hasMore,
    );
  }

  Future<void> fetchFirstPage({
    String search = '',
    String? customerStage,
    int pageSize = 20,
  }) async {
    _search = search;
    _customerStage = customerStage;
    _page = 1;
    _pageSize = pageSize;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final token = _accessTokenOrNull();
      if (token == null) {
        return _mockCustomersData();
      }

      final res = await _api.listCustomers(
        accessToken: token,
        queryParameters: {
          'page': '1',
          'page_size': '$_pageSize',
          if (_search.trim().isNotEmpty) 'search': _search.trim(),
          if (_customerStage != null) 'customer_stage': _customerStage!,
        },
      );

      final data = (res['data'] as List<dynamic>? ?? const []);
      final customers = data.map(_mapCustomer).toList();

      final meta = res['meta'] as Map<String, dynamic>? ?? const {};
      _total = (meta['total'] as num?)?.toInt() ?? customers.length;
      _page = (meta['page'] as num?)?.toInt() ?? 1;
      _pageSize = (meta['page_size'] as num?)?.toInt() ?? _pageSize;
      _hasMore = customers.length < _total;

      return CustomersData(
        customers: customers,
        total: _total,
        page: _page,
        pageSize: _pageSize,
        hasMore: _hasMore,
      );
    });
  }

  Future<void> loadMore() async {
    final current = _dataOrEmpty();
    if (!_hasMore) return;

    state = AsyncValue.data(current.copyWith(hasMore: _hasMore));

    final nextPage = _page + 1;
    final next = await AsyncValue.guard(() async {
      final token = _accessTokenOrNull();
      if (token == null) {
        return current.copyWith(hasMore: false);
      }
      final res = await _api.listCustomers(
        accessToken: token,
        queryParameters: {
          'page': '$nextPage',
          'page_size': '$_pageSize',
          if (_search.trim().isNotEmpty) 'search': _search.trim(),
          if (_customerStage != null) 'customer_stage': _customerStage!,
        },
      );

      final data = (res['data'] as List<dynamic>? ?? const []);
      final newCustomers = data.map(_mapCustomer).toList();

      final meta = res['meta'] as Map<String, dynamic>? ?? const {};
      _total = (meta['total'] as num?)?.toInt() ?? _total;
      _page = (meta['page'] as num?)?.toInt() ?? nextPage;
      _pageSize = (meta['page_size'] as num?)?.toInt() ?? _pageSize;
      _hasMore = current.customers.length + newCustomers.length < _total;

      return current.copyWith(
        customers: [...current.customers, ...newCustomers],
        total: _total,
        page: _page,
        pageSize: _pageSize,
        hasMore: _hasMore,
      );
    });

    state = next;
  }

  Future<void> refresh() async {
    await fetchFirstPage(
        search: _search, customerStage: _customerStage, pageSize: _pageSize);
  }

  Customer? getById(String customerId) {
    final current = state.value;
    if (current == null) return null;
    return current.customers.cast<Customer?>().firstWhere(
          (c) => c?.id == customerId,
          orElse: () => null,
        );
  }

  Future<Customer?> fetchById(String customerId) async {
    final current = _dataOrEmpty();
    try {
      final token = _requireAccessToken();
      final res =
          await _api.getCustomer(accessToken: token, customerId: customerId);
      final customerRaw = res['customer'];
      final customer = _mapCustomer(customerRaw);

      final next = [
        for (final c in current.customers)
          if (c.id == customerId) customer else c,
      ];
      state = AsyncValue.data(current.copyWith(customers: next));
      return customer;
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchStageHistory(String customerId) async {
    final current = _dataOrEmpty();
    final idx = current.customers.indexWhere((c) => c.id == customerId);
    if (idx == -1) return;

    final token = _requireAccessToken();
    final res = await _api.listCustomerStageHistory(
        accessToken: token, customerId: customerId);

    final list = (res['data'] as List<dynamic>? ?? const [])
        .map(_mapStageHistory)
        .toList();
    final customer = current.customers[idx];
    final updated = customer.copyWith(stageHistory: list);

    final next = [...current.customers];
    next[idx] = updated;
    state = AsyncValue.data(current.copyWith(customers: next));
  }

  Future<void> fetchInteractions(String customerId, {int pageSize = 50}) async {
    if (!AppConfig.useSupabaseAuth) return;
    final token = _accessTokenOrNull();
    if (token == null) return;

    final res = await _api.listCustomerInteractions(
      accessToken: token,
      customerId: customerId,
      pageSize: pageSize,
    );

    final list = (res['data'] as List<dynamic>? ?? const [])
        .map(_mapInteraction)
        .toList();

    final existing = _extras[customerId] ?? _CustomerLocalExtras();
    _extras[customerId] = _CustomerLocalExtras(
      additionalPhones: existing.additionalPhones,
      zaloLink: existing.zaloLink,
      facebookLink: existing.facebookLink,
      interactions: list,
      transactions: existing.transactions,
      aiChat: existing.aiChat,
    );

    _emitLocalMerge(customerId);
  }

  Future<Customer> createCustomer({
    required String fullName,
    required String phoneNumber,
    CustomerStage stage = CustomerStage.receiveInfo,
    String? notes,
    String? source,
    List<String> tags = const [],
    List<String> additionalPhones = const [],
    String? zaloLink,
    String? facebookLink,
  }) async {
    final token = _accessTokenOrNull();
    if (token == null) {
      final current = _dataOrEmpty();
      final id = 'demo_${DateTime.now().millisecondsSinceEpoch}';
      final customer = Customer(
        id: id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        additionalPhones: additionalPhones,
        stage: stage,
        notes: notes,
        source: source,
        tags: tags,
        zaloLink: zaloLink,
        facebookLink: facebookLink,
      );
      state = AsyncValue.data(
        current.copyWith(customers: [customer, ...current.customers]),
      );
      return customer;
    }
    final stageApi = _toApiStage(stage);
    if (stageApi == null) {
      throw const NodeApiException(400, 'Stage not supported by backend');
    }

    final res = await _api.createCustomer(
      accessToken: token,
      body: {
        'full_name': fullName,
        'phone_number': phoneNumber,
        if (notes != null) 'notes': notes,
        if (source != null) 'source': source,
        if (tags.isNotEmpty) 'tags': tags,
        'customer_stage': stageApi,
        if (additionalPhones.isNotEmpty)
          'secondary_phone': additionalPhones.first,
        if (zaloLink != null && zaloLink.trim().isNotEmpty)
          'zalo_id': zaloLink.trim(),
      },
    );

    final rawCustomer = res['customer'];
    final customer = _mapCustomer(rawCustomer);

    _extras[customer.id] = _CustomerLocalExtras(
      additionalPhones:
          additionalPhones.length <= 1 ? const [] : additionalPhones.sublist(1),
      zaloLink: zaloLink,
      facebookLink: facebookLink,
    );

    final current = _dataOrEmpty();
    state = AsyncValue.data(
      current.copyWith(customers: [customer, ...current.customers]),
    );

    return customer;
  }

  Future<Customer> updateCustomer({
    required String customerId,
    String? fullName,
    String? phoneNumber,
    CustomerStage? stage,
    String? notes,
    String? source,
    List<String>? tags,
    List<String>? additionalPhones,
    String? zaloLink,
    String? facebookLink,
  }) async {
    final token = _accessTokenOrNull();
    if (token == null) {
      final current = _dataOrEmpty();
      final idx = current.customers.indexWhere((c) => c.id == customerId);
      if (idx == -1) {
        throw const NodeApiException(404, 'Customer not found');
      }
      final previous = current.customers[idx];
      final nextCustomer = previous.copyWith(
        fullName: fullName ?? previous.fullName,
        phoneNumber: phoneNumber ?? previous.phoneNumber,
        stage: stage ?? previous.stage,
        notes: notes ?? previous.notes,
        source: source ?? previous.source,
        tags: tags ?? previous.tags,
        additionalPhones: additionalPhones ?? previous.additionalPhones,
        zaloLink: zaloLink ?? previous.zaloLink,
        facebookLink: facebookLink ?? previous.facebookLink,
      );
      final nextList = [...current.customers];
      nextList[idx] = nextCustomer;
      state = AsyncValue.data(current.copyWith(customers: nextList));
      return nextCustomer;
    }

    final payload = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (notes != null) 'notes': notes,
      if (source != null) 'source': source,
      if (tags != null) 'tags': tags,
      if (stage != null) 'customer_stage': _toApiStage(stage),
      if (additionalPhones != null && additionalPhones.isNotEmpty)
        'secondary_phone': additionalPhones.first,
      if (zaloLink != null && zaloLink.trim().isNotEmpty)
        'zalo_id': zaloLink.trim(),
    };

    if (payload['customer_stage'] == null && stage != null) {
      throw const NodeApiException(400, 'Stage not supported by backend');
    }

    final res = await _api.updateCustomer(
        accessToken: token, customerId: customerId, body: payload);
    final customer = _mapCustomer(res['customer']);

    final existing = _extras[customerId] ?? _CustomerLocalExtras();
    _extras[customerId] = _CustomerLocalExtras(
      additionalPhones: additionalPhones != null
          ? (additionalPhones.length <= 1
              ? const []
              : additionalPhones.sublist(1))
          : existing.additionalPhones,
      zaloLink: zaloLink ?? existing.zaloLink,
      facebookLink: facebookLink ?? existing.facebookLink,
      interactions: existing.interactions,
      transactions: existing.transactions,
      aiChat: existing.aiChat,
    );

    final current = _dataOrEmpty();
    final next = [
      for (final c in current.customers)
        if (c.id == customerId) customer else c,
    ];
    state = AsyncValue.data(current.copyWith(customers: next));
    return customer;
  }

  Future<void> deleteCustomer(String customerId) async {
    final token = _accessTokenOrNull();
    if (token != null) {
      await _api.deleteCustomer(accessToken: token, customerId: customerId);
    }

    final current = _dataOrEmpty();
    _extras.remove(customerId);
    state = AsyncValue.data(
      current.copyWith(
          customers:
              current.customers.where((c) => c.id != customerId).toList()),
    );
  }

  Future<void> changeStage({
    required String customerId,
    required CustomerStage to,
    String? reason,
  }) async {
    final token = _accessTokenOrNull();
    if (token == null) {
      final current = _dataOrEmpty();
      final idx = current.customers.indexWhere((c) => c.id == customerId);
      if (idx == -1) return;
      final customer = current.customers[idx];
      if (customer.stage == to) return;
      final entry = StageChange(
        id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
        from: customer.stage,
        to: to,
        reason: reason,
        timestamp: DateTime.now(),
      );
      final updated = customer
          .copyWith(stage: to, stageHistory: [entry, ...customer.stageHistory]);
      final next = [...current.customers];
      next[idx] = updated;
      state = AsyncValue.data(current.copyWith(customers: next));
      return;
    }
    final stageApi = _toApiStage(to);
    if (stageApi == null) {
      throw const NodeApiException(400, 'Stage not supported by backend');
    }

    final res = await _api.updateCustomerStage(
      accessToken: token,
      customerId: customerId,
      toStage: stageApi,
      reason: reason,
    );

    final current = _dataOrEmpty();
    final idx = current.customers.indexWhere((c) => c.id == customerId);
    if (idx == -1) return;

    final customer = _mapCustomer(res['customer']);
    final stageHistoryRaw = res['stage_history'];
    final stageHistory =
        stageHistoryRaw == null ? null : _mapStageHistory(stageHistoryRaw);

    final previous = current.customers[idx];
    final updated = customer.copyWith(
      stageHistory: stageHistory != null
          ? [stageHistory, ...previous.stageHistory]
          : previous.stageHistory,
    );

    final next = [...current.customers];
    next[idx] = updated;
    state = AsyncValue.data(current.copyWith(customers: next));
  }

  // Prototype-local by default; when Supabase auth is on, also sync to Node API.
  void addInteraction(String customerId, Interaction interaction) {
    final existing = _extras[customerId] ?? _CustomerLocalExtras();

    _extras[customerId] = _CustomerLocalExtras(
      additionalPhones: existing.additionalPhones,
      zaloLink: existing.zaloLink,
      facebookLink: existing.facebookLink,
      interactions: [interaction, ...existing.interactions],
      transactions: existing.transactions,
      aiChat: existing.aiChat,
    );
    _emitLocalMerge(customerId);

    if (!AppConfig.useSupabaseAuth) return;
    final token = _accessTokenOrNull();
    if (token == null) return;

    final apiType = _toApiInteractionType(interaction.type);
    if (apiType == null) return;

    unawaited(
      Future<void>(() async {
        try {
          await _api.createInteraction(
            accessToken: token,
            body: {
              'customer_id': customerId,
              'interaction_type': apiType,
              'interaction_date': interaction.timestamp.toIso8601String(),
              'content': interaction.content,
            },
          );
          await fetchInteractions(customerId);
          await fetchById(customerId);
        } catch (_) {
          // Best-effort: keep UI responsive; detailed error is surfaced by explicit flows.
        }
      }),
    );
  }

  Future<void> createInteractionRemote({
    required String customerId,
    required InteractionType type,
    required String content,
    required DateTime timestamp,
  }) async {
    if (!AppConfig.useSupabaseAuth) {
      addInteraction(
        customerId,
        Interaction(
          id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          content: content,
          timestamp: timestamp,
        ),
      );
      return;
    }

    final token = _requireAccessToken();
    final apiType = _toApiInteractionType(type);
    if (apiType == null) {
      throw const NodeApiException(
          400, 'Interaction type not supported by backend');
    }

    await _api.createInteraction(
      accessToken: token,
      body: {
        'customer_id': customerId,
        'interaction_type': apiType,
        'interaction_date': timestamp.toIso8601String(),
        'content': content,
      },
    );

    await fetchInteractions(customerId);
    await fetchById(customerId);
  }

  void updateInteraction(String customerId, Interaction updated) {
    final existing = _extras[customerId] ?? _CustomerLocalExtras();
    final next = existing.interactions
        .map((i) => i.id == updated.id ? updated : i)
        .toList();
    _extras[customerId] = _CustomerLocalExtras(
      additionalPhones: existing.additionalPhones,
      zaloLink: existing.zaloLink,
      facebookLink: existing.facebookLink,
      interactions: next,
      transactions: existing.transactions,
      aiChat: existing.aiChat,
    );
    _emitLocalMerge(customerId);
  }

  void deleteInteraction(String customerId, String interactionId) {
    final existing = _extras[customerId] ?? _CustomerLocalExtras();
    final next =
        existing.interactions.where((i) => i.id != interactionId).toList();
    _extras[customerId] = _CustomerLocalExtras(
      additionalPhones: existing.additionalPhones,
      zaloLink: existing.zaloLink,
      facebookLink: existing.facebookLink,
      interactions: next,
      transactions: existing.transactions,
      aiChat: existing.aiChat,
    );
    _emitLocalMerge(customerId);
  }

  void addTransaction(String customerId, TransactionEntry entry) {
    final existing = _extras[customerId] ?? _CustomerLocalExtras();
    _extras[customerId] = _CustomerLocalExtras(
      additionalPhones: existing.additionalPhones,
      zaloLink: existing.zaloLink,
      facebookLink: existing.facebookLink,
      interactions: existing.interactions,
      transactions: [entry, ...existing.transactions],
      aiChat: existing.aiChat,
    );
    _emitLocalMerge(customerId);
  }

  void updateTransaction(String customerId, TransactionEntry updated) {
    final existing = _extras[customerId] ?? _CustomerLocalExtras();
    final next = existing.transactions
        .map((t) => t.id == updated.id ? updated : t)
        .toList();
    _extras[customerId] = _CustomerLocalExtras(
      additionalPhones: existing.additionalPhones,
      zaloLink: existing.zaloLink,
      facebookLink: existing.facebookLink,
      interactions: existing.interactions,
      transactions: next,
      aiChat: existing.aiChat,
    );
    _emitLocalMerge(customerId);
  }

  void deleteTransaction(String customerId, String transactionId) {
    final existing = _extras[customerId] ?? _CustomerLocalExtras();
    final next =
        existing.transactions.where((t) => t.id != transactionId).toList();
    _extras[customerId] = _CustomerLocalExtras(
      additionalPhones: existing.additionalPhones,
      zaloLink: existing.zaloLink,
      facebookLink: existing.facebookLink,
      interactions: existing.interactions,
      transactions: next,
      aiChat: existing.aiChat,
    );
    _emitLocalMerge(customerId);
  }

  void addAiMessage(String customerId, AiChatMessage message) {
    final existing = _extras[customerId] ?? _CustomerLocalExtras();
    _extras[customerId] = _CustomerLocalExtras(
      additionalPhones: existing.additionalPhones,
      zaloLink: existing.zaloLink,
      facebookLink: existing.facebookLink,
      interactions: existing.interactions,
      transactions: existing.transactions,
      aiChat: [...existing.aiChat, message],
    );
    _emitLocalMerge(customerId);
  }

  void _emitLocalMerge(String customerId) {
    final current = state.value;
    if (current == null) return;
    final idx = current.customers.indexWhere((c) => c.id == customerId);
    if (idx == -1) return;

    final c = current.customers[idx];
    final extras = _extras[customerId];
    if (extras == null) return;

    final merged = c.copyWith(
      additionalPhones: [...c.additionalPhones, ...extras.additionalPhones],
      zaloLink: extras.zaloLink,
      facebookLink: extras.facebookLink,
      interactions: extras.interactions,
      transactions: extras.transactions,
      aiChat: extras.aiChat,
    );

    final next = [...current.customers];
    next[idx] = merged;
    state = AsyncValue.data(current.copyWith(customers: next));
  }
}

final customersProvider =
    StateNotifierProvider<CustomersNotifier, AsyncValue<CustomersData>>((ref) {
  return CustomersNotifier(ref);
});
