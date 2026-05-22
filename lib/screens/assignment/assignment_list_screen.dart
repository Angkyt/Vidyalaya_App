import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/assignment.dart';
import '../../providers/study_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'add_edit_assignment_screen.dart';
import 'assignment_details_screen.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  int _filter = 0; // 0 All, 1 Pending, 2 In Progress, 3 Completed
  final _filters = const ['All', 'Pending', 'In Progress', 'Completed'];

  List<Assignment> _apply(List<Assignment> all) {
    Iterable<Assignment> list = all;
    if (_filter == 1) {
      list = list.where((a) => a.status == AssignmentStatus.pending);
    } else if (_filter == 2) {
      list = list.where((a) => a.status == AssignmentStatus.inProgress);
    } else if (_filter == 3) {
      list = list.where((a) => a.status == AssignmentStatus.completed);
    }
    final result = list.toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StudyDataProvider>();
    final list = _apply(data.assignments);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(showBack: true),
              const SizedBox(height: 18),
              const PageTitle('Assignments'),
              const SizedBox(height: 16),
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
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_outlined,
                                size: 48, color: context.textSecondary),
                            const SizedBox(height: 12),
                            Text('No assignments',
                                style:
                                    TextStyle(color: context.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final a = list[i];
                          final c = data.courseById(a.courseId);
                          return _Tile(assignment: a, courseName: c?.name);
                        },
                      ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Add Assignment',
                icon: Icons.add,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddEditAssignmentScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final Assignment assignment;
  final String? courseName;
  const _Tile({required this.assignment, this.courseName});

  @override
  Widget build(BuildContext context) {
    // Bar color reflects priority (Low=green, Medium=orange, High=red).
    final priorityColor = switch (assignment.priority) {
      Priority.high => AppColors.highPriority,
      Priority.medium => AppColors.mediumPriority,
      Priority.low => AppColors.lowPriority,
    };
    // Pill on the right keeps showing priority label using the same color.

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AssignmentDetailsScreen(assignmentId: assignment.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 36, color: priorityColor),
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
                      '${courseName ?? 'Course'} • ${DateFormat('d MMM').format(assignment.dueDate)}',
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
                  color: priorityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(assignment.priority.label,
                    style: TextStyle(
                        fontSize: 10,
                        color: priorityColor,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: assignment.progress / 100,
                    minHeight: 6,
                    backgroundColor: context.inputColor,
                    valueColor: AlwaysStoppedAnimation(priorityColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${assignment.progress}%',
                  style: TextStyle(
                      fontSize: 12, color: context.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
