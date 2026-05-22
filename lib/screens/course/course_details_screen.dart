import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/assignment.dart';
import '../../providers/study_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../assignment/add_edit_assignment_screen.dart';
import '../assignment/assignment_details_screen.dart';
import 'add_edit_course_screen.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String courseId;
  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StudyDataProvider>();
    final course = data.courseById(courseId);
    if (course == null) {
      return const Scaffold(body: Center(child: Text('Course not found')));
    }
    final assignments = data.assignmentsForCourse(course.id);
    final progress = data.progressForCourse(course.id);
    final color = CourseColors.of(course.colorIndex);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(showBack: true),
              const SizedBox(height: 16),
              PageTitle(course.name),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(course.name,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700)),
                              if (course.code.isNotEmpty)
                                Text(course.code,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: context.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AddEditCourseScreen(course: course)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _detailRow(context, Icons.person_outline, course.lecturer),
                    if (course.hasSchedule)
                      _detailRow(context, Icons.schedule, course.scheduleLabel),
                    if (course.room.isNotEmpty)
                      _detailRow(context, Icons.room_outlined, course.room),
                    if (course.semester.isNotEmpty)
                      _detailRow(context, Icons.calendar_today_outlined,
                          course.semester),
                    if (course.hasDateRange)
                      _detailRow(
                          context,
                          Icons.event_outlined,
                          '${_fmtDate(course.courseStartDate!)} – ${_fmtDate(course.courseEndDate!)}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              minHeight: 6,
                              backgroundColor: context.inputColor,
                              valueColor: AlwaysStoppedAnimation(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('$progress% complete',
                            style: TextStyle(
                                fontSize: 12, color: context.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text('Assignments (${assignments.length})',
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.teal),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddEditAssignmentScreen(
                              presetCourseId: course.id)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: assignments.isEmpty
                    ? _empty(context, course.id)
                    : ListView.separated(
                        itemCount: assignments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _AssignmentTile(assignment: assignments[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context, String cId) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined,
              size: 48, color: context.textSecondary),
          const SizedBox(height: 12),
          const Text('No assignments yet',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Add an assignment to get started.',
              style: TextStyle(color: context.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Assignment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AddEditAssignmentScreen(presetCourseId: cId)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.textSecondary),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(fontSize: 12, color: context.textSecondary)),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _AssignmentTile extends StatelessWidget {
  final Assignment assignment;
  const _AssignmentTile({required this.assignment});

  @override
  Widget build(BuildContext context) {
    // Bar color reflects priority (Low=green, Medium=orange, High=red).
    final priorityColor = switch (assignment.priority) {
      Priority.high => AppColors.highPriority,
      Priority.medium => AppColors.mediumPriority,
      Priority.low => AppColors.lowPriority,
    };
    // Status pill on the right keeps the status color so overdue /
    // completed states are still visually obvious.
    final statusColor = assignment.status == AssignmentStatus.completed
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
          Container(width: 4, height: 44, color: priorityColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assignment.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: assignment.status == AssignmentStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                    )),
                const SizedBox(height: 2),
                Text(
                  'Due ${DateFormat('d MMM, h:mm a').format(assignment.dueDate)}',
                  style: TextStyle(
                      fontSize: 12, color: context.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(assignment.status.label,
                style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
