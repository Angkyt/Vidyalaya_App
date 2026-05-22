import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/assignment.dart';
import '../../providers/study_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../dashboard/notifications_screen.dart';
import 'add_edit_course_screen.dart';
import 'course_details_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _search = TextEditingController();
  int _filter = 0;
  final _filters = const ['All', 'Active', 'Completed'];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Course> _apply(List<Course> all, StudyDataProvider data) {
    Iterable<Course> list = all;
    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q) ||
          c.lecturer.toLowerCase().contains(q));
    }
    if (_filter == 1) {
      list = list.where((c) => data.dueTaskCount(c.id) > 0);
    } else if (_filter == 2) {
      list = list.where((c) =>
          data.assignmentsForCourse(c.id).isNotEmpty &&
          data
              .assignmentsForCourse(c.id)
              .every((a) => a.status == AssignmentStatus.completed));
    }
    return list.toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StudyDataProvider>();
    final urgentCount = data.urgentOrOverdue.length;
    final list = _apply(data.courses, data);

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
            // Show badge over the bell separately for visual consistency:
            // we already include count inside the dashboard. For Course/Calendar
            // a simple bell is fine; users can tap to see the list.
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text('All Courses',
                      style: Theme.of(context).textTheme.headlineMedium),
                ),
                if (urgentCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$urgentCount urgent',
                        style: const TextStyle(
                            color: AppColors.errorRed,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                ],
                Material(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddEditCourseScreen()),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text('Add Course',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _search,
              hint: 'Search by name, code, or lecturer',
              prefixIcon: Icons.search,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _filters.length,
                itemBuilder: (_, i) => PillChip(
                  label: _filters[i],
                  selected: i == _filter,
                  onTap: () => setState(() => _filter = i),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: list.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      itemCount: list.length,
                      padding: const EdgeInsets.only(bottom: 16),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _CourseTile(course: list[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.menu_book_rounded,
                size: 36, color: AppColors.teal),
          ),
          const SizedBox(height: 16),
          const Text('No courses found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _search.text.isEmpty
                  ? 'Tap the + button to add your first course.'
                  : 'Try a different search or filter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          if (_search.text.isEmpty)
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddEditCourseScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Course'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
        ],
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  final Course course;
  const _CourseTile({required this.course});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StudyDataProvider>();
    final progress = data.progressForCourse(course.id);
    final due = data.dueTaskCount(course.id);
    final color = CourseColors.of(course.colorIndex);

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CourseDetailsScreen(courseId: course.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  course.name.isNotEmpty
                      ? course.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
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
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                        ),
                        if (course.code.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.inputColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              course.code,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.textSecondary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lecturer: ${course.lecturer.isEmpty ? '—' : course.lecturer}',
                      style: TextStyle(
                          fontSize: 12, color: context.textSecondary),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: context.textSecondary, size: 20),
                onSelected: (v) async {
                  if (v == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AddEditCourseScreen(course: course)),
                    );
                  } else if (v == 'delete') {
                    final confirmed = await _confirmDelete(context);
                    if (confirmed == true && context.mounted) {
                      await context
                          .read<StudyDataProvider>()
                          .deleteCourse(course.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Deleted "${course.name}"'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit')
                      ])),
                  PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: AppColors.errorRed),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(color: AppColors.errorRed))
                      ])),
                ],
              ),
            ],
          ),
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
              Text('$progress%',
                  style:
                      TextStyle(fontSize: 12, color: context.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                due == 0
                    ? 'No pending tasks'
                    : '$due pending ${due == 1 ? 'task' : 'tasks'}',
                style:
                    TextStyle(fontSize: 12, color: context.textSecondary),
              ),
              if (course.hasSchedule) ...[
                const Spacer(),
                Icon(Icons.schedule,
                    size: 12, color: context.textSecondary),
                const SizedBox(width: 4),
                Text(course.scheduleLabel,
                    style: TextStyle(
                        fontSize: 11, color: context.textSecondary)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete course?'),
        content: Text(
            'This will also delete all assignments under "${course.name}". This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.errorRed))),
        ],
      ),
    );
  }
}
