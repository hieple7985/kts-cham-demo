import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/realtime/realtime_sync_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../customers/presentation/screens/add_edit_customer_screen.dart';
import '../../../customers/presentation/screens/customer_list_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'calendar_screen.dart';
import 'cuca_chat_screen.dart';
import 'home_screen.dart';

class AppShellScreen extends ConsumerStatefulWidget {
  const AppShellScreen({super.key});

  @override
  ConsumerState<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends ConsumerState<AppShellScreen> {
  int _currentIndex = 0;
  int _homeBadgeCount = 0;

  void _setTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(realtimeSyncProvider);

    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Main content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(
                  onOpenCustomerList: () => _setTab(1),
                  onAddCustomer: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddEditCustomerScreen()),
                    );
                  },
                  onAskCuca: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CucaChatScreen()),
                    );
                  },
                  onPendingRemindersChanged: (count) {
                    if (!mounted) return;
                    if (_homeBadgeCount == count) return;
                    setState(() => _homeBadgeCount = count);
                  },
                ),
                const CustomerListScreen(),
                const CalendarScreen(),
                const SettingsScreen(),
              ],
            ),
          ),
          // App footer (Web only)
          const AppFooter(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: theme.colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: _BadgedIcon(
              icon: Icons.home,
              count: _homeBadgeCount,
            ),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Khách hàng'),
          const BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch'),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
        onTap: _setTab,
      ),
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return Icon(icon);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: -10,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.dangerText,
              borderRadius: BorderRadius.circular(2),
            ),
            constraints: const BoxConstraints(minWidth: 18),
            child: Text(
              count > 99 ? '99+' : '$count',
              textAlign: TextAlign.center,
              style: AppTextStyle.subtextStrong.copyWith(
                color: AppColors.white,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
