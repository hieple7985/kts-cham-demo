import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_prefs.dart';
import '../../../../core/presentation/widgets/cuca_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import '../models/customer_list_options.dart';
import '../providers/customers_list_provider.dart';
import '../providers/customers_provider.dart';
import '../widgets/customer_card.dart';
import 'add_edit_customer_screen.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!AppPrefs.didOnboard) return;
      if (AppPrefs.didShowCustomerFabHint) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tip: bấm nút + để thêm khách hàng mới.')),
      );
      await AppPrefs.setDidShowCustomerFabHint(true);
    });

    _scrollController.addListener(() {
      final position = _scrollController.position;
      if (position.maxScrollExtent <= 0) return;
      if (position.pixels < position.maxScrollExtent - 250) return;
      ref.read(customersListProvider.notifier).loadMore();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(customersListProvider);
    final customersAsync = ref.watch(customersProvider);

    return PopScope(
      canPop: !listState.selectionMode,
      onPopInvoked: (didPop) {
        if (didPop) return;
        ref.read(customersListProvider.notifier).clearSelection();
      },
      child: Scaffold(
        appBar: AppBar(
          title: listState.selectionMode
              ? Text('Đã chọn ${listState.selectedIds.length}')
              : const Text('Khách hàng'),
          leading: listState.selectionMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => ref.read(customersListProvider.notifier).clearSelection(),
                )
              : null,
          actions: listState.selectionMode
              ? [
                  IconButton(
                    tooltip: 'Đổi stage',
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: () => _showBulkStageSheet(),
                  ),
                  IconButton(
                    tooltip: 'Xóa',
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmBulkDelete(),
                  ),
                ]
              : [
                  PopupMenuButton<CustomerSortOption>(
                    tooltip: 'Sắp xếp',
                    icon: const Icon(Icons.sort),
                    onSelected: (opt) => ref.read(customersListProvider.notifier).setSort(opt),
                    itemBuilder: (context) => [
                      for (final opt in CustomerSortOption.values)
                        PopupMenuItem(value: opt, child: Text(opt.label)),
                    ],
                  ),
                ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildStageFilters(listState),
            Expanded(
              child: customersAsync.when(
                loading: () => const _CustomerListSkeleton(),
                error: (error, stack) => Center(child: Text('Lỗi: $error')),
                data: (data) {
                  final customers = data.customers;
                  final visible = listState.visibleCustomers;

                  if (customers.isEmpty) {
                    return _buildEmptyNoCustomers(context);
                  }

                  if (visible.isEmpty) {
                    return _buildEmptySearch(context, listState.query);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(customersListProvider.notifier).refresh();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                        left: AppSpacing.s4,
                        right: AppSpacing.s4,
                        top: AppSpacing.s4,
                        bottom: AppSpacing.s4 + 80, // Extra space for FAB
                      ),
                      itemCount: visible.length + (listState.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= visible.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final customer = visible[index];
                        final isSelected = listState.selectedIds.contains(customer.id);

                        return Dismissible(
                          key: Key('customer_${customer.id}'),
                          direction: listState.selectionMode
                              ? DismissDirection.none
                              : DismissDirection.horizontal,
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: AppSpacing.s5),
                            margin: const EdgeInsets.only(bottom: AppSpacing.s3),
                            decoration: BoxDecoration(
                              color: AppColors.stageWarm,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.flag, color: AppColors.white),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: AppSpacing.s5),
                            margin: const EdgeInsets.only(bottom: AppSpacing.s3),
                            decoration: BoxDecoration(
                              color: AppColors.grey3,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.call, color: AppColors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              unawaited(
                                ref.read(customersProvider.notifier).updateCustomer(
                                      customerId: customer.id,
                                      tags: {...customer.tags, 'Follow-up'}.toList(),
                                    ),
                              );
                              if (!context.mounted) return false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã đánh dấu follow-up: ${customer.fullName}')),
                              );
                              return false;
                            }

                            final action = await showModalBottomSheet<String>(
                              context: context,
                              showDragHandle: true,
                              builder: (context) => SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.call, color: Colors.green),
                                      title: const Text('Gọi'),
                                      onTap: () => Navigator.pop(context, 'call'),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete, color: Colors.red),
                                      title: const Text('Xóa khách'),
                                      onTap: () => Navigator.pop(context, 'delete'),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            if (action == 'call') {
                              if (!context.mounted) return false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã ghi nhớ: Gọi ${customer.fullName}')),
                              );
                              return false;
                            }

                            return action == 'delete';
                          },
                          onDismissed: (direction) {
                            unawaited(ref.read(customersProvider.notifier).deleteCustomer(customer.id));
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã xóa ${customer.fullName}')),
                            );
                          },
                          child: CustomerCard(
                            customer: customer,
                            selectionMode: listState.selectionMode,
                            selected: isSelected,
                            onTap: () {
                              if (listState.selectionMode) {
                                ref.read(customersListProvider.notifier).toggleSelected(customer.id);
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomerDetailScreen(customerId: customer.id),
                                ),
                              );
                            },
                            onLongPress: () => ref.read(customersListProvider.notifier).toggleSelected(customer.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: listState.selectionMode
            ? null
            : FloatingActionButton(
                heroTag: 'add_customer_fab',
                tooltip: 'Thêm khách hàng',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddEditCustomerScreen()),
                  );
                },
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, SĐT, ghi chú...',
          hintStyle: AppTextStyle.body.copyWith(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s3,
            vertical: AppSpacing.s4,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(customersListProvider.notifier).setQuery('');
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {});
          _searchDebounce?.cancel();
          _searchDebounce = Timer(const Duration(milliseconds: 300), () {
            ref.read(customersListProvider.notifier).setQuery(value);
          });
        },
      ),
    );
  }

  Widget _buildStageFilters(CustomersListState state) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
        children: [
          for (final f in CustomerListStageFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s2),
              child: ChoiceChip(
                label: Text(
                  '${f.label} (${state.counts[f] ?? 0})',
                  style: AppTextStyle.caption,
                ),
                selected: state.stageFilter == f,
                onSelected: (_) => ref.read(customersListProvider.notifier).setStageFilter(f),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyNoCustomers(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CucaMascot(pose: CucaPose.success, height: 170),
            const SizedBox(height: AppSpacing.s4),
            const Text(
              'Thêm khách hàng đầu tiên',
              style: AppTextStyle.title3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              'Bạn chưa có Customer nào. Hãy thêm khách đầu tiên để bắt đầu chăm sóc.',
              style: AppTextStyle.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s4),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddEditCustomerScreen()),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Thêm Customer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearch(BuildContext context, String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CucaMascot(pose: CucaPose.helpful, height: 170),
            const SizedBox(height: AppSpacing.s4),
            const Text(
              'Không tìm thấy khách nào',
              style: AppTextStyle.title3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              query.isEmpty ? 'Hãy thử đổi bộ lọc.' : 'Thử từ khóa khác nhé.',
              style: AppTextStyle.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBulkDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa khách hàng'),
        content: const Text('Bạn có chắc muốn xóa các khách đã chọn không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok != true) return;
    ref.read(customersListProvider.notifier).bulkDelete();
  }

  void _showBulkStageSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in [
              CustomerListStageFilter.hot,
              CustomerListStageFilter.warm,
              CustomerListStageFilter.cold,
              CustomerListStageFilter.won,
              CustomerListStageFilter.lost,
            ])
              ListTile(
                leading: const Icon(Icons.label),
                title: Text('Chuyển sang ${f.label}'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(customersListProvider.notifier).bulkSetStage(f);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomerListSkeleton extends StatelessWidget {
  const _CustomerListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.s4),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.grey12,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
