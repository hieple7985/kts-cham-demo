import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:widgetbook/widgetbook.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/screens/create_password_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_email_screen.dart';
import '../features/auth/presentation/screens/login_phone_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/presentation/screens/signup_email_screen.dart';
import '../features/auth/presentation/screens/signup_phone_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/customers/domain/models/customer_model.dart';
import '../features/customers/presentation/screens/add_edit_customer_screen.dart';
import '../features/customers/presentation/screens/customer_detail_screen.dart';
import '../features/customers/presentation/screens/customer_list_screen.dart';
import '../features/customers/presentation/widgets/customer_card.dart';
import '../features/home/presentation/screens/app_shell_screen.dart';
import '../features/home/presentation/screens/ai_insight_screen.dart';
import '../features/home/presentation/screens/calendar_screen.dart';
import '../features/home/presentation/screens/cuca_chat_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/models/home_reminder.dart';
import '../features/home/presentation/widgets/reminder_item.dart';
import '../features/onboarding/presentation/screens/import_contacts_screen.dart';
import '../features/onboarding/presentation/screens/notification_permission_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_welcome_screen.dart';
import '../features/settings/presentation/screens/change_password_screen.dart';
import '../features/settings/presentation/screens/edit_profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../core/presentation/widgets/cuca_mascot.dart';
import '../features/auth/presentation/widgets/cuca_auth_mascot.dart';

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookFolder(
          name: 'Core',
          children: [
            WidgetbookComponent(
              name: 'CucaMascot',
              useCases: [
                WidgetbookUseCase(
                  name: 'Playground',
                  builder: (context) {
                    final pose = context.knobs.object.dropdown<CucaPose>(
                      label: 'Pose',
                      options: CucaPose.values,
                      labelBuilder: (p) => p.name,
                    );
                    final height = context.knobs.double.slider(
                      label: 'Height',
                      initialValue: 150,
                      min: 80,
                      max: 300,
                    );

                    return Center(
                      child: CucaMascot(
                        pose: pose,
                        height: height,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Customers',
          children: [
            WidgetbookComponent(
              name: 'CustomerCard',
              useCases: [
                WidgetbookUseCase(
                  name: 'Playground',
                  builder: (context) {
                    final stage = context.knobs.object.dropdown<CustomerStage>(
                      label: 'Stage',
                      options: CustomerStage.values,
                      initialOption: CustomerStage.research,
                      labelBuilder: (s) => s.name,
                    );
                    final isDemo = context.knobs.boolean(
                      label: 'Demo badge',
                      initialValue: true,
                    );
                    final name = context.knobs.string(
                      label: 'Full name',
                      initialValue: 'Nguyễn Văn Minh',
                    );
                    final phone = context.knobs.string(
                      label: 'Phone',
                      initialValue: '0912345678',
                    );
                    final selectionMode = context.knobs.boolean(
                      label: 'Selection mode',
                      initialValue: false,
                    );
                    final selected = context.knobs.boolean(
                      label: 'Selected',
                      initialValue: false,
                    );

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: CustomerCard(
                        customer: Customer(
                          id: 'wb_1',
                          fullName: name,
                          phoneNumber: phone,
                          stage: stage,
                          tags: const ['VIP', 'Facebook'],
                          isDemo: isDemo,
                          lastContactDate: DateTime.now().subtract(const Duration(days: 3)),
                          notes: 'Snippet ghi chú gần nhất…',
                        ),
                        selectionMode: selectionMode,
                        selected: selected,
                      ),
                    );
                  },
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'Screens',
              useCases: [
                WidgetbookUseCase.child(
                  name: 'CustomerListScreen',
                  child: const CustomerListScreen(),
                ),
                WidgetbookUseCase(
                  name: 'CustomerDetailScreen (id=1)',
                  builder: (_) => const CustomerDetailScreen(customerId: '1'),
                ),
                WidgetbookUseCase(
                  name: 'AddEditCustomerScreen (Add)',
                  builder: (_) => const AddEditCustomerScreen(),
                ),
                WidgetbookUseCase(
                  name: 'AddEditCustomerScreen (Edit)',
                  builder: (_) => AddEditCustomerScreen(
                    customer: Customer(
                      id: 'edit_1',
                      fullName: 'Trần Thị B',
                      phoneNumber: '0987654321',
                      stage: CustomerStage.haveNeeds,
                      tags: const ['Zalo'],
                      notes: 'Đã hỏi về mẫu mới mùa hè.',
                      isDemo: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Auth',
          children: [
            WidgetbookComponent(
              name: 'CucaAuthMascot',
              useCases: [
                WidgetbookUseCase(
                  name: 'Playground',
                  builder: (context) {
                    final pose = context.knobs.object.dropdown<CucaAuthPose>(
                      label: 'Pose',
                      options: CucaAuthPose.values,
                      labelBuilder: (p) => p.name,
                    );
                    final height = context.knobs.double.slider(
                      label: 'Height',
                      initialValue: 140,
                      min: 80,
                      max: 240,
                    );

                    return Center(
                      child: CucaAuthMascot(
                        pose: pose,
                        height: height,
                      ),
                    );
                  },
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'Screens',
              useCases: [
                WidgetbookUseCase.child(
                  name: 'WelcomeScreen',
                  child: const WelcomeScreen(),
                ),
                WidgetbookUseCase.child(
                  name: 'LoginPhoneScreen',
                  child: const LoginPhoneScreen(),
                ),
                WidgetbookUseCase.child(
                  name: 'LoginEmailScreen',
                  child: const LoginEmailScreen(),
                ),
                WidgetbookUseCase(
                  name: 'OtpVerificationScreen',
                  builder: (context) {
                    final phone = context.knobs.string(
                      label: 'Phone number',
                      initialValue: '0912345678',
                    );
                    final isLogin = context.knobs.boolean(
                      label: 'isLogin',
                      initialValue: true,
                    );

                    return OtpVerificationScreen(
                      phoneNumber: phone,
                      isLogin: isLogin,
                    );
                  },
                ),
                WidgetbookUseCase.child(
                  name: 'SignupPhoneScreen',
                  child: const SignupPhoneScreen(),
                ),
                WidgetbookUseCase.child(
                  name: 'SignupEmailScreen',
                  child: const SignupEmailScreen(),
                ),
                WidgetbookUseCase(
                  name: 'CreatePasswordScreen',
                  builder: (context) {
                    final phone = context.knobs.string(
                      label: 'Phone',
                      initialValue: '0912345678',
                    );
                    return CreatePasswordScreen(phone: phone);
                  },
                ),
                WidgetbookUseCase.child(
                  name: 'ForgotPasswordScreen',
                  child: const ForgotPasswordScreen(),
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Onboarding',
          children: [
            WidgetbookComponent(
              name: 'Screens',
              useCases: [
                WidgetbookUseCase.child(
                  name: 'OnboardingWelcomeScreen',
                  child: const OnboardingWelcomeScreen(),
                ),
                WidgetbookUseCase.child(
                  name: 'ImportContactsScreen',
                  child: const ImportContactsScreen(),
                ),
                WidgetbookUseCase.child(
                  name: 'NotificationPermissionScreen',
                  child: const NotificationPermissionScreen(),
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'App',
          children: [
            WidgetbookComponent(
              name: 'Screens',
              useCases: [
                WidgetbookUseCase.child(
                  name: 'AppShellScreen',
                  child: const AppShellScreen(),
                ),
                WidgetbookUseCase.child(
                  name: 'HomeScreen',
                  child: const HomeScreen(),
                ),
                WidgetbookUseCase.child(
                  name: 'CucaChatScreen',
                  child: const CucaChatScreen(),
                ),
                WidgetbookUseCase.child(
                  name: 'CalendarScreen',
                  child: const CalendarScreen(),
                ),
                WidgetbookUseCase.child(
                  name: 'SettingsScreen',
                  child: const SettingsScreen(),
                ),
                WidgetbookUseCase(
                  name: 'AiInsightScreen',
                  builder: (context) {
                    final count = context.knobs.int.slider(
                      label: 'Customers',
                      initialValue: 2,
                      min: 0,
                      max: 5,
                    );
                    final customers = List<Customer>.generate(
                      count,
                      (i) => Customer(
                        id: '${i + 1}',
                        fullName: 'Customer ${i + 1}',
                        phoneNumber: '09${i}2345678',
                      ),
                    );
                    return AiInsightScreen(customers: customers);
                  },
                ),
                WidgetbookUseCase.child(
                  name: 'EditProfileScreen',
                  child: const EditProfileScreen(),
                ),
                WidgetbookUseCase.child(
                  name: 'ChangePasswordScreen',
                  child: const ChangePasswordScreen(),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'Home Widgets',
              useCases: [
                WidgetbookUseCase(
                  name: 'ReminderItem',
                  builder: (context) {
                    final name = context.knobs.string(
                      label: 'Customer Name',
                      initialValue: 'Nguyễn Văn A',
                    );
                    final stage = context.knobs.object.dropdown<ReminderStage>(
                      label: 'Stage',
                      options: ReminderStage.values,
                      labelBuilder: (s) => s.name,
                    );
                    final reason = context.knobs.string(
                      label: 'Reason',
                      initialValue: 'Hẹn gọi lại tư vấn giá',
                    );
                    final reminder = HomeReminder(
                      id: 'r1',
                      customerId: '1',
                      customerName: name,
                      stage: stage,
                      reason: reason,
                      dueAt: DateTime.now(),
                    );
                    return Center(
                      child: SizedBox(
                        width: 380,
                        child: ReminderItem(
                          reminder: reminder,
                          timeLabel: '09:00',
                          onTap: () {},
                          onCall: () {},
                          onMessage: () {},
                          onNote: () {},
                          onMore: () {},
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppTheme.lightTheme),
            WidgetbookTheme(name: 'Dark', data: AppTheme.darkTheme),
          ],
        ),
        ViewportAddon(Viewports.all),
        AlignmentAddon(),
        GridAddon(),
      ],
      appBuilder: (context, child) {
        return ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                home: child,
              );
            },
          ),
        );
      },
    );
  }
}
