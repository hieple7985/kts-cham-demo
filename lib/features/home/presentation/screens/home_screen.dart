import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/app_prefs.dart';
import '../../../../core/navigation/deep_link_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customers/domain/models/customer_model.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../../customers/presentation/screens/add_edit_customer_screen.dart';
import '../../../customers/presentation/screens/customer_detail_screen.dart';
import '../../../customers/presentation/screens/customer_list_screen.dart';
import 'ai_insight_screen.dart';
import '../models/home_reminder.dart';
import '../providers/home_reminders_provider.dart';
import '../widgets/reminder_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenCustomerList,
    this.onAddCustomer,
    this.onAskCuca,
    this.onPendingRemindersChanged,
  });

  final VoidCallback? onOpenCustomerList;
  final VoidCallback? onAddCustomer;
  final VoidCallback? onAskCuca;
  final ValueChanged<int>? onPendingRemindersChanged;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<HomeReminder> _reminders = [];
  bool _isRefreshing = false;

  late final AnimationController _mascotController;
  ProviderSubscription<AsyncValue<CustomersData>>? _customersSubscription;
  ProviderSubscription<AsyncValue<HomeRemindersData>>? _remindersSubscription;

  @override
  void initState() {
    super.initState();

    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _playMascotWave();

    if (AppConfig.useSupabaseAuth) {
      _remindersSubscription = ref.listenManual<AsyncValue<HomeRemindersData>>(
        homeRemindersProvider,
        (prev, next) {
          next.whenData((data) {
            _hydrateReminders(data.reminders);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _notifyBadgeCount();
            });
          });
        },
      );
    } else {
      _customersSubscription = ref.listenManual<AsyncValue<CustomersData>>(
        customersProvider,
        (prev, next) {
          next.whenData((data) {
            _hydrateReminders(_buildMockReminders(data.customers));
            _notifyBadgeCount();
          });
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!AppPrefs.didOnboard) return;
      if (AppPrefs.didShowHomeHint) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Tip: vào "DS Khách" rồi bấm nút + để thêm khách nhanh.'),
          action: SnackBarAction(
            label: 'Mở DS Khách',
            onPressed: () {
              if (widget.onOpenCustomerList != null) {
                widget.onOpenCustomerList!.call();
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CustomerListScreen()),
              );
            },
          ),
        ),
      );

      await AppPrefs.setDidShowHomeHint(true);
    });
  }

  @override
  void dispose() {
    _customersSubscription?.close();
    _remindersSubscription?.close();
    _mascotController.dispose();
    super.dispose();
  }

  void _playMascotWave() {
    _mascotController
      ..reset()
      ..forward();
  }

  void _hydrateReminders(List<HomeReminder> next) {
    final previousById = <String, HomeReminder>{
      for (final r in _reminders) r.id: r,
    };

    _reminders.clear();
    for (final reminder in next) {
      final previous = previousById[reminder.id];
      if (previous == null) {
        _reminders.add(reminder);
      } else {
        _reminders.add(
          reminder.copyWith(
            status: previous.status,
            dueAt: previous.dueAt,
          ),
        );
      }
    }

    if (mounted) setState(() {});
  }

  List<HomeReminder> _buildMockReminders(List<Customer> customers) {
    final now = DateTime.now();

    if (customers.isEmpty) return const [];

    final List<HomeReminder> result = [];
    for (final customer in customers) {
      final stage = _mapCustomerStage(customer.stage);
      final dueAt = customer.nextCareDate ??
          now.add(Duration(hours: stage == ReminderStage.hot ? 2 : 6));
      final reason = customer.nextCareDate != null
          ? 'Đến lịch chăm sóc khách'
          : (customer.lastContactDate == null
              ? 'Khách mới, nên liên hệ lần đầu'
              : 'Đã ${now.difference(customer.lastContactDate!).inDays} ngày chưa chăm sóc');

      result.add(
        HomeReminder(
          id: 'r_${customer.id}',
          customerId: customer.id,
          customerName: customer.fullName,
          stage: stage,
          reason: reason,
          dueAt: dueAt,
        ),
      );
    }

    result.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return result;
  }

  ReminderStage _mapCustomerStage(CustomerStage stage) {
    switch (stage) {
      case CustomerStage.sales:
      case CustomerStage.explosionPoint:
        return ReminderStage.hot;
      case CustomerStage.haveNeeds:
      case CustomerStage.research:
        return ReminderStage.warm;
      case CustomerStage.lost:
        return ReminderStage.cold;
      case CustomerStage.afterSales:
      case CustomerStage.repeat:
        return ReminderStage.care;
      case CustomerStage.receiveInfo:
        return ReminderStage.warm;
    }
  }

  int _badgeCount(List<HomeReminder> reminders) {
    return reminders.where((r) => r.status == ReminderStatus.pending).length;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _notifyBadgeCount() {
    if (widget.onPendingRemindersChanged == null) return;
    widget.onPendingRemindersChanged!.call(_badgeCount(_reminders));
  }

  Future<void> _onRefresh(List<Customer> customers) async {
    setState(() => _isRefreshing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (AppConfig.useSupabaseAuth) {
      await ref.read(customersProvider.notifier).refresh();
      await ref.read(homeRemindersProvider.notifier).refresh();
    } else {
      _hydrateReminders(_buildMockReminders(customers));
      _notifyBadgeCount();
    }
    _playMascotWave();

    if (!mounted) return;
    setState(() => _isRefreshing = false);
  }

  void _openReminderActions(HomeReminder reminder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r12),
        ),
      ),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.check_circle, color: AppColors.successText),
                title: const Text('Đã liên hệ'),
                onTap: () {
                  Navigator.pop(context);
                  _updateReminderStatus(reminder.id, ReminderStatus.done);
                },
              ),
              ListTile(
                leading: Icon(Icons.snooze, color: AppColors.typeVIP),
                title: const Text('Hoãn 1 giờ'),
                onTap: () {
                  Navigator.pop(context);
                  _snoozeReminder(reminder.id, const Duration(hours: 1));
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today, color: AppColors.primary),
                title: const Text('Hoãn đến ngày mai'),
                onTap: () {
                  Navigator.pop(context);
                  _snoozeReminder(reminder.id, const Duration(days: 1));
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: AppColors.textDisabled),
                title: const Text('Bỏ qua'),
                onTap: () {
                  Navigator.pop(context);
                  _updateReminderStatus(reminder.id, ReminderStatus.skipped);
                },
              ),
              SizedBox(height: AppSpacing.s4),
            ],
          ),
        );
      },
    );
  }

  void _updateReminderStatus(String id, ReminderStatus status) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _reminders[index] = _reminders[index].copyWith(status: status);
    _notifyBadgeCount();
    setState(() {});
  }

  void _snoozeReminder(String id, Duration delta) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final current = _reminders[index];
    _reminders[index] = current.copyWith(dueAt: current.dueAt.add(delta));
    _notifyBadgeCount();
    setState(() {});
  }

  void _addInteraction({
    required String customerId,
    required InteractionType type,
    required String content,
  }) {
    ref.read(customersProvider.notifier).addInteraction(
          customerId,
          Interaction(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            type: type,
            content: content,
            timestamp: DateTime.now(),
          ),
        );
  }

  void _openAddNote(HomeReminder reminder) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r12),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.s4,
            right: AppSpacing.s4,
            top: AppSpacing.s4,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ghi chú nhanh',
                style: AppTextStyle.headline,
              ),
              SizedBox(height: AppSpacing.s3),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Nhập ghi chú…',
                ),
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.s3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    _addInteraction(
                      customerId: reminder.customerId,
                      type: InteractionType.note,
                      content: text,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Đã lưu ghi chú')),
                    );
                  },
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _timeLabel(DateTime dueAt) {
    final now = DateTime.now();
    if (_isSameDay(dueAt, now)) {
      final h = dueAt.hour.toString().padLeft(2, '0');
      final m = dueAt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    return '${dueAt.day}/${dueAt.month}';
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth provider at build method level for proper rebuilds
    final authState = ref.watch(authProvider);
    final customersState = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: customersState.when(
              loading: () => Column(
                children: [
                  _buildHeader(context, authState),
                  const Expanded(child: _HomeSkeleton()),
                ],
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Lỗi: $err',
                  style: AppTextStyle.body,
                ),
              ),
              data: (data) {
                final customers = data.customers;

                final hasCustomers = customers.isNotEmpty;
                final todayPendingReminders = _reminders
                    .where((r) => r.status == ReminderStatus.pending)
                    .where((r) => _isSameDay(r.dueAt, DateTime.now()))
                    .toList();

                return Column(
                  children: [
                    _buildHeader(context, authState),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => _onRefresh(customers),
                        color: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        child: SingleChildScrollView(
                          padding: AppSpacing.pV4.copyWith(
                            left: AppSpacing.s4,
                            right: AppSpacing.s4,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _isRefreshing
                                  ? const _InsightSkeleton()
                                  : _buildAIInsightCard(context, customers),
                              SizedBox(height: AppSpacing.s6),
                              _buildQuickActions(context),
                              SizedBox(height: AppSpacing.s6),
                              if (!hasCustomers)
                                _buildFirstTimeNoCustomers(context)
                              else if (_isRefreshing)
                                const _RemindersSkeleton()
                              else if (todayPendingReminders.isEmpty)
                                _buildEmptyReminders(context)
                              else
                                _buildTodayReminders(
                                  context,
                                  reminders: todayPendingReminders,
                                ),
                              SizedBox(height: AppSpacing.s4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthState authState) {
    final greeting = _greetingText();
    final wave =
        CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut);

    // Get real user data from auth state passed as parameter
    final user = authState.user;
    final fullName = (user?['full_name'] as String?) ?? 'Người dùng';
    final firstInitial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s4,
        AppSpacing.s4,
        AppSpacing.s3,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                firstInitial,
                style: AppTextStyle.headline.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s3),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTextStyle.caption,
                ),
                Text(
                  fullName,
                  style: AppTextStyle.bodyStrong,
                ),
              ],
            ),
          ),

          // Mascot Animation (Small)
          AnimatedBuilder(
            animation: wave,
            builder: (context, child) {
              final t = wave.value;
              final rotation = (t < 0.5 ? t : 1 - t) * 0.15;
              final scale = 1 + (t < 0.5 ? t : 1 - t) * 0.08;
              return Transform.rotate(
                angle: rotation,
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(AppAssets.cucaHeadset, height: 40, width: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng,';
    if (hour < 18) return 'Chào buổi chiều,';
    return 'Chào buổi tối,';
  }

  Widget _buildAIInsightCard(BuildContext context, List<Customer> customers) {
    final total = customers.length;
    final cold = customers
        .where((c) => c.lastContactDate != null)
        .where((c) => DateTime.now().difference(c.lastContactDate!).inDays >= 7)
        .length;

    final text = total == 0
        ? 'Chưa có dữ liệu để tạo insight.\nThêm khách hàng đầu tiên để bắt đầu.'
        : 'Tuần này bạn đang quản lý $total khách.\nCó $cold khách đang "nguội", nên liên hệ lại.';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        left: AppSpacing.s4,
        right: AppSpacing.s4,
        top: AppSpacing.s4,
      ),
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryPressed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.r16Border,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AiInsightScreen(customers: customers),
            ),
          );
        },
        borderRadius: AppRadius.r16Border,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.typeVIP,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.s2),
                      const Text(
                        'CUCA Insight',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s2),
                  Text(
                    text,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.s3),
            Image.asset(AppAssets.cucaIdea, height: 80, width: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
          ),
          child: Text(
            'Thao tác nhanh',
            style: AppTextStyle.headline,
          ),
        ),
        SizedBox(height: AppSpacing.s3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              context,
              icon: Icons.person_add,
              label: 'Thêm KH',
              bgColor: AppColors.infoBg,
              iconColor: AppColors.primary,
              onTap: () {
                if (widget.onAddCustomer != null) {
                  widget.onAddCustomer!.call();
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddEditCustomerScreen()),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.group,
              label: 'Danh sách',
              bgColor: AppColors.dangerBg,
              iconColor: AppColors.stageHot,
              onTap: () {
                if (widget.onOpenCustomerList != null) {
                  widget.onOpenCustomerList!.call();
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CustomerListScreen()),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.psychology,
              label: 'Hỏi CUCA',
              bgColor: AppColors.warningBg,
              iconColor: AppColors.typeVIP,
              onTap: () {
                if (widget.onAskCuca != null) {
                  widget.onAskCuca!.call();
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng AI Chat đang phát triển.')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            label,
            style: AppTextStyle.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayReminders(
    BuildContext context, {
    required List<HomeReminder> reminders,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hôm nay cần làm',
                style: AppTextStyle.headline,
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.s2),
        for (final reminder in reminders)
          ReminderItem(
            reminder: reminder,
            timeLabel: _timeLabel(reminder.dueAt),
            onTap: () {
              final handled = DeepLinkHandler.canHandle(reminder.deepLink) &&
                  DeepLinkHandler.handle(context, reminder.deepLink!);
              if (handled) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CustomerDetailScreen(customerId: reminder.customerId),
                ),
              );
            },
            onCall: () {
              _addInteraction(
                customerId: reminder.customerId,
                type: InteractionType.call,
                content: 'Gọi khách',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Đã ghi nhớ: Gọi ${reminder.customerName}')),
              );
              _openReminderActions(reminder);
            },
            onMessage: () {
              _addInteraction(
                customerId: reminder.customerId,
                type: InteractionType.message,
                content: 'Nhắn khách',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Đã ghi nhớ: Nhắn ${reminder.customerName}')),
              );
              _openReminderActions(reminder);
            },
            onNote: () => _openAddNote(reminder),
            onMore: () => _openReminderActions(reminder),
          ),
      ],
    );
  }

  Widget _buildEmptyReminders(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.r12Border,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey1.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(AppAssets.cucaWriting, height: 140, fit: BoxFit.contain),
          SizedBox(height: AppSpacing.s3),
          const Text(
            'Hôm nay bạn không có việc cần làm',
            style: AppTextStyle.bodyStrong,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Bạn có thể xem lại các khách cũ và chủ động chăm sóc.',
            style: AppTextStyle.caption,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.s3),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onOpenCustomerList ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CustomerListScreen()),
                    );
                  },
              icon: const Icon(Icons.group),
              label: const Text('Xem tất cả Customer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstTimeNoCustomers(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.r12Border,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey1.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(AppAssets.cucaThumbsUp, height: 140, fit: BoxFit.contain),
          SizedBox(height: AppSpacing.s3),
          const Text(
            'Chưa có khách hàng nào',
            style: AppTextStyle.bodyStrong,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Hãy thêm khách đầu tiên để CUCA bắt đầu nhắc việc cho bạn.',
            style: AppTextStyle.caption,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.s3),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: widget.onAddCustomer ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddEditCustomerScreen()),
                    );
                  },
              icon: const Icon(Icons.person_add),
              label: const Text('Thêm Customer đầu tiên'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.pV4.copyWith(
        left: AppSpacing.s4,
        right: AppSpacing.s4,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      child: const Column(
        children: [
          _InsightSkeleton(),
          SizedBox(height: AppSpacing.s6),
          _RemindersSkeleton(),
        ],
      ),
    );
  }
}

class _InsightSkeleton extends StatelessWidget {
  const _InsightSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: AppRadius.r16Border,
      ),
    );
  }
}

class _RemindersSkeleton extends StatelessWidget {
  const _RemindersSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 18,
              width: 140,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: AppRadius.r4Border,
              ),
            ),
            Container(
              height: 16,
              width: 70,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: AppRadius.r4Border,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s3),
        for (var i = 0; i < 3; i++)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s3),
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: AppRadius.r12Border,
            ),
          ),
      ],
    );
  }
}
