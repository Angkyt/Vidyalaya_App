import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/assignment.dart';
import '../../providers/study_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'add_edit_assignment_screen.dart';

class AssignmentDetailsScreen extends StatefulWidget {
  final String assignmentId;
  const AssignmentDetailsScreen({super.key, required this.assignmentId});

  @override
  State<AssignmentDetailsScreen> createState() =>
      _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState extends State<AssignmentDetailsScreen> {
  // Local copies so the user can adjust then explicitly Save.
  int? _progress;
  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StudyDataProvider>();
    final a = data.assignments
        .where((x) => x.id == widget.assignmentId)
        .cast<Assignment?>()
        .firstWhere((x) => true, orElse: () => null);
    if (a == null) {
      return const Scaffold(body: Center(child: Text('Assignment not found')));
    }
    final c = data.courseById(a.courseId);
    _progress ??= a.progress;
    final priorityColor = switch (a.priority) {
      Priority.high => AppColors.highPriority,
      Priority.medium => AppColors.mediumPriority,
      Priority.low => AppColors.lowPriority,
    };
    final statusColor = a.status == AssignmentStatus.completed
        ? AppColors.completed
        : a.isOverdue
            ? AppColors.errorRed
            : a.isUrgent
                ? AppColors.mediumPriority
                : AppColors.dotBlue;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(showBack: true),
              const SizedBox(height: 18),
              const PageTitle('Assignment'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  a.isOverdue && a.status != AssignmentStatus.completed
                                      ? 'OVERDUE'
                                      : a.status.label,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: priorityColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('${a.priority.label} priority',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: priorityColor,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(a.title,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(c?.name ?? 'Unknown course',
                              style: TextStyle(
                                  fontSize: 13, color: context.textSecondary)),
                          const SizedBox(height: 16),
                          _row(context, Icons.event,
                              DateFormat('EEE, d MMM yyyy • h:mm a').format(a.dueDate)),
                          _row(context, Icons.notifications_outlined, a.reminder),
                          if (a.notes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.inputColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Notes',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: context.textSecondary,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(a.notes,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: context.textPrimary)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.trending_up,
                                  size: 18, color: AppColors.teal),
                              const SizedBox(width: 8),
                              const Text('Progress',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Text('$_progress%',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.teal)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.teal,
                              thumbColor: AppColors.teal,
                              overlayColor: AppColors.teal.withOpacity(0.15),
                              inactiveTrackColor: context.inputColor,
                            ),
                            child: Slider(
                              value: (_progress ?? 0).toDouble(),
                              min: 0,
                              max: 100,
                              divisions: 20,
                              label: '$_progress%',
                              onChanged: (v) => setState(() {
                                _progress = v.round();
                                _dirty = _progress != a.progress;
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              if (a.status != AssignmentStatus.completed)
                TealButton(
                  label: 'Mark Complete',
                  icon: Icons.check_circle_outline,
                  onPressed: () async {
                    await context
                        .read<StudyDataProvider>()
                        .markComplete(a.id);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Marked as complete'),
                        backgroundColor: AppColors.successGreen,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              if (a.status != AssignmentStatus.completed)
                const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                AddEditAssignmentScreen(assignment: a)),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.teal,
                        side: const BorderSide(color: AppColors.teal),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await _confirmDelete(context);
                        if (ok != true || !mounted) return;
                        await context
                            .read<StudyDataProvider>()
                            .deleteAssignment(a.id);
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: _dirty ? 'Save Changes' : 'Saved',
                icon: _dirty ? Icons.save_outlined : Icons.check,
                onPressed: _dirty
                    ? () async {
                        await context
                            .read<StudyDataProvider>()
                            .setProgress(a.id, _progress ?? a.progress);
                        if (!mounted) return;
                        setState(() => _dirty = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Changes saved'),
                            backgroundColor: AppColors.successGreen,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13, color: context.textPrimary)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete assignment?'),
        content: const Text('This cannot be undone.'),
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
