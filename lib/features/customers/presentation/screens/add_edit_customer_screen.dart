import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/node_api_client.dart';
import '../../domain/models/customer_model.dart';
import '../models/customer_list_options.dart';
import '../providers/customers_provider.dart';
import '../../../../core/presentation/widgets/cuca_mascot.dart';
import 'customer_detail_screen.dart';

enum PhoneLabel { primary, secondary, company, other }

extension PhoneLabelUi on PhoneLabel {
  String get label {
    switch (this) {
      case PhoneLabel.primary:
        return 'Chính';
      case PhoneLabel.secondary:
        return 'Phụ';
      case PhoneLabel.company:
        return 'Công ty';
      case PhoneLabel.other:
        return 'Khác';
    }
  }
}

enum SocialPlatform { zalo, facebook, other }

extension SocialPlatformUi on SocialPlatform {
  String get label {
    switch (this) {
      case SocialPlatform.zalo:
        return 'Zalo';
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.other:
        return 'Khác';
    }
  }

  IconData get icon {
    switch (this) {
      case SocialPlatform.zalo:
        return Icons.chat_bubble;
      case SocialPlatform.facebook:
        return Icons.facebook;
      case SocialPlatform.other:
        return Icons.link;
    }
  }

  Color get color {
    switch (this) {
      case SocialPlatform.zalo:
        return Colors.blueAccent;
      case SocialPlatform.facebook:
        return Colors.indigo;
      case SocialPlatform.other:
        return Colors.grey;
    }
  }
}

class _PhoneDraft {
  _PhoneDraft({
    required this.id,
    required this.label,
    required this.controller,
    required this.hasZalo,
  });

  final String id;
  PhoneLabel label;
  final TextEditingController controller;
  bool hasZalo;
}

class _SocialDraft {
  _SocialDraft({
    required this.id,
    required this.platform,
    required this.controller,
  });

  final String id;
  SocialPlatform platform;
  final TextEditingController controller;
}

class AddEditCustomerScreen extends ConsumerStatefulWidget {
  final Customer? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  ConsumerState<AddEditCustomerScreen> createState() =>
      _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends ConsumerState<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isDirty = false;

  CustomerListStageFilter _stage = CustomerListStageFilter.warm;
  String? _source;

  final List<_PhoneDraft> _phones = [];
  final List<_SocialDraft> _socialLinks = [];

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();

    final customer = widget.customer;
    if (customer != null) {
      _nameController.text = customer.fullName;
      _notesController.text = customer.notes ?? '';
      _source = customer.source;
      _stage = customer.listStageGroup == CustomerListStageFilter.all
          ? CustomerListStageFilter.warm
          : customer.listStageGroup;

      _phones.addAll(_draftPhonesFromCustomer(customer));
      _socialLinks.addAll(_draftSocialFromCustomer(customer));
    } else {
      _phones.add(
        _PhoneDraft(
          id: const Uuid().v4(),
          label: PhoneLabel.primary,
          controller: TextEditingController(),
          hasZalo: false,
        ),
      );
    }

