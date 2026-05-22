import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(showBack: true),
              const SizedBox(height: 18),
              const PageTitle('Help & Support'),
              const SizedBox(height: 16),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: [
                    _row(context, Icons.help_outline, 'FAQ',
                        'How to add assignments, courses and reminders'),
                    const SizedBox(height: 10),
                    _row(context, Icons.support_agent, 'Contact Support',
                        'Email or live help options'),
                    const SizedBox(height: 10),
                    _row(context, Icons.bug_report_outlined, 'Report an Issue',
                        'Send bug details and screenshots'),
                    const SizedBox(height: 10),
                    _row(context, Icons.menu_book_outlined, 'User Guide',
                        'Learn app navigation and features'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String title, String subtitle) {
    return AppCard(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title — coming soon'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.teal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: context.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.textSecondary, size: 20),
        ],
      ),
    );
  }
}
