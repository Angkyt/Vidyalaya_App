import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/assignment.dart';
import '../../models/course.dart';
import '../../providers/settings_provider.dart';
import '../../providers/study_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../assignment/assignment_details_screen.dart';
import '../course/course_details_screen.dart';
import '../settings/notification_preferences_screen.dart';

/// One notification per row. Two kinds:
/// - assignment-due (tap → assignment details)
/// - tomorrow's class (tap → course details)
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  List<_NotifItem> _buildItems(
      StudyDataProvider data, SettingsProvider settings) {
    if (!settings.notifsEnabled) return const [];
    final filter = settings.typeFilter;
    final items = <_NotifItem>[];

    // Assignment due reminders
    if (filter.assignments) {
      for (final a in data.upcoming) {
        if (settings.isCourseMuted(a.courseId)) continue;
        final c = data.courseById(a.courseId);
        if (c == null) continue;
        items.add(_NotifItem.assignment(course: c, assignment: a));
      }
    }

    // Class schedule reminders — bundled under Announcements
    if (filter.announcements) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      // Today's classes that haven't started yet
      for (final c in data.classesOn(today)) {
        if (settings.isCourseMuted(c.id)) continue;
        final start =
            DateTime(today.year, today.month, today.day, c.startHour, c.startMinute);
        if (start.isAfter(now)) {
          items.add(_NotifItem.classToday(course: c, when: start));
        }
      }

      // Tomorrow's classes
      for (final c in data.classesOn(tomorrow)) {
        if (settings.isCourseMuted(c.id)) continue;
        final start = DateTime(tomorrow.year, tomorrow.month, tomorrow.day,
            c.startHour, c.startMinute);
        items.add(_NotifItem.classTomorrow(course: c, when: start));
      }
    }

    items.sort((a, b) => a.when.compareTo(b.when));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StudyDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final items = _buildItems(data, settings);
    final notifsOn = settings.notifsEnabled;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(showBack: true),
              const SizedBox(height: 18),
              PageTitle(
                'Notifications',
                trailing: IconButton(
                  icon: const Icon(Icons.tune, size: 20),
                  tooltip: 'Notification preferences',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const NotificationPreferencesScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!notifsOn) ...[
                AppCard(
                  child: Row(
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          color: context.textSecondary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Notifications are turned off. Turn them on in Notification Preferences to see reminders here.',
                          style: TextStyle(
                              fontSize: 13, color: context.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Expanded(
                child: items.isEmpty
                    ? _empty(context)
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) => _NotifTile(item: items[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 48, color: context.textSecondary),
          const SizedBox(height: 12),
          Text('No notifications',
              style: TextStyle(color: context.textSecondary)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Class reminders and assignment alerts will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: context.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

enum _NotifKind { assignment, classToday, classTomorrow }

class _NotifItem {
  final _NotifKind kind;
  final Course course;
  final Assignment? assignment;
  final DateTime when;
  _NotifItem.assignment({required this.course, required this.assignment})
      : kind = _NotifKind.assignment,
        when = assignment!.dueDate;
  _NotifItem.classToday({required this.course, required this.when})
      : kind = _NotifKind.classToday,
        assignment = null;
  _NotifItem.classTomorrow({required this.course, required this.when})
      : kind = _NotifKind.classTomorrow,
        assignment = null;
}

class _NotifTile extends StatelessWidget {
  final _NotifItem item;
  const _NotifTile({required this.item});

  /// Tap behavior:
  /// - For an assignment: replace Notifications with the Course page,
  ///   then push the Assignment on top. Back from Assignment → Course;
  ///   Back from Course → wherever the bell was tapped.
  /// - For a class: replace Notifications with the Course page.
  void _onTap(BuildContext context) {
    final nav = Navigator.of(context);
    nav.pushReplacement(MaterialPageRoute(
      builder: (_) => CourseDetailsScreen(courseId: item.course.id),
    ));
    if (item.kind == _NotifKind.assignment) {
      nav.push(MaterialPageRoute(
        builder: (_) =>
            AssignmentDetailsScreen(assignmentId: item.assignment!.id),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAssignment = item.kind == _NotifKind.assignment;
    final courseColor = CourseColors.of(item.course.colorIndex);

    String title;
    String subtitle;
    IconData icon;
    Color accent;

    if (isAssignment) {
      final a = item.assignment!;
      final hours = a.dueDate.difference(DateTime.now()).inHours;
      final String when;
      if (a.isOverdue) {
        when = 'Overdue';
      } else if (hours < 24) {
        when = 'Due in $hours h';
      } else {
        when = 'Due ${DateFormat('d MMM').format(a.dueDate)}';
      }
      title = '${item.course.name} – ${a.title} Due';
      subtitle = when;
      icon = Icons.event_note;
      accent = a.isOverdue
          ? AppColors.errorRed
          : a.isUrgent
              ? AppColors.mediumPriority
              : AppColors.teal;
    } else if (item.kind == _NotifKind.classToday) {
      final minsAway = item.when.difference(DateTime.now()).inMinutes;
      final timeStr = DateFormat('h:mm a').format(item.when);
      title = 'Today: ${item.course.name} class at $timeStr';
      if (minsAway < 60) {
        subtitle = 'Starts in $minsAway min';
      } else {
        final hoursAway = (minsAway / 60).floor();
        subtitle = 'Starts in $hoursAway h';
      }
      icon = Icons.event_available;
      accent = courseColor;
    } else {
      // classTomorrow
      final timeStr = DateFormat('h:mm a').format(item.when);
      title = 'Tomorrow: ${item.course.name} class at $timeStr';
      subtitle = DateFormat('EEEE, d MMM').format(item.when);
      icon = Icons.event_available;
      accent = courseColor;
    }

    return AppCard(
      onTap: () => _onTap(context),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: context.textSecondary)),
              ],
            ),
          ),
          if (!isAssignment)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: courseColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('CLASS',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
            ),
        ],
      ),
    );
  }
}