    for (final p in _phones) {
      p.controller.addListener(_markDirtyOnce);
    }
    for (final s in _socialLinks) {
      s.controller.addListener(_markDirtyOnce);
    }
    _nameController.addListener(_markDirtyOnce);
    _notesController.addListener(_markDirtyOnce);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    for (final p in _phones) {
      p.controller.dispose();
    }
    for (final s in _socialLinks) {
      s.controller.dispose();
    }
    super.dispose();
  }

  void _markDirtyOnce() {
    if (_isDirty) return;
    setState(() => _isDirty = true);
  }

  List<_PhoneDraft> _draftPhonesFromCustomer(Customer customer) {
    final drafts = <_PhoneDraft>[
      _PhoneDraft(
        id: const Uuid().v4(),
        label: PhoneLabel.primary,
        controller: TextEditingController(text: customer.phoneNumber),
        hasZalo: (customer.zaloLink ?? '').isNotEmpty,
      ),
    ];
    for (final p in customer.additionalPhones) {
      drafts.add(
        _PhoneDraft(
          id: const Uuid().v4(),
          label: PhoneLabel.secondary,
          controller: TextEditingController(text: p),
          hasZalo: false,
        ),
      );
    }
    return drafts;
  }

  List<_SocialDraft> _draftSocialFromCustomer(Customer customer) {
    final drafts = <_SocialDraft>[];
    if ((customer.zaloLink ?? '').isNotEmpty) {
      drafts.add(
        _SocialDraft(
          id: const Uuid().v4(),
          platform: SocialPlatform.zalo,
          controller: TextEditingController(text: customer.zaloLink),
        ),
      );
    }
    if ((customer.facebookLink ?? '').isNotEmpty) {
      drafts.add(
        _SocialDraft(
          id: const Uuid().v4(),
          platform: SocialPlatform.facebook,
          controller: TextEditingController(text: customer.facebookLink),
        ),
      );
    }
    return drafts;
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_isDirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bỏ thay đổi?'),
        content:
            const Text('Bạn có thay đổi chưa lưu. Bạn muốn bỏ thay đổi không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tiếp tục chỉnh')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Bỏ')),
        ],
      ),
    );
    return result ?? false;
  }

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('84')) {
      return '0${digits.substring(2)}';
    }
    return digits;
  }

  String? _validatePhone(String? value, {required String currentId}) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Vui lòng nhập SĐT';

    final normalized = _normalizePhone(raw);
    if (normalized.length != 10) return 'SĐT phải đủ 10 số';
    if (!normalized.startsWith('0')) return 'SĐT phải bắt đầu bằng 0';

    final duplicates = _phones
        .where((p) => p.id != currentId)
        .map((p) => _normalizePhone(p.controller.text))
        .where((x) => x.isNotEmpty)
        .toSet();
    if (duplicates.contains(normalized)) return 'SĐT bị trùng trong khách này';

    return null;
  }

  CustomerStage _mapGroupToStage(
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
        return CustomerStage.lost;
      case CustomerListStageFilter.all:
        return current;
    }
  }

  bool _isValidUrl(String text) {
    final t = text.trim();
    if (t.isEmpty) return true;
    final uri = Uri.tryParse(t);
    return uri != null &&
        (uri.scheme.isNotEmpty ||
            t.startsWith('zalo://') ||
            t.startsWith('fb://'));
  }

  Future<void> _pasteToController(TextEditingController controller) async {
    final data = await Clipboard.getData('text/plain');
    final text = (data?.text ?? '').trim();
    if (text.isEmpty) return;
    controller.text = text;
    _markDirtyOnce();
  }

  Future<void> _mockImportContact() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Tính năng nhập liên hệ đang phát triển.')),
    );
    if (_nameController.text.trim().isEmpty)
      _nameController.text = 'Contact Demo';
    if (_phones.isNotEmpty && _phones.first.controller.text.trim().isEmpty) {
      _phones.first.controller.text = '0912345678';
      _phones.first.hasZalo = true;
      setState(() {});
    }
    _markDirtyOnce();
  }

  Future<void> _pickAvatarPlaceholder() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Tính năng chọn avatar đang phát triển.')),
    );
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final primary = _phones.firstOrNull;
    if (primary == null ||
        _validatePhone(primary.controller.text, currentId: primary.id) !=
            null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập ít nhất 1 SĐT hợp lệ.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final phonesNormalized =
        _phones.map((p) => _normalizePhone(p.controller.text)).toList();
    final phoneNumber = phonesNormalized.first;
    final additionalPhones =
        phonesNormalized.skip(1).where((x) => x.isNotEmpty).toList();
    final hasAnyZalo = _phones.any((p) => p.hasZalo);

    String? zaloLink;
    for (final s in _socialLinks) {
      if (s.platform == SocialPlatform.zalo) {
        final v = s.controller.text.trim();
        if (v.isNotEmpty) zaloLink = v;
        break;
      }
    }
    String? facebookLink;
    for (final s in _socialLinks) {
      if (s.platform == SocialPlatform.facebook) {
        final v = s.controller.text.trim();
        if (v.isNotEmpty) facebookLink = v;
        break;
      }
    }

    if (zaloLink == null && hasAnyZalo) {
      zaloLink = 'zalo://chat?phone=$phoneNumber';
    }

    final stage = _mapGroupToStage(
        _stage, _isEditing ? widget.customer!.stage : CustomerStage.haveNeeds);

    Customer? saved;
    try {
      if (_isEditing) {
        final id = widget.customer!.id;
        saved = await ref.read(customersProvider.notifier).updateCustomer(
              customerId: id,
              fullName: name,
              phoneNumber: phoneNumber,
              additionalPhones: additionalPhones,
              stage: stage == CustomerStage.lost ? null : stage,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              source: _source,
              tags: _mergeTags(hasAnyZalo: hasAnyZalo),
              zaloLink: zaloLink,
              facebookLink: facebookLink,
            );
      } else {
        if (stage == CustomerStage.lost) {
          throw Exception('Stage "Lost" chưa hỗ trợ ở backend.');
        }
        saved = await ref.read(customersProvider.notifier).createCustomer(
              fullName: name,
              phoneNumber: phoneNumber,
              additionalPhones: additionalPhones,
              stage: stage,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              source: _source,
              tags: _mergeTags(hasAnyZalo: hasAnyZalo),
              zaloLink: zaloLink,
              facebookLink: facebookLink,
            );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final message = e is NodeApiException ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu thất bại: $message')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    final savedCustomer = saved;
    await _showSaveSuccess(savedCustomer.id);

    if (!mounted) return;
    if (_isEditing) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CustomerDetailScreen(customerId: savedCustomer.id)),
    );
  }

  List<String> _mergeTags({required bool hasAnyZalo}) {
    final base = _isEditing ? widget.customer!.tags : <String>[];
    final next = {...base};
    if (hasAnyZalo) next.add('Zalo');
    return next.toList();
  }

  Future<void> _showSaveSuccess(String customerId) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CucaMascot(pose: CucaPose.success, height: 140, animate: false),
            SizedBox(height: 12),
            Text('Đã lưu khách hàng',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showSocialGuide() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Hướng dẫn lấy link',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Zalo: mở trang cá nhân → Chia sẻ/Copy link (nếu có).'),
              SizedBox(height: 6),
              Text('Facebook: vào profile → Copy link trang cá nhân.'),
              SizedBox(height: 6),
              Text(
                  'Liên kết sẽ được lưu và sử dụng khi tính năng mở link được triển khai.'),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final ok = await _confirmDiscardChanges();
        if (!ok) return;
        if (!context.mounted) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Sửa khách hàng' : 'Thêm khách hàng'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final ok = await _confirmDiscardChanges();
              if (!ok) return;
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
          actions: [
            if (_isEditing)
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final ok = await _confirmDiscardChanges();
                        if (!ok) return;
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                child: const Text('Hủy'),
              ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                _buildBasicInfo(),
                const SizedBox(height: 16),
                _buildPhones(),
                const SizedBox(height: 16),
                _buildStage(),
                const SizedBox(height: 16),
                _buildSocialLinks(),
                const SizedBox(height: 16),
                _buildNotesAndSource(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4))
              ],
            ),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Lưu',
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Thông tin cơ bản',
          trailing: TextButton.icon(
            onPressed: _mockImportContact,
            icon: const Icon(Icons.contacts),
            label: const Text('Chọn từ danh bạ'),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: _pickAvatarPlaceholder,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[200],
                child: Text(
                  _nameController.text.trim().isEmpty
                      ? '?'
                      : _nameController.text.trim()[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Vui lòng nhập tên' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Số điện thoại',
          trailing: TextButton.icon(
            onPressed: () {
              setState(() {
                final draft = _PhoneDraft(
                  id: const Uuid().v4(),
                  label: PhoneLabel.secondary,
                  controller: TextEditingController(),
                  hasZalo: false,
                );
                draft.controller.addListener(_markDirtyOnce);
                _phones.add(draft);
                _isDirty = true;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm số'),
          ),
        ),
        const SizedBox(height: 12),
        for (final phone in _phones) _buildPhoneItem(phone),
      ],
    );
  }

  Widget _buildPhoneItem(_PhoneDraft phone) {
    final canRemove = _phones.length > 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<PhoneLabel>(
                  value: phone.label,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Label',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                  items: PhoneLabel.values
                      .map((l) =>
                          DropdownMenuItem(value: l, child: Text(l.label, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: _isLoading
                      ? null
                      : (v) {
                          if (v == null) return;
                          setState(() {
                            phone.label = v;
                            _isDirty = true;
                          });
                        },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: phone.controller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: phone.label == PhoneLabel.primary
                        ? 'SĐT chính *'
                        : 'SĐT',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (v) => _validatePhone(v, currentId: phone.id),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Xóa',
                onPressed: !canRemove || _isLoading
                    ? null
                    : () {
                        setState(() {
                          _phones.removeWhere((p) => p.id == phone.id);
                          phone.controller.dispose();
                          _isDirty = true;
                        });
                      },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  value: phone.hasZalo,
                  onChanged: _isLoading
                      ? null
                      : (v) {
                          setState(() {
                            phone.hasZalo = v ?? false;
                            _isDirty = true;
                          });
                        },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Có Zalo', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStage() {
    final options = [
      CustomerListStageFilter.hot,
      CustomerListStageFilter.warm,
      CustomerListStageFilter.cold,
      CustomerListStageFilter.won,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Stage'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in options)
              ChoiceChip(
                label: Text(o.label),
                selected: _stage == o,
                onSelected: _isLoading
                    ? null
                    : (_) {
                        setState(() {
                          _stage = o;
                          _isDirty = true;
                        });
                      },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Liên kết MXH',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Hướng dẫn',
                onPressed: _showSocialGuide,
                icon: const Icon(Icons.help_outline),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    final draft = _SocialDraft(
                      id: const Uuid().v4(),
                      platform: SocialPlatform.zalo,
                      controller: TextEditingController(),
                    );
                    draft.controller.addListener(_markDirtyOnce);
                    _socialLinks.add(draft);
                    _isDirty = true;
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm link'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final link in _socialLinks) _buildSocialItem(link),
      ],
    );
  }

  Widget _buildSocialItem(_SocialDraft link) {
    final canRemove = _socialLinks.length > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<SocialPlatform>(
              value: link.platform,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Nền tảng'),
              items: SocialPlatform.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (v) {
                      if (v == null) return;
                      setState(() {
                        link.platform = v;
                        _isDirty = true;
                      });
                    },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: link.controller,
              decoration: InputDecoration(
                labelText: 'URL / Deep link',
                border: const OutlineInputBorder(),
                prefixIcon:
                    Icon(link.platform.icon, color: link.platform.color),
                suffixIcon: IconButton(
                  tooltip: 'Paste',
                  icon: const Icon(Icons.paste),
                  onPressed: _isLoading
                      ? null
                      : () => _pasteToController(link.controller),
                ),
              ),
              validator: (v) =>
                  _isValidUrl(v ?? '') ? null : 'URL không hợp lệ',
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Xóa',
            onPressed: !canRemove || _isLoading
                ? null
                : () {
                    setState(() {
                      _socialLinks.removeWhere((s) => s.id == link.id);
                      link.controller.dispose();
                      _isDirty = true;
                    });
                  },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesAndSource() {
    final sources = const ['Giới thiệu', 'Facebook', 'Zalo', 'Website', 'Khác'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ghi chú & Nguồn'),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _source != null && sources.contains(_source) ? _source : null,
          decoration: const InputDecoration(
            labelText: 'Nguồn khách (optional)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.source),
          ),
          items: sources
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: _isLoading
              ? null
              : (v) {
                  setState(() {
                    _source = v;
                    _isDirty = true;
                  });
                },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Ghi chú',
            hintText: 'Ghi chú về nhu cầu, tình huống, bối cảnh của khách...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note),
          ),
        ),
      ],
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
