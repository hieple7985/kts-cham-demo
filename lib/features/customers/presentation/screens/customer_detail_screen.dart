import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/presentation/widgets/cuca_mascot.dart';
import '../../../../core/network/node_api_client.dart';
import '../../domain/models/customer_model.dart';
import '../models/customer_list_options.dart';
import '../models/template_models.dart';
import '../providers/customer_chat_provider.dart';
import '../providers/customer_ai_provider.dart';
import '../providers/customer_templates_provider.dart';
import '../providers/customer_tasks_purchases_provider.dart';
import '../providers/customers_provider.dart';
import '../../../home/presentation/providers/home_reminders_provider.dart';
import 'add_edit_customer_screen.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  bool _isChangingStage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
          ref.read(customersProvider.notifier).fetchById(widget.customerId));
      unawaited(ref
          .read(customersProvider.notifier)
          .fetchStageHistory(widget.customerId));
      unawaited(ref
          .read(customersProvider.notifier)
          .fetchInteractions(widget.customerId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);

    Customer? customerOrNull;
    customersAsync.whenData((data) {
      for (final c in data.customers) {
        if (c.id == widget.customerId) {
          customerOrNull = c;
          return;
        }
      }
    });

    final customer = customerOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết khách hàng'),
        actions: [
          if (customer != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddEditCustomerScreen(customer: customer)),
                );
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'copy_phone' && customer != null) {
                _copyText(customer.phoneNumber);
              } else if (value == 'ask_cuca') {
                _scrollToAiChat();
              } else if (value == 'delete' && customer != null) {
                _confirmDelete(context, customer.id);
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                  value: 'copy_phone', child: Text('Copy SĐT')),
              const PopupMenuItem<String>(
                  value: 'ask_cuca', child: Text('Hỏi CUCA')),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Xóa liên hệ', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: customersAsync.when(
        loading: () => _buildSkeletonBody(),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (data) {
          Customer? c;
          for (final item in data.customers) {
            if (item.id == widget.customerId) {
              c = item;
              break;
            }
          }
          if (c == null)
            return const Center(child: Text('Không tìm thấy khách hàng'));
          return _buildBody(context, c);
        },
      ),
      floatingActionButton: customer == null
          ? null
          : FloatingActionButton(
              heroTag: 'add_interaction_fab',
              tooltip: 'Thêm tương tác',
              onPressed: () => _showAddOrEditInteractionSheet(context,
                  customerId: customer.id),
              child: const Icon(Icons.add_comment),
            ),
    );
  }

  final _scrollController = ScrollController();
  final _aiChatKey = GlobalKey();
  final _aiInputController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _aiInputController.dispose();
    super.dispose();
  }

  Widget _buildBody(BuildContext context, Customer customer) {
    return SafeArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, customer),
            const SizedBox(height: AppSpacing.s4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
              child: _buildAiSummaryCard(context, customer),
            ),
            const SizedBox(height: AppSpacing.s4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
              child: _buildAIInsightCard(context, customer),
            ),
            const SizedBox(height: AppSpacing.s6),
            _buildContactInfoSection(context, customer),
            const SizedBox(height: AppSpacing.s6),
            _buildStageControl(context, customer),
            const SizedBox(height: AppSpacing.s3),
            _buildStageHistorySection(context, customer),
            const SizedBox(height: AppSpacing.s6),
            _buildTimelineSection(context, customer),
            const SizedBox(height: AppSpacing.s6),
            _buildChatSessionsSection(context, customer),
            const SizedBox(height: AppSpacing.s6),
            _buildAiAnalysisSection(context, customer),
            const SizedBox(height: AppSpacing.s6),
            _buildTemplateComposerSection(context, customer),
            const SizedBox(height: AppSpacing.s6),
            _buildTasksSection(context, customer),
            const SizedBox(height: AppSpacing.s6),
            _buildPurchasesSection(context, customer),
            const SizedBox(height: AppSpacing.s6),
            _buildTransactionsSection(context, customer),
            const SizedBox(height: AppSpacing.s6),
            _buildAiChatSection(context, customer),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBody() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s4),
      children: [
        Container(
            height: 140,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12))),
        const SizedBox(height: 16),
        Container(
            height: 96,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12))),
        const SizedBox(height: 16),
        Container(
            height: 160,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12))),
      ],
    );
  }

  void _scrollToAiChat() {
    final context = _aiChatKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(context,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã copy')));
  }

  void _callPhone(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã ghi nhớ: Gọi $phone')),
    );
  }

  void _openDeepLink(String label, String link) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã ghi nhớ: Mở $label')),
    );
  }

  Widget _buildContactInfoSection(BuildContext context, Customer customer) {
    final phones = <String>[
      customer.phoneNumber,
      ...customer.additionalPhones,
    ].where((p) => p.trim().isNotEmpty).toList();

    final hasZalo = customer.zaloLink != null && customer.zaloLink!.isNotEmpty;
    final hasFacebook =
        customer.facebookLink != null && customer.facebookLink!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Liên hệ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                for (var i = 0; i < phones.length; i++)
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(i == 0 ? 'SĐT chính' : 'SĐT phụ ${i}'),
                    subtitle: Text(phones[i]),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          tooltip: 'Gọi',
                          icon: const Icon(Icons.call),
                          onPressed: () => _callPhone(phones[i]),
                        ),
                        IconButton(
                          tooltip: 'Copy',
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyText(phones[i]),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 1),
                CheckboxListTile(
                  value: hasZalo,
                  onChanged: null,
                  title: const Text('Có Zalo'),
                  subtitle: Text(hasZalo ? 'Đã có link Zalo' : 'Chưa có link'),
                ),
                if (hasZalo)
                  ListTile(
                    leading:
                        const Icon(Icons.chat_bubble, color: Colors.blueAccent),
                    title: const Text('Zalo'),
                    subtitle: Text(customer.zaloLink!),
                    onTap: () => _openDeepLink('Zalo', customer.zaloLink!),
                  ),
                if (hasFacebook)
                  ListTile(
                    leading: const Icon(Icons.facebook, color: Colors.indigo),
                    title: const Text('Facebook'),
                    subtitle: Text(customer.facebookLink!),
                    onTap: () =>
                        _openDeepLink('Facebook', customer.facebookLink!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSummaryCard(BuildContext context, Customer customer) {
    final stageGroup = customer.listStageGroup.label;
    final daysSince = customer.lastContactDate == null
        ? null
        : DateTime.now().difference(customer.lastContactDate!).inDays;
    final heat = daysSince == null
        ? 'chưa có dữ liệu'
        : (daysSince >= 7 ? 'nguội' : 'ấm');
    final next = daysSince == null
        ? 'Gợi ý: ghi lại cuộc gọi/ghi chú đầu tiên.'
        : (daysSince >= 7
            ? 'Gợi ý: follow-up nhẹ nhàng trong 2 ngày tới.'
            : 'Gợi ý: duy trì chăm sóc định kỳ.');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CucaMascot(
              pose: CucaPose.hint, height: 60, width: 60, animate: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI tóm tắt nhanh',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Stage: $stageGroup • Mức độ: $heat'),
                const SizedBox(height: 6),
                Text(next, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOrEditInteractionSheet(
    BuildContext context, {
    required String customerId,
    Interaction? initial,
  }) {
    if (AppConfig.useSupabaseAuth && initial != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Chưa hỗ trợ sửa tương tác khi tích hợp backend.')),
      );
      return;
    }

    final contentController =
        TextEditingController(text: initial?.content ?? '');
    InteractionType selectedType = initial?.type ?? InteractionType.note;
    DateTime timestamp = initial?.timestamp ?? DateTime.now();

    Future<void> paste() async {
      final data = await Clipboard.getData('text/plain');
      final text = (data?.text ?? '').trim();
      if (text.isEmpty) return;
      contentController.text = [
        contentController.text.trim(),
        text,
      ].where((x) => x.isNotEmpty).join('\n');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                initial == null ? 'Thêm tương tác mới' : 'Sửa tương tác',
                style:
                    AppTextStyle.title3,
              ),
              const SizedBox(height: AppSpacing.s4),
              Wrap(
                spacing: 12,
                children: (AppConfig.useSupabaseAuth
                        ? [
                            InteractionType.call,
                            InteractionType.message,
                            InteractionType.zalo,
                            InteractionType.meeting,
                            InteractionType.note,
                          ]
                        : InteractionType.values)
                    .map((type) {
                  final isSelected = selectedType == type;
                  return ChoiceChip(
                    label: Text(_getInteractionLabel(type)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setSheetState(() => selectedType = type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.s4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: timestamp,
                          firstDate: DateTime(2020),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked == null) return;
                        setSheetState(() {
                          timestamp = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            timestamp.hour,
                            timestamp.minute,
                          );
                        });
                      },
                      icon: const Icon(Icons.event),
                      label: Text(DateFormat('dd/MM/yyyy').format(timestamp)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(timestamp),
                        );
                        if (picked == null) return;
                        setSheetState(() {
                          timestamp = DateTime(
                            timestamp.year,
                            timestamp.month,
                            timestamp.day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      },
                      icon: const Icon(Icons.schedule),
                      label: Text(DateFormat('HH:mm').format(timestamp)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s3),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.s3),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: paste,
                  icon: const Icon(Icons.paste),
                  label: const Text('Paste từ clipboard'),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final content = contentController.text.trim();
                    if (content.isEmpty) return;

                    try {
                      if (initial == null && AppConfig.useSupabaseAuth) {
                        await ref
                            .read(customersProvider.notifier)
                            .createInteractionRemote(
                              customerId: customerId,
                              type: selectedType,
                              content: content,
                              timestamp: timestamp,
                            );
                      } else {
                        final interaction = Interaction(
                          id: initial?.id ?? const Uuid().v4(),
                          type: selectedType,
                          content: content,
                          timestamp: timestamp,
                        );

                        if (initial == null) {
                          ref
                              .read(customersProvider.notifier)
                              .addInteraction(customerId, interaction);
                        } else {
                          ref
                              .read(customersProvider.notifier)
                              .updateInteraction(customerId, interaction);
                        }
                      }

                      if (context.mounted) Navigator.pop(context);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã thêm tương tác')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      final message =
                          e is NodeApiException ? e.message : e.toString();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Thêm tương tác thất bại: $message')),
                      );
                    }
                  },
                  child:
                      Text(initial == null ? 'Lưu tương tác' : 'Lưu thay đổi'),
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
            ],
          ),
        ),
      ),
    );
  }

  String _getInteractionLabel(InteractionType type) {
    switch (type) {
      case InteractionType.call:
        return 'Gọi điện';
      case InteractionType.message:
        return 'Tin nhắn';
      case InteractionType.zalo:
        return 'Zalo';
      case InteractionType.facebook:
        return 'Facebook';
      case InteractionType.meeting:
        return 'Gặp mặt';
      case InteractionType.note:
        return 'Ghi chú';
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa khách hàng này không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(customersProvider.notifier).deleteCustomer(id);
        if (!context.mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xóa: $e')),
        );
      }
    }
  }

  Widget _buildHeader(BuildContext context, Customer customer) {
    final stageGroup = customer.listStageGroup;
    final stageColor = customer.listStageColor;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: stageColor.withOpacity(0.2),
                child: Text(
                    customer.fullName.isNotEmpty
                        ? customer.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: stageColor)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.fullName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (customer.isDemo)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4)),
                            child: const Text('DEMO',
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(customer.phoneNumber,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: AppSpacing.s2),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTag(stageGroup.label, stageColor),
                        if (customer.tags.isNotEmpty)
                          ...customer.tags
                              .map((t) => _buildTag(t, Colors.blue)),
                        if (customer.source != null)
                          _buildTag('Nguồn: ${customer.source}', Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAction(Icons.call, 'Gọi', Colors.green,
                  () => _callPhone(customer.phoneNumber)),
              _buildQuickAction(Icons.copy, 'Copy SĐT', Colors.grey,
                  () => _copyText(customer.phoneNumber)),
              if (customer.zaloLink != null && customer.zaloLink!.isNotEmpty)
                _buildQuickAction(Icons.chat_bubble, 'Zalo', Colors.blueAccent,
                    () => _openDeepLink('Zalo', customer.zaloLink!)),
              if (customer.facebookLink != null &&
                  customer.facebookLink!.isNotEmpty)
                _buildQuickAction(Icons.facebook, 'Facebook', Colors.indigo,
                    () => _openDeepLink('Facebook', customer.facebookLink!)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAIInsightCard(BuildContext context, Customer customer) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(AppAssets.cucaIdea, height: 60, width: 60),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gợi ý từ CUCA',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  customer.notes ??
                      'Chưa có ghi chú nhiều. Hãy thêm thông tin tương tác.',
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: AppSpacing.s3),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _scrollToAiChat,
                    icon: const Icon(Icons.smart_toy),
                    label: const Text('Hỏi CUCA về khách này'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageControl(BuildContext context, Customer customer) {
    final groupOptions = [
      CustomerListStageFilter.hot,
      CustomerListStageFilter.warm,
      CustomerListStageFilter.cold,
      CustomerListStageFilter.won,
      CustomerListStageFilter.lost,
    ];
    final current = customer.listStageGroup;
    final currentIndex =
        groupOptions.indexOf(current).clamp(0, groupOptions.length - 1);
    final progress = groupOptions.length <= 1
        ? 0.0
        : currentIndex / (groupOptions.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
          child: Text('Hành trình khách hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              color: customer.listStageColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
          child: Row(
            children: groupOptions.map((stageGroup) {
              final isSelected = stageGroup == current;
              final isPassed = groupOptions.indexOf(stageGroup) < currentIndex;
              final color = customer.listStageColor;

              return GestureDetector(
                onTap: () {
                  _changeStageWithReason(customer: customer, group: stageGroup);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color
                        : (isPassed
                            ? color.withOpacity(0.2)
                            : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    stageGroup.label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isPassed ? color : Colors.black54),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _changeStageWithReason({
    required Customer customer,
    required CustomerListStageFilter group,
  }) async {
    if (customer.listStageGroup == group) return;
    if (_isChangingStage) return;

    final controller = TextEditingController();
    final reason = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lý do đổi stage'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ví dụ: khách hỏi chi tiết giá…',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Bỏ qua')),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Lưu')),
        ],
      ),
    );

    final stage = _mapGroupToStage(group, customer.stage);
    if (stage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stage này chưa hỗ trợ ở backend.')),
      );
      return;
    }

    try {
      setState(() => _isChangingStage = true);
      await ref.read(customersProvider.notifier).changeStage(
            customerId: customer.id,
            to: stage,
            reason: reason,
          );
      await ref.read(customersProvider.notifier).fetchById(customer.id);
      await ref.read(customersProvider.notifier).fetchStageHistory(customer.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã đổi stage: ${customer.fullName}')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is NodeApiException ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đổi stage thất bại: $message')),
      );
    } finally {
      if (mounted) setState(() => _isChangingStage = false);
    }
  }

  CustomerStage? _mapGroupToStage(
      CustomerListStageFilter group, CustomerStage current) {
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

  String _getStageLabel(CustomerStage stage) {
    switch (stage) {
      case CustomerStage.receiveInfo:
        return 'Nhận tin';
      case CustomerStage.haveNeeds:
        return 'Có nhu cầu';
      case CustomerStage.research:
        return 'Tìm hiểu';
      case CustomerStage.explosionPoint:
        return 'Bùng nổ';
      case CustomerStage.sales:
        return 'Chốt đơn';
      case CustomerStage.afterSales:
        return 'CSKH';
      case CustomerStage.repeat:
        return 'Mua lại';
      case CustomerStage.lost:
        return 'Đã mất';
    }
  }

  Widget _buildStageHistorySection(BuildContext context, Customer customer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lịch sử đổi stage',
                style: AppTextStyle.bodyStrong,
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _isChangingStage
                    ? null
                    : () => ref
                        .read(customersProvider.notifier)
                        .fetchStageHistory(customer.id),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (customer.stageHistory.isEmpty)
            _buildEmptyCard(
              pose: CucaPose.helpful,
              title: 'Chưa có lịch sử',
              message: 'Khi bạn đổi stage, lý do sẽ được lưu ở đây.',
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  for (final h in customer.stageHistory.take(6))
                    ListTile(
                      leading: const Icon(Icons.timeline),
                      title: Text(
                          '${_getStageLabel(h.from)} → ${_getStageLabel(h.to)}'),
                      subtitle: Text(
                        [
                          DateFormat('HH:mm dd/MM').format(h.timestamp),
                          if (h.reason != null && h.reason!.isNotEmpty)
                            h.reason!,
                        ].join(' • '),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard({
    required CucaPose pose,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          CucaMascot(pose: pose, height: 120, animate: false),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(message,
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.s3),
            action,
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context, Customer customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
          child: Text('Lịch sử tương tác',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        if (customer.interactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: _buildEmptyCard(
              pose: CucaPose.helpful,
              title: 'Chưa có tương tác',
              message: 'Ghi lại cuộc gọi đầu tiên với khách này nhé.',
              action: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddOrEditInteractionSheet(context,
                      customerId: customer.id),
                  icon: const Icon(Icons.add_comment),
                  label: const Text('Thêm tương tác'),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            itemCount: customer.interactions.length,
            itemBuilder: (context, index) {
              final interaction = customer.interactions[index];
              return _buildTimelineItem(customer, interaction);
            },
          ),
      ],
    );
  }

  Widget _buildTimelineItem(Customer customer, Interaction interaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: interaction.color.withOpacity(0.1),
                    shape: BoxShape.circle),
                child:
                    Icon(interaction.icon, color: interaction.color, size: 16),
              ),
              Container(width: 2, height: 40, color: Colors.grey[200]),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_getInteractionLabel(interaction.type),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Row(
                      children: [
                        Text(
                          DateFormat('HH:mm dd/MM')
                              .format(interaction.timestamp),
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddOrEditInteractionSheet(
                                context,
                                customerId: customer.id,
                                initial: interaction,
                              );
                            } else if (value == 'delete') {
                              if (AppConfig.useSupabaseAuth) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Chưa hỗ trợ xóa tương tác khi tích hợp backend.')),
                                );
                                return;
                              }

                              ref
                                  .read(customersProvider.notifier)
                                  .deleteInteraction(
                                      customer.id, interaction.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Đã xóa tương tác')));
                            } else if (value == 'remind') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Tính năng tạo nhắc nhở đang phát triển.')),
                              );
                            }
                          },
                          itemBuilder: (context) => AppConfig.useSupabaseAuth
                              ? const [
                                  PopupMenuItem(
                                      value: 'remind',
                                      child: Text('Tạo nhắc nhở tiếp theo')),
                                ]
                              : const [
                                  PopupMenuItem(
                                      value: 'edit', child: Text('Sửa')),
                                  PopupMenuItem(
                                      value: 'delete', child: Text('Xóa')),
                                  PopupMenuItem(
                                      value: 'remind',
                                      child: Text('Tạo nhắc nhở tiếp theo')),
                                ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(interaction.content,
                    style: TextStyle(
                        color: Colors.grey[700], fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSessionsSection(BuildContext context, Customer customer) {
    if (!AppConfig.useSupabaseAuth) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildEmptyCard(
          pose: CucaPose.hint,
          title: 'Chat sessions (demo)',
          message: 'Bật Supabase auth để import và xem chat sessions.',
        ),
      );
    }

    final chat = ref.watch(customerChatProvider(customer.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Chat sessions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => ref
                        .read(customerChatProvider(customer.id).notifier)
                        .refreshSessions(),
                    icon: const Icon(Icons.refresh),
                  ),
                  TextButton.icon(
                    onPressed: () => _showImportChatSheet(context, customer.id),
                    icon: const Icon(Icons.upload),
                    label: const Text('Import'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (chat.isLoadingSessions)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator()))
          else if (chat.sessions.isEmpty)
            _buildEmptyCard(
              pose: CucaPose.hint,
              title: 'Chưa có chat session',
              message:
                  'Dán đoạn chat đã copy từ Zalo/Facebook để import vào hệ thống.',
              action: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showImportChatSheet(context, customer.id),
                  icon: const Icon(Icons.paste),
                  label: const Text('Import bằng copy-paste'),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  for (final session in chat.sessions)
                    ListTile(
                      leading: const Icon(Icons.chat),
                      title: Text(
                          '${session.source} • ${session.messageCount} messages'),
                      subtitle: Text(
                        session.importedAt != null
                            ? 'Imported: ${DateFormat('dd/MM HH:mm').format(session.importedAt!)}'
                            : 'Imported: -',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openChatSessionViewer(
                          context, customer.id, session.id),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _openChatSessionViewer(
      BuildContext context, String customerId, String sessionId) {
    ref.read(customerChatProvider(customerId).notifier).openSession(sessionId);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Consumer(
            builder: (context, ref, _) {
              final chat = ref.watch(customerChatProvider(customerId));
              if (chat.isLoadingMessages) {
                return const Center(child: CircularProgressIndicator());
              }

              if (chat.messages.isEmpty) {
                return const Center(child: Text('Chưa có tin nhắn'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.s4),
                itemCount: chat.messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final msg = chat.messages[index];
                  final isMe = msg.sender == 'sales';

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue[50] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.messageText,
                            style: const TextStyle(fontSize: 14, height: 1.35),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm dd/MM').format(msg.timestamp),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showImportChatSheet(BuildContext context, String customerId) {
    final controller = TextEditingController();
    var isJson = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Import chat',
                  style: AppTextStyle.title3),
              const SizedBox(height: AppSpacing.s2),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Copy-paste text'),
                    selected: !isJson,
                    onSelected: (_) => setModalState(() => isJson = false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('JSON'),
                    selected: isJson,
                    onSelected: (_) => setModalState(() => isJson = true),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                isJson
                    ? 'Dán JSON export (Zalo format).'
                    : 'Dán log chat theo format có timestamp (Zalo export text).',
              ),
              const SizedBox(height: AppSpacing.s3),
              TextField(
                controller: controller,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: isJson
                      ? '{ \"messages\": [...] }'
                      : 'VD: 01/12/2025, 09:15 - Bạn: ...',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.s3),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        final text = (data?.text ?? '').trim();
                        if (text.isEmpty) return;
                        controller.text = text;
                      },
                      icon: const Icon(Icons.paste),
                      label: const Text('Paste'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        try {
                          if (isJson) {
                            final payload = jsonDecode(text);
                            await ref
                                .read(customerChatProvider(customerId).notifier)
                                .importFromJson(payload);
                          } else {
                            await ref
                                .read(customerChatProvider(customerId).notifier)
                                .importFromText(text);
                          }

                          if (context.mounted) Navigator.pop(context);
                          if (!mounted) return;
                          final warnings = ref
                              .read(customerChatProvider(customerId))
                              .lastImportWarnings;
                          if (warnings.isNotEmpty) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Import xong (warnings: ${warnings.length})')),
                            );
                          } else {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                  content: Text('Import thành công')),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text('Import thất bại: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.upload),
                      label: const Text('Import'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _promptFeedbackNotes(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ghi chú feedback (optional)'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Ví dụ: sai vì khách không nhạy cảm giá...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Bỏ qua')),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Gửi')),
        ],
      ),
    );
    return result;
  }

  Widget _buildAiAnalysisSection(BuildContext context, Customer customer) {
    if (!AppConfig.useSupabaseAuth) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildEmptyCard(
          pose: CucaPose.hint,
          title: 'AI Analysis (demo)',
          message: 'Bật Supabase auth để chạy Edge Function ai-chat-analysis.',
        ),
      );
    }

    final ai = ref.watch(customerAiProvider(customer.id));
    final notifier = ref.read(customerAiProvider(customer.id).notifier);

    final types = const [
      'psychology',
      'behavior',
      'needs',
      'financial',
      'product_recommendation',
    ];

    String titleOf(String type) {
      switch (type) {
        case 'psychology':
          return 'Tâm lý';
        case 'behavior':
          return 'Hành vi';
        case 'needs':
          return 'Nhu cầu';
        case 'financial':
          return 'Tài chính';
        case 'product_recommendation':
          return 'Gợi ý sản phẩm';
        default:
          return type;
      }
    }

    Widget kv(String k, String v) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 120,
                  child: Text(k, style: TextStyle(color: Colors.grey[600]))),
              Expanded(child: Text(v)),
            ],
          ),
        );

    Widget feedbackRow(String type) {
      final id = ai.analysisIds[type];
      if (id == null) return const SizedBox.shrink();

      final current = ai.feedbackByType[type];
      Future<void> send(String feedback, {bool askNotes = false}) async {
        final notes = askNotes ? await _promptFeedbackNotes(context) : null;
        try {
          await notifier.submitFeedback(
            analysisId: id,
            feedback: feedback,
            feedbackNotes: notes,
          );
          notifier.setLocalFeedback(analysisType: type, feedback: feedback);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã gửi feedback')),
          );
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gửi feedback thất bại: $e')),
          );
        }
      }

      String labelOf(String? v) {
        switch (v) {
          case 'correct':
            return 'Đúng';
          case 'partially_correct':
            return 'Tạm đúng';
          case 'incorrect':
            return 'Sai';
          default:
            return 'Chưa feedback';
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s2),
          Text('Feedback: ${labelOf(current)}',
              style: TextStyle(color: Colors.grey[700], fontSize: 12)),
          const SizedBox(height: AppSpacing.s2),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => send('correct'),
                icon: const Icon(Icons.thumb_up),
                label: const Text('Đúng'),
              ),
              OutlinedButton.icon(
                onPressed: () => send('partially_correct', askNotes: true),
                icon: const Icon(Icons.thumbs_up_down),
                label: const Text('Tạm đúng'),
              ),
              OutlinedButton.icon(
                onPressed: () => send('incorrect', askNotes: true),
                icon: const Icon(Icons.thumb_down),
                label: const Text('Sai'),
              ),
            ],
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AI Analysis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  TextButton(
                    onPressed:
                        ai.isRunning ? null : () => notifier.runAnalysis(),
                    child: ai.isRunning
                        ? const Text('Đang chạy...')
                        : const Text('Chạy phân tích'),
                  ),
                  IconButton(
                    tooltip: 'Force',
                    onPressed: ai.isRunning
                        ? null
                        : () => notifier.runAnalysis(force: true),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ],
          ),
          if (ai.modelName != null || ai.sessionId != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Session: ${ai.sessionId ?? '-'} • Model: ${ai.modelName ?? '-'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          if (ai.error != null)
            Text('Lỗi: ${ai.error}', style: const TextStyle(color: Colors.red)),
          if (ai.analyses.isEmpty)
            _buildEmptyCard(
              pose: CucaPose.hint,
              title: 'Chưa có phân tích',
              message: 'Import chat sessions trước, sau đó chạy phân tích.',
              action: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showImportChatSheet(context, customer.id),
                  icon: const Icon(Icons.upload),
                  label: const Text('Import chat'),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  for (final type in types)
                    if (ai.analyses[type] != null)
                      ExpansionTile(
                        title: Text(titleOf(type)),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Builder(builder: (context) {
                            final out = ai.analyses[type]!;
                            switch (type) {
                              case 'psychology':
                                final summary =
                                    out['summary']?.toString() ?? '-';
                                final tone = out['tone']?.toString() ?? '-';
                                final signals = out['signals'] is List
                                    ? (out['signals'] as List)
                                        .map((e) => e.toString())
                                        .toList()
                                    : const <String>[];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    kv('Summary', summary),
                                    kv('Tone', tone),
                                    if (signals.isNotEmpty)
                                      kv('Signals', signals.join(' • ')),
                                    feedbackRow(type),
                                  ],
                                );
                              case 'behavior':
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    kv(
                                        'Likelihood',
                                        out['likelihood_to_buy']?.toString() ??
                                            '-'),
                                    kv('Risk', out['risk']?.toString() ?? '-'),
                                    kv(
                                        'Next action',
                                        out['next_best_action']?.toString() ??
                                            '-'),
                                    feedbackRow(type),
                                  ],
                                );
                              case 'financial':
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    kv('Sensitivity',
                                        out['sensitivity']?.toString() ?? '-'),
                                    kv('Note', out['note']?.toString() ?? '-'),
                                    feedbackRow(type),
                                  ],
                                );
                              case 'product_recommendation':
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    kv('Idea', out['idea']?.toString() ?? '-'),
                                    feedbackRow(type),
                                  ],
                                );
                              case 'needs':
                                final inferred = out['inferred_needs'] is List
                                    ? (out['inferred_needs'] as List)
                                        .map((e) => e.toString())
                                        .toList()
                                    : const <String>[];
                                final suggestions =
                                    out['content_suggestions'] is List
                                        ? (out['content_suggestions'] as List)
                                            .map((e) => e.toString())
                                            .toList()
                                        : const <String>[];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (inferred.isNotEmpty)
                                      kv('Needs', inferred.join(' • ')),
                                    if (suggestions.isNotEmpty)
                                      kv('Suggestions',
                                          suggestions.join('\n• ')),
                                    kv(
                                        'Contact time',
                                        out['optimal_contact_time']
                                                ?.toString() ??
                                            '-'),
                                    kv('Notes',
                                        out['notes']?.toString() ?? '-'),
                                    feedbackRow(type),
                                  ],
                                );
                              default:
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(out.toString()),
                                    feedbackRow(type),
                                  ],
                                );
                            }
                          }),
                        ],
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTemplateComposerSection(
      BuildContext context, Customer customer) {
    if (!AppConfig.useSupabaseAuth) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildEmptyCard(
          pose: CucaPose.hint,
          title: 'Templates (demo)',
          message:
              'Bật Supabase auth để dùng templates và render theo customer.',
        ),
      );
    }

    final templates = ref.watch(customerTemplatesProvider(customer.id));
    final notifier = ref.read(customerTemplatesProvider(customer.id).notifier);

    final selectedTemplateId = templates.selectedTemplateId;
    MessageTemplate? selected;
    if (selectedTemplateId != null) {
      for (final t in templates.templates) {
        if (t.id == selectedTemplateId) {
          selected = t;
          break;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Templates',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                tooltip: 'Refresh',
                onPressed: () => notifier.refresh(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (templates.error != null)
            Text('Lỗi: ${templates.error}',
                style: const TextStyle(color: Colors.red)),
          if (templates.isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator()))
          else if (templates.templates.isEmpty)
            _buildEmptyCard(
              pose: CucaPose.hint,
              title: 'Chưa có template',
              message:
                  'Tạo templates ở backend trước (seed/admin), sau đó refresh.',
            )
          else ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: templates.selectedTemplateId,
                decoration: const InputDecoration(
                  labelText: 'Chọn template',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: InputBorder.none,
                ),
                items: [
                  for (final t in templates.templates)
                    DropdownMenuItem(
                      value: t.id,
                      child: Text(
                          '${t.templateName} • ${t.category} (used ${t.usageCount})'),
                    ),
                ],
                onChanged: (id) {
                  if (id == null) return;
                  notifier.selectTemplate(id);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            if (selected != null)
              Text(
                'Variables: ${(selected.variables.isEmpty ? [
                    'customer_name',
                    'phone_number',
                    'zalo_id'
                  ] : selected.variables).join(', ')}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            const SizedBox(height: AppSpacing.s3),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: templates.selectedTemplateId == null ||
                            templates.isLoading
                        ? null
                        : () => notifier.renderSelected(trackUsage: true),
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Render'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (templates.renderedContent ?? '').trim().isEmpty
                        ? null
                        : () async {
                            final text = templates.renderedContent ?? '';
                            await Clipboard.setData(ClipboardData(text: text));
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã copy nội dung')),
                            );
                          },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s3),
            if ((templates.renderedSubject ?? '').trim().isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text('Subject: ${templates.renderedSubject}'),
              ),
            if ((templates.renderedContent ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s3),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  templates.renderedContent!,
                  style: const TextStyle(height: 1.35),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, Customer customer) {
    if (!AppConfig.useSupabaseAuth) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildEmptyCard(
          pose: CucaPose.hint,
          title: 'Tasks (demo)',
          message: 'Bật Supabase auth để đồng bộ tasks theo customer.',
        ),
      );
    }

    final state = ref.watch(customerTasksPurchasesProvider(customer.id));
    final notifier =
        ref.read(customerTasksPurchasesProvider(customer.id).notifier);

    String typeLabel(String t) {
      switch (t) {
        case 'call':
          return 'Gọi';
        case 'send_message':
          return 'Nhắn tin';
        case 'meeting':
          return 'Gặp';
        case 'follow_up':
          return 'Follow-up';
        case 'send_document':
          return 'Gửi tài liệu';
        default:
          return t;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tasks',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => notifier.refreshTasks(),
                    icon: const Icon(Icons.refresh),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddTaskSheet(context, customer.id),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.isLoadingTasks)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator()))
          else if (state.tasks.isEmpty)
            _buildEmptyCard(
              pose: CucaPose.hint,
              title: 'Chưa có task',
              message: 'Tạo task đầu tiên để theo dõi công việc chăm khách.',
              action: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddTaskSheet(context, customer.id),
                  icon: const Icon(Icons.add_task),
                  label: const Text('Tạo task'),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  for (final t in state.tasks)
                    ListTile(
                      leading: Checkbox(
                        value: t.status == 'completed',
                        onChanged: t.status == 'completed'
                            ? null
                            : (_) async {
                                try {
                                  await notifier.markTaskCompleted(t.id);
                                  if (AppConfig.useSupabaseAuth) {
                                    unawaited(ref
                                        .read(homeRemindersProvider.notifier)
                                        .refresh());
                                  }
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Đã hoàn thành task')),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Lỗi: $e')),
                                  );
                                }
                              },
                      ),
                      title: Text(t.title),
                      subtitle: Text(
                          '${typeLabel(t.taskType)} • Due ${t.dueDate} • ${t.status}'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, String customerId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String taskType = 'follow_up';
    String priority = 'medium';
    DateTime due = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tạo task',
                  style: AppTextStyle.title3),
              const SizedBox(height: AppSpacing.s3),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    labelText: 'Tiêu đề', border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSpacing.s3),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Mô tả (optional)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSpacing.s3),
              DropdownButtonFormField<String>(
                value: taskType,
                decoration: const InputDecoration(
                    labelText: 'Loại', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                      value: 'follow_up', child: Text('Follow-up')),
                  DropdownMenuItem(value: 'call', child: Text('Gọi')),
                  DropdownMenuItem(
                      value: 'send_message', child: Text('Nhắn tin')),
                  DropdownMenuItem(value: 'meeting', child: Text('Gặp')),
                  DropdownMenuItem(
                      value: 'send_document', child: Text('Gửi tài liệu')),
                ],
                onChanged: (v) => setSheetState(() => taskType = v ?? taskType),
              ),
              const SizedBox(height: AppSpacing.s3),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(
                    labelText: 'Priority', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (v) => setSheetState(() => priority = v ?? priority),
              ),
              const SizedBox(height: AppSpacing.s3),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: due,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked == null) return;
                  setSheetState(() => due = picked);
                },
                icon: const Icon(Icons.event),
                label: Text('Due: ${DateFormat('dd/MM/yyyy').format(due)}'),
              ),
              const SizedBox(height: AppSpacing.s3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    final dueDate =
                        '${due.year.toString().padLeft(4, '0')}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}';
                    try {
                      await ref
                          .read(customerTasksPurchasesProvider(customerId)
                              .notifier)
                          .createTask(
                            taskType: taskType,
                            title: title,
                            dueDate: dueDate,
                            description: descController.text.trim().isEmpty
                                ? null
                                : descController.text.trim(),
                            priority: priority,
                          );
                      if (AppConfig.useSupabaseAuth) {
                        unawaited(
                            ref.read(homeRemindersProvider.notifier).refresh());
                      }
                      if (context.mounted) Navigator.pop(context);
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Đã tạo task')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('Tạo task thất bại: $e')),
                      );
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchasesSection(BuildContext context, Customer customer) {
    if (!AppConfig.useSupabaseAuth) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildEmptyCard(
          pose: CucaPose.hint,
          title: 'Purchases (demo)',
          message: 'Bật Supabase auth để đồng bộ purchases theo customer.',
        ),
      );
    }

    final state = ref.watch(customerTasksPurchasesProvider(customer.id));
    final notifier =
        ref.read(customerTasksPurchasesProvider(customer.id).notifier);

    String money(double v) => '${v.toStringAsFixed(0)}₫';

    final total = customer.totalSpent;
    final lastPurchase = customer.lastPurchaseDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Purchases',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => notifier.refreshPurchases(),
                    icon: const Icon(Icons.refresh),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        _showAddPurchaseSheet(context, customer.id),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Thêm'),
                  ),
                ],
              ),
            ],
          ),
          if (total != null || lastPurchase != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Total: ${total == null ? '-' : money(total)} • Last: ${lastPurchase == null ? '-' : DateFormat('dd/MM/yyyy').format(lastPurchase)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          if (state.isLoadingPurchases)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator()))
          else if (state.purchases.isEmpty)
            _buildEmptyCard(
              pose: CucaPose.hint,
              title: 'Chưa có purchase',
              message: 'Thêm giao dịch/đơn hàng để theo dõi total_spent.',
              action: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddPurchaseSheet(context, customer.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm purchase'),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  for (final p in state.purchases)
                    ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(p.productName),
                      subtitle: Text('${p.purchaseDate} • ${p.paymentStatus}'),
                      trailing: Text(money(p.finalPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAddPurchaseSheet(BuildContext context, String customerId) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final notesController = TextEditingController();
    String paymentStatus = 'pending';
    DateTime date = DateTime.now();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thêm purchase',
                  style: AppTextStyle.title3),
              const SizedBox(height: AppSpacing.s3),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm/đơn',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSpacing.s3),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Giá (VND)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSpacing.s3),
              DropdownButtonFormField<String>(
                value: paymentStatus,
                decoration: const InputDecoration(
                    labelText: 'Trạng thái thanh toán',
                    border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'partial', child: Text('Partial')),
                  DropdownMenuItem(
                      value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(
                      value: 'cancelled', child: Text('Cancelled')),
                ],
                onChanged: (v) =>
                    setSheetState(() => paymentStatus = v ?? paymentStatus),
              ),
              const SizedBox(height: AppSpacing.s3),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked == null) return;
                  setSheetState(() => date = picked);
                },
                icon: const Icon(Icons.event),
                label: Text('Date: ${DateFormat('dd/MM/yyyy').format(date)}'),
              ),
              const SizedBox(height: AppSpacing.s3),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSpacing.s3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final price = double.tryParse(priceController.text.trim());
                    if (price == null) return;

                    final purchaseDate =
                        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

                    try {
                      await ref
                          .read(customerTasksPurchasesProvider(customerId)
                              .notifier)
                          .createPurchase(
                            productName: name,
                            price: price,
                            purchaseDate: purchaseDate,
                            paymentStatus: paymentStatus,
                            notes: notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim(),
                          );
                      if (context.mounted) Navigator.pop(context);
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Đã thêm purchase')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('Thêm purchase thất bại: $e')),
                      );
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(BuildContext context, Customer customer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Giao dịch/Đơn hàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _showAddOrEditTransactionSheet(context,
                    customerId: customer.id),
                icon: const Icon(Icons.add),
                label: const Text('Thêm'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (customer.transactions.isEmpty)
            _buildEmptyCard(
              pose: CucaPose.success,
              title: 'Chưa có giao dịch',
              message: 'Thêm giao dịch đầu tiên để theo dõi trạng thái khách.',
              action: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddOrEditTransactionSheet(context,
                      customerId: customer.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm giao dịch'),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  for (final t in customer.transactions)
                    ListTile(
                      title: Text(t.title),
                      subtitle: Text(
                          '${DateFormat('dd/MM').format(t.date)} • ${_formatVnd(t.amountVnd)}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showAddOrEditTransactionSheet(context,
                                customerId: customer.id, initial: t);
                          } else if (value == 'delete') {
                            ref
                                .read(customersProvider.notifier)
                                .deleteTransaction(customer.id, t.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Đã xóa giao dịch')));
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Sửa')),
                          PopupMenuItem(value: 'delete', child: Text('Xóa')),
                        ],
                      ),
                      leading: _transactionStatusChip(t.status),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _transactionStatusChip(TransactionStatus status) {
    Color color;
    String label;
    switch (status) {
      case TransactionStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case TransactionStatus.won:
        color = Colors.green;
        label = 'Won';
        break;
      case TransactionStatus.lost:
        color = Colors.grey;
        label = 'Lost';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  String _formatVnd(int amount) {
    final s = NumberFormat.decimalPattern('vi').format(amount);
    return '$sđ';
  }

  void _showAddOrEditTransactionSheet(
    BuildContext context, {
    required String customerId,
    TransactionEntry? initial,
  }) {
    final titleController = TextEditingController(text: initial?.title ?? '');
    final amountController =
        TextEditingController(text: initial?.amountVnd.toString() ?? '');
    final noteController = TextEditingController(text: initial?.note ?? '');
    TransactionStatus status = initial?.status ?? TransactionStatus.pending;
    DateTime date = initial?.date ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                initial == null ? 'Thêm giao dịch' : 'Sửa giao dịch',
                style:
                    AppTextStyle.title3,
              ),
              const SizedBox(height: AppSpacing.s3),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    labelText: 'Tên giao dịch', border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSpacing.s3),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                    labelText: 'Giá trị (VND)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.s3),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TransactionStatus>(
                      value: status,
                      decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(
                            value: TransactionStatus.pending,
                            child: Text('Pending')),
                        DropdownMenuItem(
                            value: TransactionStatus.won, child: Text('Won')),
                        DropdownMenuItem(
                            value: TransactionStatus.lost, child: Text('Lost')),
                      ],
                      onChanged: (v) => setSheetState(
                          () => status = v ?? TransactionStatus.pending),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2020),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked == null) return;
                        setSheetState(() => date = picked);
                      },
                      icon: const Icon(Icons.event),
                      label: Text(DateFormat('dd/MM/yyyy').format(date)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s3),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                    labelText: 'Ghi chú', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.s3),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final amount =
                        int.tryParse(amountController.text.trim()) ?? 0;
                    if (title.isEmpty || amount <= 0) return;

                    final entry = TransactionEntry(
                      id: initial?.id ?? const Uuid().v4(),
                      title: title,
                      amountVnd: amount,
                      status: status,
                      date: date,
                      note: noteController.text.trim().isEmpty
                          ? null
                          : noteController.text.trim(),
                    );

                    if (initial == null) {
                      ref
                          .read(customersProvider.notifier)
                          .addTransaction(customerId, entry);
                    } else {
                      ref
                          .read(customersProvider.notifier)
                          .updateTransaction(customerId, entry);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiChatSection(BuildContext context, Customer customer) {
    final messages = customer.aiChat;
    return Padding(
      key: _aiChatKey,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hỏi CUCA',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _promptChip(customer, 'Gợi ý tin nhắn follow-up'),
              _promptChip(customer, 'Tóm tắt lịch sử khách này'),
              _promptChip(customer, 'Đề xuất bước tiếp theo'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            child: messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s4),
                      child: Text(
                        'Chưa có hội thoại.\nHãy chọn prompt hoặc nhập câu hỏi.',
                        style: TextStyle(color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      final isUser = m.role == AiMessageRole.user;
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: isUser
                                ? AppColors.primary.withOpacity(0.12)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(m.content),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _aiInputController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập câu hỏi cho CUCA…',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Gửi',
                icon: const Icon(Icons.send),
                onPressed: () {
                  final prompt = _aiInputController.text.trim();
                  if (prompt.isEmpty) return;
                  _aiInputController.clear();
                  _sendAiPrompt(customer, prompt);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _promptChip(Customer customer, String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () => _sendAiPrompt(customer, text),
    );
  }

  void _sendAiPrompt(Customer customer, String prompt) {
    final now = DateTime.now();
    ref.read(customersProvider.notifier).addAiMessage(
          customer.id,
          AiChatMessage(
            id: const Uuid().v4(),
            role: AiMessageRole.user,
            content: prompt,
            timestamp: now,
          ),
        );

    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      ref.read(customersProvider.notifier).addAiMessage(
            customer.id,
            AiChatMessage(
              id: const Uuid().v4(),
              role: AiMessageRole.assistant,
              content: _fakeAiResponse(customer, prompt),
              timestamp: DateTime.now(),
            ),
          );
    });
  }

  String _fakeAiResponse(Customer customer, String prompt) {
    if (prompt.toLowerCase().contains('follow-up')) {
      return 'Gợi ý tin nhắn: “Chào ${customer.fullName}, em nhắc lại thông tin hôm trước mình trao đổi. Anh/chị có cần em gửi thêm báo giá/ưu đãi không ạ?”';
    }
    if (prompt.toLowerCase().contains('tóm tắt')) {
      final last = customer.interactions.isEmpty
          ? 'chưa có'
          : _getInteractionLabel(customer.interactions.first.type);
      return 'Tóm tắt nhanh: stage hiện tại ${customer.listStageGroup.label}. Tương tác gần nhất: $last. Hãy bổ sung ghi chú nếu có thêm thông tin.';
    }
    if (prompt.toLowerCase().contains('bước')) {
      return 'Đề xuất: đặt lịch follow-up trong 2 ngày tới, nhắc lại benefit chính + hỏi nhu cầu hiện tại.';
    }
    return 'Tính năng AI Chat đang phát triển.';
  }
}
