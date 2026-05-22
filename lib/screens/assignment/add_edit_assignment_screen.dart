import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/assignment.dart';
import '../../providers/study_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AddEditAssignmentScreen extends StatefulWidget {
  final Assignment? assignment;
  final String? presetCourseId;
  const AddEditAssignmentScreen({
    super.key,
    this.assignment,
    this.presetCourseId,
  });

  @override
  State<AddEditAssignmentScreen> createState() =>
      _AddEditAssignmentScreenState();
}

class _AddEditAssignmentScreenState extends State<AddEditAssignmentScreen> {
  late final _title =
      TextEditingController(text: widget.assignment?.title ?? '');
  late final _notes =
      TextEditingController(text: widget.assignment?.notes ?? '');
  late String? _courseId =
      widget.assignment?.courseId ?? widget.presetCourseId;
  late DateTime _due = widget.assignment?.dueDate ??
      DateTime.now().add(const Duration(days: 3));
  late Priority _priority = widget.assignment?.priority ?? Priority.medium;
  late String _reminder = widget.assignment?.reminder ?? '1 day before';

  String? _titleError;
  String? _courseError;
  bool _saving = false;

  bool get _isEdit => widget.assignment != null;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_due),
    );
    if (!mounted) return;
    setState(() {
      _due = DateTime(date.year, date.month, date.day,
          time?.hour ?? 23, time?.minute ?? 59);
    });
  }

  Future<void> _save() async {
    setState(() {
      _titleError = _title.text.trim().isEmpty ? 'Title is required' : null;
      _courseError = _courseId == null ? 'Select a course' : null;
    });
    if (_titleError != null || _courseError != null) return;

    setState(() => _saving = true);
    final data = context.read<StudyDataProvider>();
    if (_isEdit) {
      final a = widget.assignment!;
      a.title = _title.text.trim();
      a.notes = _notes.text.trim();
      a.dueDate = _due;
      a.priority = _priority;
      a.reminder = _reminder;
      await data.updateAssignment(a);
    } else {
      await data.addAssignment(
        courseId: _courseId!,
        title: _title.text.trim(),
        notes: _notes.text.trim(),
        dueDate: _due,
        priority: _priority,
        reminder: _reminder,
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Assignment updated' : 'Assignment added'),
        backgroundColor: AppColors.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StudyDataProvider>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(showBack: true),
              const SizedBox(height: 18),
              PageTitle(_isEdit ? 'Edit Assignment' : 'New Assignment'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    AppTextField(
                      label: 'Title *',
                      controller: _title,
                      errorText: _titleError,
                      prefixIcon: Icons.assignment_outlined,
                    ),
                    const SizedBox(height: 14),
                    Text('Course *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: context.inputColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _courseError != null
                              ? AppColors.errorRed
                              : Colors.transparent,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _courseId,
                          hint: Text('Select course',
                              style: TextStyle(color: context.textHint)),
                          dropdownColor: context.cardColor,
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: context.textSecondary),
                          items: data.courses
                              .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name,
                                      style: TextStyle(
                                          color: context.textPrimary))))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _courseId = v;
                              _courseError = null;
                            });
                          },
                        ),
                      ),
                    ),
                    if (_courseError != null) ...[
                      const SizedBox(height: 6),
                      Text(_courseError!,
                          style: const TextStyle(
                              color: AppColors.errorRed, fontSize: 12)),
                    ],
                    const SizedBox(height: 14),
                    Text('Due Date *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: context.inputColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event,
                                size: 18, color: context.textHint),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('EEE, d MMM yyyy • h:mm a')
                                  .format(_due),
                              style: TextStyle(color: context.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Priority',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _priorityChip(
                            Priority.high, AppColors.highPriority),
                        const SizedBox(width: 10),
                        _priorityChip(
                            Priority.medium, AppColors.mediumPriority),
                        const SizedBox(width: 10),
                        _priorityChip(Priority.low, AppColors.lowPriority),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('Reminder',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: context.inputColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _reminder,
                          dropdownColor: context.cardColor,
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: context.textSecondary),
                          items: const [
                            'No reminder',
                            '1 hour before',
                            '6 hours before',
                            '1 day before',
                            '2 days before',
                            '1 week before'
                          ]
                              .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s,
                                      style: TextStyle(
                                          color: context.textPrimary))))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _reminder = v ?? _reminder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Notes',
                      controller: _notes,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                label: _isEdit ? 'Save Changes' : 'Save Assignment',
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priorityChip(Priority p, Color color) {
    final selected = _priority == p;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = p),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : context.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? color : context.borderColor),
          ),
          alignment: Alignment.center,
          child: Text(p.label,
              style: TextStyle(
                color: selected ? Colors.white : context.textPrimary,
                fontWeight: FontWeight.w600,
              )),
        ),
      ),
    );
  }
}
