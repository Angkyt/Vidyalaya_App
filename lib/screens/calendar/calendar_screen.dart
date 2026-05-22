import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/assignment.dart';
import '../../models/course.dart';
import '../../providers/study_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../assignment/assignment_details_screen.dart';
import '../course/course_details_screen.dart';
import '../dashboard/notifications_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StudyDataProvider>();
    final assignmentsForSelected = data.assignmentsOn(_selected);
    final classesForSelected = data.classesOn(_selected);
    final startingForSelected = data.coursesStartingOn(_selected);
    final endingForSelected = data.coursesEndingOn(_selected);

    // Sort: classes by start time, then assignments by due time
    classesForSelected.sort((a, b) {
      final aT = a.startHour * 60 + a.startMinute;
      final bT = b.startHour * 60 + b.startMinute;
      return aT.compareTo(bT);
    });
    assignmentsForSelected
        .sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              showBell: true,
              onBellTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationsScreen()),
              ),
            ),
            const SizedBox(height: 16),
            Text('Calendar',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(8),
              child: TableCalendar<_CalEvent>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
                focusedDay: _focused,
                selectedDayPredicate: (d) => _sameDay(d, _selected),
                calendarFormat: _format,
                onFormatChanged: (f) => setState(() => _format = f),
                onDaySelected: (sel, foc) {
                  setState(() {
                    _selected = sel;
                    _focused = foc;
                  });
                },
                eventLoader: (day) {
                  final events = <_CalEvent>[];
                  for (final a in data.assignmentsOn(day)) {
                    events.add(_CalEvent.assignment(a));
                  }
                  for (final c in data.classesOn(day)) {
                    events.add(_CalEvent.classMeeting(c));
                  }
                  for (final c in data.coursesStartingOn(day)) {
                    events.add(_CalEvent.courseStart(c));
                  }
                  for (final c in data.coursesEndingOn(day)) {
                    events.add(_CalEvent.courseEnd(c));
                  }
                  return events;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  // markersAutoAligned is overridden by our custom markerBuilder
                  markersMaxCount: 4,
                  markerSize: 5,
                  defaultTextStyle: TextStyle(color: context.textPrimary),
                  weekendTextStyle: TextStyle(color: context.textPrimary),
                  outsideTextStyle: TextStyle(color: context.textHint),
                ),
                calendarBuilders: CalendarBuilders<_CalEvent>(
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return null;
                    // Collect unique course colors for events on this day.
                    final colors = <Color>[];
                    for (final ev in events) {
                      Color? c;
                      if (ev.course != null) {
                        c = CourseColors.of(ev.course!.colorIndex);
                      } else if (ev.assignment != null) {
                        final course =
                            data.courseById(ev.assignment!.courseId);
                        if (course != null) {
                          c = CourseColors.of(course.colorIndex);
                        }
                      }
                      c ??= AppColors.dotBlue;
                      if (!colors.contains(c)) colors.add(c);
                      if (colors.length >= 4) break;
                    }
                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < colors.length; i++) ...[
                            if (i > 0) const SizedBox(width: 2),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: colors[i],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  titleTextStyle: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                  formatButtonDecoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  formatButtonTextStyle:
                      const TextStyle(color: AppColors.teal, fontSize: 12),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: context.textPrimary),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: context.textPrimary),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11),
                  weekendStyle: TextStyle(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(DateFormat('EEEE, d MMM').format(_selected),
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                      '${classesForSelected.length + assignmentsForSelected.length + startingForSelected.length + endingForSelected.length}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: (classesForSelected.isEmpty &&
                      assignmentsForSelected.isEmpty &&
                      startingForSelected.isEmpty &&
                      endingForSelected.isEmpty)
                  ? _empty(context)
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        if (startingForSelected.isNotEmpty) ...[
                          Text('Course starts',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4)),
                          const SizedBox(height: 8),
                          ...startingForSelected.map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _CourseMilestoneTile(
                                    course: c, isStart: true),
                              )),
                          const SizedBox(height: 14),
                        ],
                        if (classesForSelected.isNotEmpty) ...[
                          Text('Classes',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4)),
                          const SizedBox(height: 8),
                          ...classesForSelected.map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ClassTile(course: c),
                              )),
                          const SizedBox(height: 14),
                        ],
                        if (assignmentsForSelected.isNotEmpty) ...[
                          Text('Assignments due',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4)),
                          const SizedBox(height: 8),
                          ...assignmentsForSelected.map((a) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _AssignmentTile(assignment: a),
                              )),
                          const SizedBox(height: 14),
                        ],
                        if (endingForSelected.isNotEmpty) ...[
                          Text('Course ends',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4)),
                          const SizedBox(height: 8),
                          ...endingForSelected.map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _CourseMilestoneTile(
                                    course: c, isStart: false),
                              )),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available,
              size: 48, color: context.textSecondary),
          const SizedBox(height: 12),
          const Text('Nothing scheduled',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('No classes or assignments on this day.',
              style:
                  TextStyle(color: context.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Unified event for the calendar's eventLoader.
enum _CalEventKind { assignment, classMeeting, courseStart, courseEnd }

class _CalEvent {
  final _CalEventKind kind;
  final Assignment? assignment;
  final Course? course;
  _CalEvent.assignment(this.assignment)
      : course = null,
        kind = _CalEventKind.assignment;
  _CalEvent.classMeeting(this.course)
      : assignment = null,
        kind = _CalEventKind.classMeeting;
  _CalEvent.courseStart(this.course)
      : assignment = null,
        kind = _CalEventKind.courseStart;
  _CalEvent.courseEnd(this.course)
      : assignment = null,
        kind = _CalEventKind.courseEnd;
}

class _ClassTile extends StatelessWidget {
  final Course course;
  const _ClassTile({required this.course});

  @override
  Widget build(BuildContext context) {
    final color = CourseColors.of(course.colorIndex);
    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CourseDetailsScreen(courseId: course.id)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(course.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                    ),
                    if (course.code.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.inputColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(course.code,
                            style: TextStyle(
                                fontSize: 10,
                                color: context.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 12, color: context.textSecondary),
                    const SizedBox(width: 4),
                    Text(course.scheduleLabel,
                        style: TextStyle(
                            fontSize: 12, color: context.textSecondary)),
                    if (course.room.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.room_outlined,
                          size: 12, color: context.textSecondary),
                      const SizedBox(width: 4),
                      Text(course.room,
                          style: TextStyle(
                              fontSize: 12, color: context.textSecondary)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
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

class _AssignmentTile extends StatelessWidget {
  final Assignment assignment;
  const _AssignmentTile({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StudyDataProvider>();
    final c = data.courseById(assignment.courseId);
    final color = assignment.status == AssignmentStatus.completed
        ? AppColors.completed
        : assignment.isOverdue
            ? AppColors.errorRed
            : assignment.isUrgent
                ? AppColors.mediumPriority
                : AppColors.dotBlue;

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                AssignmentDetailsScreen(assignmentId: assignment.id)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assignment.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration:
                          assignment.status == AssignmentStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                    )),
                const SizedBox(height: 2),
                Text(
                  '${c?.name ?? 'Course'} • ${DateFormat('h:mm a').format(assignment.dueDate)}',
                  style: TextStyle(
                      fontSize: 12, color: context.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
                assignment.isOverdue &&
                        assignment.status != AssignmentStatus.completed
                    ? 'OVERDUE'
                    : assignment.status.label,
                style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4)),
          ),
        ],
      ),
    );
  }
}

class _CourseMilestoneTile extends StatelessWidget {
  final Course course;
  final bool isStart;
  const _CourseMilestoneTile(
      {required this.course, required this.isStart});

  @override
  Widget build(BuildContext context) {
    final color = CourseColors.of(course.colorIndex);
    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CourseDetailsScreen(courseId: course.id)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
                isStart ? Icons.play_circle_outline : Icons.flag_outlined,
                color: color,
                size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(course.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                    ),
                    if (course.code.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.inputColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(course.code,
                            style: TextStyle(
                                fontSize: 10,
                                color: context.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(isStart ? 'Course begins today' : 'Course ends today',
                    style: TextStyle(
                        fontSize: 12, color: context.textSecondary)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(isStart ? 'START' : 'END',
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }
}
