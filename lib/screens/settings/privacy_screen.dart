import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(showBack: true),
              const SizedBox(height: 18),
              const PageTitle('Privacy'),
              const SizedBox(height: 6),
              Text(
                'How Vidyalaya handles your data.',
                style:
                    TextStyle(color: context.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 18),

              // Summary
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shield_outlined,
                          color: AppColors.teal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your data stays on this device',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            'Vidyalaya is an offline app. Nothing you enter is sent to a server.',
                            style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // What we store
              Text('What is stored locally',
                  style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
              const SizedBox(height: 8),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: const [
                    _PrivacyRow(
                      icon: Icons.person_outline,
                      label: 'Account details',
                      detail:
                          'Name, email, phone, and student ID you signed up with.',
                    ),
                    _PrivacyRow(
                      icon: Icons.lock_outline,
                      label: 'Password',
                      detail:
                          'Stored as a salted SHA-256 hash. Your plain password is never saved.',
                    ),
                    _PrivacyRow(
                      icon: Icons.menu_book_outlined,
                      label: 'Courses and assessments',
                      detail:
                          'Every course, schedule, and assignment you add.',
                    ),
                    _PrivacyRow(
                      icon: Icons.image_outlined,
                      label: 'Profile photo',
                      detail:
                          'If you upload one, it is saved in this app\'s sandbox folder.',
                    ),
                    _PrivacyRow(
                      icon: Icons.tune,
                      label: 'Preferences',
                      detail:
                          'Theme, notification choices, muted subjects, and wellbeing reminders.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // What we don't do
              Text('What Vidyalaya does NOT do',
                  style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
              const SizedBox(height: 8),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: const [
                    _PrivacyRow(
                      icon: Icons.cloud_off_outlined,
                      label: 'No cloud sync',
                      detail:
                          'Data is not uploaded anywhere. Reinstalling the app or switching devices means starting fresh.',
                    ),
                    _PrivacyRow(
                      icon: Icons.bar_chart_outlined,
                      label: 'No tracking or analytics',
                      detail:
                          'There are no third-party SDKs collecting usage data, crash reports, or identifiers.',
                    ),
                    _PrivacyRow(
                      icon: Icons.ads_click_outlined,
                      label: 'No ads',
                      detail:
                          'No advertising, no behavioural profiling, no data sold to anyone.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Vidyalaya is provided as an offline study planner. Because data lives only on this device, please back up anything important separately.',
                style: TextStyle(
                    fontSize: 11,
                    color: context.textSecondary,
                    height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final Widget? trailing;
  const _PrivacyRow({
    required this.icon,
    required this.label,
    required this.detail,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(detail,
                    style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondary,
                        height: 1.4)),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
