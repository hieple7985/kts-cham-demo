import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';

/// Calendar view types
enum CalendarView { month, week, day }

/// Mock event model
class CalendarEvent {
  final String id;
  final String title;
  final String customerName;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final EventType type;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.customerName,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.type,
  });
}

enum EventType {
  reminder,
  call,
  meeting,
  task,
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static final DateTime _now = DateTime.now();

  CalendarView _currentView = CalendarView.month;
  DateTime _focusedMonth = _now;
  DateTime? _selectedDay = _now;
  final Set<DateTime> _eventsDays = {};

  // Mock events - will be replaced with real data
  late final List<CalendarEvent> _mockEvents = [
    CalendarEvent(
      id: '1',
      title: 'Chăm sóc khách hàng',
      customerName: 'Nguyễn Văn A',
      date: DateTime(_now.year, _now.month, 15),
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      type: EventType.call,
    ),
    CalendarEvent(
      id: '2',
      title: 'Hẹn gặp',
      customerName: 'Trần Thị B',
      date: DateTime(_now.year, _now.month, 15),
      startTime: const TimeOfDay(hour: 14, minute: 0),
      endTime: const TimeOfDay(hour: 15, minute: 30),
      type: EventType.meeting,
    ),
    CalendarEvent(
      id: '3',
      title: 'Nhắc nợ',
      customerName: 'Lê Văn C',
      date: DateTime(_now.year, _now.month, 18),
      startTime: const TimeOfDay(hour: 10, minute: 0),
      type: EventType.reminder,
    ),
    CalendarEvent(
      id: '4',
      title: 'Giao hàng',
      customerName: 'Phạm Thị D',
      date: DateTime(_now.year, _now.month, 18),
      startTime: const TimeOfDay(hour: 16, minute: 0),
      type: EventType.task,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeEventsDays();
  }

  void _initializeEventsDays() {
    for (final event in _mockEvents) {
      final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
      _eventsDays.add(eventDate);
    }
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _mockEvents.where((event) {
      final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
      final queryDate = DateTime(day.year, day.month, day.day);
      return eventDate.isAtSameMomentAs(queryDate);
    }).toList();
  }

  void _goToPrevious() {
    setState(() {
      switch (_currentView) {
        case CalendarView.month:
          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
          break;
        case CalendarView.week:
          _focusedMonth = _focusedMonth.subtract(const Duration(days: 7));
          break;
        case CalendarView.day:
          _focusedMonth = _focusedMonth.subtract(const Duration(days: 1));
          break;
      }
    });
  }

  void _goToNext() {
    setState(() {
      switch (_currentView) {
        case CalendarView.month:
          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
          break;
        case CalendarView.week:
          _focusedMonth = _focusedMonth.add(const Duration(days: 7));
          break;
        case CalendarView.day:
          _focusedMonth = _focusedMonth.add(const Duration(days: 1));
          break;
      }
    });
  }

  void _goToToday() {
    setState(() {
      _focusedMonth = DateTime.now();
      _selectedDay = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lịch', style: AppTextStyle.headline),
            Text(
              _getMonthYearLabel(),
              style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            onPressed: _goToToday,
            tooltip: 'Hôm nay',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildViewToggle(),
          _buildNavigationRow(),
          Expanded(
            child: _buildCalendarBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_event_fab',
        tooltip: 'Thêm sự kiện',
        onPressed: () => _showAddEventDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  String _getMonthYearLabel() {
    const months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.grey2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewToggleButton('Tháng', CalendarView.month),
          _buildViewToggleButton('Tuần', CalendarView.week),
          _buildViewToggleButton('Ngày', CalendarView.day),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(String label, CalendarView view) {
    final isSelected = _currentView == view;
    return InkWell(
      onTap: () => setState(() => _currentView = view),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s1),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyle.caption.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _goToPrevious,
            splashRadius: 20,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _goToNext,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarBody() {
    switch (_currentView) {
      case CalendarView.month:
        return _buildMonthView();
      case CalendarView.week:
        return _buildWeekView();
      case CalendarView.day:
        return _buildDayView();
    }
  }

  Widget _buildMonthView() {
    return Column(
      children: [
        _buildWeekdayHeader(),
        Expanded(
          child: _buildMonthGrid(),
        ),
        _buildEventList(),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey3, width: 1)),
      ),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: AppTextStyle.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday - 1; // 0 = Monday
    final daysInMonth = lastDayOfMonth.day;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.s2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 42, // 6 rows x 7 days
      itemBuilder: (context, index) {
        final dayIndex = index - firstWeekday;
        final isValidDay = dayIndex >= 0 && dayIndex < daysInMonth;
        final day = isValidDay
            ? DateTime(_focusedMonth.year, _focusedMonth.month, dayIndex + 1)
            : null;
        final isToday = day != null &&
            DateTime(day.year, day.month, day.day).isAtSameMomentAs(todayDate);
        final isSelected = day != null &&
            _selectedDay != null &&
            DateTime(day.year, day.month, day.day)
                .isAtSameMomentAs(DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day));
        final hasEvents = day != null && _eventsDays.contains(DateTime(day.year, day.month, day.day));

        if (!isValidDay) {
          return const SizedBox.shrink();
        }

        return _buildDayCell(day!, isToday, isSelected, hasEvents);
      },
    );
  }

  Widget _buildDayCell(DateTime day, bool isToday, bool isSelected, bool hasEvents) {
    return GestureDetector(
      onTap: () => setState(() => _selectedDay = day),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${day.day}',
                style: AppTextStyle.body.copyWith(
                  color: isToday
                      ? AppColors.primary
                      : isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (hasEvents)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    if (_selectedDay == null) return const SizedBox.shrink();

    final events = _getEventsForDay(_selectedDay!);

    return Container(
      height: 250,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.grey3, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s3),
            child: Text(
              'Sự kiện ngày ${_selectedDay!.day}/${_selectedDay!.month}',
              style: AppTextStyle.title3,
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text(
                      'Không có sự kiện',
                      style: AppTextStyle.body.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(events[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s2),
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey3, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getEventTypeColor(event.type),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyle.bodyStrong,
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.customerName} • ${_formatTime(event.startTime)}${event.endTime != null ? ' - ${_formatTime(event.endTime!)}' : ''}',
                  style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(
            _getEventTypeIcon(event.type),
            color: _getEventTypeColor(event.type),
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.reminder:
        return AppColors.warningText;
      case EventType.call:
        return AppColors.primary;
      case EventType.meeting:
        return AppColors.success;
      case EventType.task:
        return AppColors.grey7;
    }
  }

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.reminder:
        return Icons.notifications_outlined;
      case EventType.call:
        return Icons.phone_outlined;
      case EventType.meeting:
        return Icons.people_outlined;
      case EventType.task:
        return Icons.check_circle_outline;
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildWeekView() {
    return const Center(
      child: Text(
        'Week view - Coming soon',
        style: AppTextStyle.body,
      ),
    );
  }

  Widget _buildDayView() {
    return const Center(
      child: Text(
        'Day view - Coming soon',
        style: AppTextStyle.body,
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm sự kiện', style: AppTextStyle.headline),
        content: const Text('Tính năng thêm sự kiện đang phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: AppTextStyle.body),
          ),
        ],
      ),
    );
  }
}
