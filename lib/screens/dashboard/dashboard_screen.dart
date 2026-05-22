import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/study_data_provider.dart';
import '../../models/assignment.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../assignment/assignment_details_screen.dart';
import '../assignment/assignment_list_screen.dart';
import '../course/course_details_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scrollController = ScrollController();
  final _coursesKey = GlobalKey();
  final _pendingKey = GlobalKey();
  final _urgentKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final data = context.watch<StudyDataProvider>();
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());
    final firstName = user?.firstName.isNotEmpty == true
        ? user!.firstName
        : (user?.fullName.isNotEmpty == true ? user!.fullName : 'there');

    final pending = data.pending;
    final urgent = data.urgentOrOverdue;

    return SafeArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting card
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(today,
                            style: TextStyle(
                                fontSize: 12, color: context.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Good day,',
                            style: TextStyle(
                                fontSize: 14, color: context.textSecondary)),
                        Text(firstName,
                            style:
                                Theme.of(context).textTheme.headlineMedium),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_outlined),
                        if (urgent.isNotEmpty)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.errorRed,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${urgent.length}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsScreen()),
                    ),
                  ),
                  ProfileAvatar(
                    initials: user?.initials ?? '?',
                    imagePath: user?.avatarPath,
                    size: 44,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Quick stats — tappable, scroll to anchors
            Row(
              children: [
                _StatCard(
                  icon: Icons.menu_book_rounded,
                  label: 'Courses',
                  value: '${data.courses.length}',
                  color: AppColors.teal,
                  onTap: () => _scrollTo(_coursesKey),
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.assignment_outlined,
                  label: 'Pending',
                  value: '${pending.length}',
                  color: AppColors.dotBlue,
                  onTap: () => _scrollTo(_pendingKey),
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Urgent',
                  value: '${urgent.length}',
                  color: AppColors.highPriority,
                  onTap: () => _scrollTo(_urgentKey),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Course progress section
            _SectionHeader(
              key: _coursesKey,
              title: 'Your courses',
            ),
            const SizedBox(height: 10),
            if (data.courses.isEmpty)
              const _EmptyHint(
                icon: Icons.menu_book_outlined,
                title: 'No courses yet',
                subtitle:
                    'Add your first course from the Courses tab to get started.',
              )
            else
              ...data.courses.map((c) {
                final progress = data.progressForCourse(c.id);
                final due = data.dueTaskCount(c.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              CourseDetailsScreen(courseId: c.id)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: CourseColors.of(c.colorIndex),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(c.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            ),
                            Text('$progress%',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: context.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                            '$due due ${due == 1 ? 'task' : 'tasks'} • ${c.lecturer}',
                            style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary)),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 6,
                            backgroundColor: context.inputColor,
                            valueColor: AlwaysStoppedAnimation(
                                CourseColors.of(c.colorIndex)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 8),

            // Pending section
            _SectionHeader(
              key: _pendingKey,
              title: 'Pending deadlines',
              actionLabel: pending.isEmpty ? null : 'View all',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AssignmentListScreen()),
              ),
            ),
            const SizedBox(height: 10),
            if (pending.isEmpty)
              const _EmptyHint(
                icon: Icons.celebration_outlined,
                title: 'All caught up!',
                subtitle:
                    'No pending assignments. Time for a wellbeing break.',
              )
            else
              ...pending.take(5).map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DeadlineTile(assignment: a),
                  )),

            const SizedBox(height: 18),

            // Urgent / overdue section
            _SectionHeader(
              key: _urgentKey,
              title: 'Urgent & overdue',
              actionLabel: urgent.isEmpty ? null : 'View all',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AssignmentListScreen()),
              ),
            ),
            const SizedBox(height: 10),
            if (urgent.isEmpty)
              const _EmptyHint(
                icon: Icons.check_circle_outline,
                title: 'Nothing urgent',
                subtitle:
                    'Tasks become urgent when they are overdue or due within 48 hours.',
              )
            else
              ...urgent.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DeadlineTile(assignment: a, urgentEmphasis: true),
                  )),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700)),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: context.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(title,
                style: Theme.of(context).textTheme.titleLarge)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!,
                style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
      ],
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  final Assignment assignment;
  final bool urgentEmphasis;
  const _DeadlineTile(
      {required this.assignment, this.urgentEmphasis = false});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StudyDataProvider>();
    final c = data.courseById(assignment.courseId);
    final priorityColor = switch (assignment.priority) {
      Priority.high => AppColors.highPriority,
      Priority.medium => AppColors.mediumPriority,
      Priority.low => AppColors.lowPriority,
    };
    // Vertical bar reflects the related course's color so each card is
    // easy to associate with its course at a glance. Falls back to teal
    // only if the course can't be found.
    final barColor =
        c == null ? AppColors.teal : CourseColors.of(c.colorIndex);

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AssignmentDetailsScreen(assignmentId: assignment.id),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2),
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
                      child: Text(assignment.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                    ),
                    if (assignment.isOverdue && urgentEmphasis)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('OVERDUE',
                            style: TextStyle(
                                fontSize: 9,
                                color: AppColors.errorRed,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${c?.name ?? 'Course'} • ${DateFormat('d MMM, h:mm a').format(assignment.dueDate)}',
                  style: TextStyle(
                      fontSize: 12, color: context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyHint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.teal),
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
        ],
      ),
    );
  }
}
