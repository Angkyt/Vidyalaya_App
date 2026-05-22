import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/study_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final data = context.watch<StudyDataProvider>();
    final filter = settings.typeFilter;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(showBack: true),
              const SizedBox(height: 18),
              const PageTitle('Notification Preferences'),
              const SizedBox(height: 4),
              Text(
                'Choose how and when Vidyalaya reminds you.',
                style:
                    TextStyle(color: context.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 18),

              // Master switch
              AppCard(
                padding: EdgeInsets.zero,
                child: _SwitchTile(
                  icon: Icons.notifications_active_outlined,
                  label: 'Enable notifications',
                  subtitle: 'Master switch for all reminders',
                  value: settings.notifsEnabled,
                  onChanged: settings.setNotifsEnabled,
                ),
              ),
              const SizedBox(height: 18),

              // Type filters
              Text('Notification types',
                  style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
              const SizedBox(height: 8),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SwitchTile(
                      icon: Icons.assignment_outlined,
                      label: 'Assessments',
                      subtitle:
                          'Reminders for assignments, quizzes, exams, and graded work',
                      enabled: settings.notifsEnabled,
                      value: filter.assignments,
                      onChanged: (v) {
                        filter.assignments = v;
                        // Keep `assessments` in sync so legacy flags
                        // produce consistent behaviour everywhere.
                        filter.assessments = v;
                        settings.setTypeFilter(filter);
                      },
                    ),
                    _SwitchTile(
                      icon: Icons.campaign_outlined,
                      label: 'Announcements',
                      subtitle:
                          'Class updates, lecturer messages, and upcoming class reminders',
                      enabled: settings.notifsEnabled,
                      value: filter.announcements,
                      onChanged: (v) {
                        filter.announcements = v;
                        settings.setTypeFilter(filter);
                      },
                    ),
                    _SwitchTile(
                      icon: Icons.water_drop_outlined,
                      label: 'Hydration reminder',
                      subtitle: 'Remind me to drink water during long sessions',
                      enabled: settings.notifsEnabled,
                      value: settings.waterReminder,
                      onChanged: settings.setWaterReminder,
                    ),
                    _SwitchTile(
                      icon: Icons.self_improvement,
                      label: 'Stretch reminder',
                      subtitle: 'Stretch every break to ease tension',
                      enabled: settings.notifsEnabled,
                      value: settings.stretchReminder,
                      onChanged: settings.setStretchReminder,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Per-course mute
              Text('Per-subject notifications',
                  style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
              const SizedBox(height: 8),
              if (data.courses.isEmpty)
                AppCard(
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: context.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Add a course to control notifications per subject.',
                          style: TextStyle(
                              fontSize: 13, color: context.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )
              else
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: data.courses.map((c) {
                      final color = CourseColors.of(c.colorIndex);
                      final muted = settings.isCourseMuted(c.id);
                      return _SwitchTile(
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                        label: c.name,
                        subtitle: c.code.isNotEmpty ? c.code : c.lecturer,
                        enabled: settings.notifsEnabled,
                        value: !muted,
                        onChanged: (v) =>
                            settings.setCourseMuted(c.id, !v),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String label;
  final String? subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    this.icon,
    this.leading,
    required this.label,
    this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ] else if (icon != null) ...[
            Icon(icon,
                size: 20,
                color: enabled
                    ? context.textSecondary
                    : context.textHint),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: enabled
                          ? context.textPrimary
                          : context.textHint,
                    )),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: enabled
                            ? context.textSecondary
                            : context.textHint,
                      )),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.teal,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
