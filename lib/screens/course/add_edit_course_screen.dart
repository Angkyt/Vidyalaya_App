import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../providers/study_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AddEditCourseScreen extends StatefulWidget {
  final Course? course;
  const AddEditCourseScreen({super.key, this.course});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  late final _name = TextEditingController(text: widget.course?.name ?? '');
  late final _code = TextEditingController(text: widget.course?.code ?? '');
  late final _lecturer =
      TextEditingController(text: widget.course?.lecturer ?? '');
  late final _semester =
      TextEditingController(text: widget.course?.semester ?? '');
  late final _room = TextEditingController(text: widget.course?.room ?? '');
  late int _color = widget.course?.colorIndex ?? 0;
  late int _dayOfWeek = widget.course?.dayOfWeek ?? 0; // 0 = no schedule
  late TimeOfDay? _startTime = (widget.course?.startHour ?? -1) >= 0
      ? TimeOfDay(
          hour: widget.course!.startHour, minute: widget.course!.startMinute)
      : null;
  late TimeOfDay? _endTime = (widget.course?.endHour ?? -1) >= 0
      ? TimeOfDay(
          hour: widget.course!.endHour, minute: widget.course!.endMinute)
      : null;
  late DateTime? _courseStartDate = widget.course?.courseStartDate;
  late DateTime? _courseEndDate = widget.course?.courseEndDate;

  String? _nameError;
  String? _codeError;
  String? _lecturerError;
  String? _scheduleError;
  String? _dateError;
  bool _saving = false;

  bool get _isEdit => widget.course != null;

  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _lecturer.dispose();
    _semester.dispose();
    _room.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool start) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (start ? _startTime : _endTime) ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
      _scheduleError = null;
    });
  }

  Future<void> _pickCourseDate(bool isStart) async {
    final initial = isStart
        ? (_courseStartDate ?? DateTime.now())
        : (_courseEndDate ??
            _courseStartDate?.add(const Duration(days: 90)) ??
            DateTime.now().add(const Duration(days: 90)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      helpText: isStart ? 'Course start date' : 'Course end date',
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _courseStartDate = picked;
      } else {
        _courseEndDate = picked;
      }
      _dateError = null;
    });
  }

  Future<void> _save() async {
    setState(() {
      _nameError = _name.text.trim().isEmpty ? 'Course name is required' : null;
      _codeError = _code.text.trim().isEmpty ? 'Course code is required' : null;
      _lecturerError =
          _lecturer.text.trim().isEmpty ? 'Lecturer is required' : null;
      _scheduleError = null;
      _dateError = null;
    });

    // Validate schedule consistency (all three must be set together, or none)
    final scheduleProvided =
        _dayOfWeek > 0 || _startTime != null || _endTime != null;
    final scheduleComplete =
        _dayOfWeek > 0 && _startTime != null && _endTime != null;
    if (scheduleProvided && !scheduleComplete) {
      setState(() => _scheduleError =
          'Please set day, start time, and end time — or leave the schedule blank.');
    }
    if (scheduleComplete) {
      final start = _startTime!.hour * 60 + _startTime!.minute;
      final end = _endTime!.hour * 60 + _endTime!.minute;
      if (end <= start) {
        setState(() =>
            _scheduleError = 'End time must be after start time.');
      }
    }

    // Validate course dates — both set together or none, and end ≥ start.
    final dateProvided = _courseStartDate != null || _courseEndDate != null;
    final dateComplete = _courseStartDate != null && _courseEndDate != null;
    if (dateProvided && !dateComplete) {
      setState(() => _dateError =
          'Please set both start and end dates — or leave both blank.');
    }
    if (dateComplete && _courseEndDate!.isBefore(_courseStartDate!)) {
      setState(() => _dateError = 'End date must be on or after start date.');
    }

    if (_nameError != null ||
        _codeError != null ||
        _lecturerError != null ||
        _scheduleError != null ||
        _dateError != null) {
      return;
    }

    setState(() => _saving = true);
    final data = context.read<StudyDataProvider>();
    final dow = scheduleComplete ? _dayOfWeek : 0;
    final sh = scheduleComplete ? _startTime!.hour : -1;
    final sm = scheduleComplete ? _startTime!.minute : 0;
    final eh = scheduleComplete ? _endTime!.hour : -1;
    final em = scheduleComplete ? _endTime!.minute : 0;

    if (_isEdit) {
      final c = widget.course!;
      c.name = _name.text.trim();
      c.code = _code.text.trim();
      c.lecturer = _lecturer.text.trim();
      c.dayOfWeek = dow;
      c.startHour = sh;
      c.startMinute = sm;
      c.endHour = eh;
      c.endMinute = em;
      c.semester = _semester.text.trim();
      c.room = _room.text.trim();
      c.colorIndex = _color;
      c.courseStartDate = _courseStartDate;
      c.courseEndDate = _courseEndDate;
      await data.updateCourse(c);
    } else {
      await data.addCourse(
        name: _name.text.trim(),
        code: _code.text.trim(),
        lecturer: _lecturer.text.trim(),
        dayOfWeek: dow,
        startHour: sh,
        startMinute: sm,
        endHour: eh,
        endMinute: em,
        semester: _semester.text.trim(),
        room: _room.text.trim(),
        colorIndex: _color,
        courseStartDate: _courseStartDate,
        courseEndDate: _courseEndDate,
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Course updated' : 'Course added'),
        backgroundColor: AppColors.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
              PageTitle(_isEdit ? 'Edit Course' : 'Add Course'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    AppTextField(
                      label: 'Course Name *',
                      controller: _name,
                      errorText: _nameError,
                      prefixIcon: Icons.menu_book_outlined,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Course Code *',
                      controller: _code,
                      errorText: _codeError,
                      prefixIcon: Icons.tag,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Lecturer *',
                      controller: _lecturer,
                      errorText: _lecturerError,
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 18),

                    // Schedule section
                    Row(
                      children: [
                        Text('Class Schedule',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: context.textPrimary)),
                        const SizedBox(width: 8),
                        Text('(optional)',
                            style: TextStyle(
                                fontSize: 11, color: context.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Day-of-week
                    Container(
                      decoration: BoxDecoration(
                        color: context.inputColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _dayOfWeek,
                          dropdownColor: context.cardColor,
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: context.textSecondary),
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text('No day selected',
                                  style: TextStyle(color: context.textHint)),
                            ),
                            for (var i = 0; i < _days.length; i++)
                              DropdownMenuItem(
                                value: i + 1,
                                child: Row(
                                  children: [
                                    Icon(Icons.event,
                                        size: 16,
                                        color: context.textSecondary),
                                    const SizedBox(width: 10),
                                    Text(_days[i],
                                        style: TextStyle(
                                            color: context.textPrimary)),
                                  ],
                                ),
                              ),
                          ],
                          onChanged: (v) => setState(() {
                            _dayOfWeek = v ?? 0;
                            _scheduleError = null;
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _timeBox(
                            label: 'Start Time',
                            time: _startTime,
                            onTap: () => _pickTime(true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _timeBox(
                            label: 'End Time',
                            time: _endTime,
                            onTap: () => _pickTime(false),
                          ),
                        ),
                      ],
                    ),
                    if (_scheduleError != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 14, color: AppColors.errorRed),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(_scheduleError!,
                                style: const TextStyle(
                                    color: AppColors.errorRed, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                    if (_dayOfWeek > 0 &&
                        _startTime != null &&
                        _endTime != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_available,
                                size: 16, color: AppColors.teal),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This class will appear every ${_days[_dayOfWeek - 1]} in the Calendar.',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.teal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),

                    // Course duration — appears on the calendar as start/end markers
                    Row(
                      children: [
                        Text('Course Duration',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: context.textPrimary)),
                        const SizedBox(width: 8),
                        Text('(optional)',
                            style: TextStyle(
                                fontSize: 11, color: context.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _dateBox(
                            label: 'Start Date',
                            date: _courseStartDate,
                            onTap: () => _pickCourseDate(true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dateBox(
                            label: 'End Date',
                            date: _courseEndDate,
                            onTap: () => _pickCourseDate(false),
                          ),
                        ),
                      ],
                    ),
                    if (_dateError != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 14, color: AppColors.errorRed),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(_dateError!,
                                style: const TextStyle(
                                    color: AppColors.errorRed, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                    if (_courseStartDate != null &&
                        _courseEndDate != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_available,
                                size: 16, color: AppColors.teal),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Course start and end will appear on the Calendar.',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.teal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),

                    AppTextField(
                      label: 'Room',
                      controller: _room,
                      prefixIcon: Icons.room_outlined,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Semester',
                      controller: _semester,
                      prefixIcon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 18),
                    Text('Color',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(CourseColors.palette.length, (i) {
                        final c = CourseColors.palette[i];
                        final selected = _color == i;
                        return GestureDetector(
                          onTap: () => setState(() => _color = i),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    selected ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                          color: c.withOpacity(0.4),
                                          blurRadius: 6)
                                    ]
                                  : null,
                            ),
                            child: selected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                  label: _isEdit ? 'Save Changes' : 'Add Course',
                  loading: _saving,
                  onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeBox({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: context.inputColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, size: 18, color: context.textHint),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11, color: context.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    time == null
                        ? 'Pick time'
                        : time.format(context),
                    style: TextStyle(
                        fontSize: 14,
                        color: time == null
                            ? context.textHint
                            : context.textPrimary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateBox({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final formatted = date == null
        ? 'Pick date'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: context.inputColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.event, size: 18, color: context.textHint),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11, color: context.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    formatted,
                    style: TextStyle(
                        fontSize: 14,
                        color: date == null
                            ? context.textHint
                            : context.textPrimary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
