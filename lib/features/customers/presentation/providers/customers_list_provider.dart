import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/customer_model.dart';
import '../models/customer_list_options.dart';
import 'customers_provider.dart';

class CustomersListState {
  const CustomersListState({
    required this.visibleCustomers,
    required this.counts,
    required this.isInitialLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.hasMore,
    required this.query,
    required this.stageFilter,
    required this.sortOption,
    required this.selectionMode,
    required this.selectedIds,
  });

  final List<Customer> visibleCustomers;
  final Map<CustomerListStageFilter, int> counts;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
  final String query;
  final CustomerListStageFilter stageFilter;
  final CustomerSortOption sortOption;
  final bool selectionMode;
  final Set<String> selectedIds;

  factory CustomersListState.initial() => CustomersListState(
        visibleCustomers: const [],
        counts: const {},
        isInitialLoading: true,
        isRefreshing: false,
        isLoadingMore: false,
        hasMore: false,
        query: '',
        stageFilter: CustomerListStageFilter.all,
        sortOption: CustomerSortOption.newest,
        selectionMode: false,
        selectedIds: const {},
      );

  CustomersListState copyWith({
    List<Customer>? visibleCustomers,
    Map<CustomerListStageFilter, int>? counts,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
    String? query,
    CustomerListStageFilter? stageFilter,
    CustomerSortOption? sortOption,
    bool? selectionMode,
    Set<String>? selectedIds,
  }) {
    return CustomersListState(
      visibleCustomers: visibleCustomers ?? this.visibleCustomers,
      counts: counts ?? this.counts,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
      stageFilter: stageFilter ?? this.stageFilter,
      sortOption: sortOption ?? this.sortOption,
      selectionMode: selectionMode ?? this.selectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class CustomersListController extends StateNotifier<CustomersListState> {
  CustomersListController(this._ref) : super(CustomersListState.initial());

  final Ref _ref;
  List<Customer> _source = const [];
  bool _hasMoreFromServer = false;

  void onSourceChanged(AsyncValue<CustomersData> next) {
    next.when(
      loading: () => state = state.copyWith(isInitialLoading: true),
      error: (_, __) => state = state.copyWith(isInitialLoading: false),
      data: (data) {
        _source = data.customers;
        _hasMoreFromServer = data.hasMore;
        state = state.copyWith(isInitialLoading: false);
        _apply();
      },
    );
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
    unawaited(
      _ref.read(customersProvider.notifier).fetchFirstPage(
            search: query,
            customerStage: _mapGroupToApiStage(state.stageFilter),
          ),
    );
  }

  void setStageFilter(CustomerListStageFilter filter) {
    state = state.copyWith(stageFilter: filter);
    unawaited(
      _ref.read(customersProvider.notifier).fetchFirstPage(
            search: state.query,
            customerStage: _mapGroupToApiStage(filter),
          ),
    );
  }

  void setSort(CustomerSortOption option) {
    state = state.copyWith(sortOption: option);
    _apply();
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    await _ref.read(customersProvider.notifier).fetchFirstPage(
          search: state.query,
          customerStage: _mapGroupToApiStage(state.stageFilter),
        );
    state = state.copyWith(isRefreshing: false);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    await _ref.read(customersProvider.notifier).loadMore();
    state = state.copyWith(isLoadingMore: false);
  }

  void toggleSelectionMode({bool? enabled}) {
    final next = enabled ?? !state.selectionMode;
    state = state.copyWith(
      selectionMode: next,
      selectedIds: next ? state.selectedIds : <String>{},
    );
  }

  void toggleSelected(String customerId) {
    final next = {...state.selectedIds};
    if (next.contains(customerId)) {
      next.remove(customerId);
    } else {
      next.add(customerId);
    }

    state = state.copyWith(
      selectionMode: true,
      selectedIds: next,
    );
  }

  void clearSelection() {
    state = state.copyWith(selectionMode: false, selectedIds: <String>{});
  }

  void bulkDelete() {
    for (final id in state.selectedIds) {
      unawaited(_ref.read(customersProvider.notifier).deleteCustomer(id));
    }
    clearSelection();
  }

  void bulkSetStage(CustomerListStageFilter stageGroup) {
    for (final id in state.selectedIds) {
      final customer = _source.firstWhere((c) => c.id == id, orElse: () => Customer(id: '', fullName: '', phoneNumber: ''));
      if (customer.id.isEmpty) continue;
      final stage = _mapGroupToStage(stageGroup, customer.stage);
      if (stage == null) continue;
      unawaited(
        _ref.read(customersProvider.notifier).changeStage(customerId: id, to: stage),
      );
    }
    clearSelection();
  }

  CustomerStage? _mapGroupToStage(CustomerListStageFilter group, CustomerStage current) {
    switch (group) {
      case CustomerListStageFilter.hot:
        return CustomerStage.explosionPoint;
      case CustomerListStageFilter.warm:
        return CustomerStage.haveNeeds;
      case CustomerListStageFilter.cold:
        return CustomerStage.research;
      case CustomerListStageFilter.won:
        return CustomerStage.sales;
      case CustomerListStageFilter.lost:
        return null;
      case CustomerListStageFilter.all:
        return current;
    }
  }

  void _apply() {
    final searched = _applySearch(_source, state.query);
    final counts = _buildCounts(searched);

    var filtered = searched;
    if (state.stageFilter != CustomerListStageFilter.all) {
      filtered = filtered.where((c) => c.listStageGroup == state.stageFilter).toList();
    }

    filtered = _sort(filtered, state.sortOption);

    state = state.copyWith(
      visibleCustomers: filtered,
      counts: counts,
      hasMore: _hasMoreFromServer,
    );
  }

  Map<CustomerListStageFilter, int> _buildCounts(List<Customer> customers) {
    final counts = <CustomerListStageFilter, int>{
      for (final s in CustomerListStageFilter.values) s: 0,
    };
    counts[CustomerListStageFilter.all] = customers.length;
    for (final c in customers) {
      counts[c.listStageGroup] = (counts[c.listStageGroup] ?? 0) + 1;
    }
    return counts;
  }

  List<Customer> _applySearch(List<Customer> customers, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return customers;

    bool match(Customer c) {
      if (c.fullName.toLowerCase().contains(q)) return true;
      if (c.phoneNumber.contains(q)) return true;
      if ((c.notes ?? '').toLowerCase().contains(q)) return true;
      for (final i in c.interactions) {
        if (i.content.toLowerCase().contains(q)) return true;
      }
      return false;
    }

    return customers.where(match).toList();
  }

  List<Customer> _sort(List<Customer> customers, CustomerSortOption option) {
    final list = [...customers];
    int ts(Customer c) => (c.lastContactDate ?? DateTime.fromMillisecondsSinceEpoch(0)).millisecondsSinceEpoch;

    switch (option) {
      case CustomerSortOption.newest:
        list.sort((a, b) => ts(b).compareTo(ts(a)));
        return list;
      case CustomerSortOption.oldest:
        list.sort((a, b) => ts(a).compareTo(ts(b)));
        return list;
      case CustomerSortOption.nameAz:
        list.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        return list;
      case CustomerSortOption.stale:
        list.sort((a, b) => ts(a).compareTo(ts(b)));
        return list;
    }
  }
}

final customersListProvider =
    StateNotifierProvider<CustomersListController, CustomersListState>((ref) {
  final controller = CustomersListController(ref);
  ref.listen<AsyncValue<CustomersData>>(
    customersProvider,
    (prev, next) => controller.onSourceChanged(next),
    fireImmediately: true,
  );
  return controller;
});

String? _mapGroupToApiStage(CustomerListStageFilter group) {
  switch (group) {
    case CustomerListStageFilter.hot:
      return 'explosion_point';
    case CustomerListStageFilter.warm:
      return 'have_needs';
    case CustomerListStageFilter.cold:
      return 'research';
    case CustomerListStageFilter.won:
      return 'sales';
    case CustomerListStageFilter.lost:
      return null;
    case CustomerListStageFilter.all:
      return null;
  }
}
