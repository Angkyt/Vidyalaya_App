class Course {
  final String id;
  String name;
  String code; // e.g. "DES101"
  String lecturer;
  // Structured schedule
  int dayOfWeek; // 1=Mon..7=Sun, 0=none
  int startHour; // 0-23, -1 = unset
  int startMinute;
  int endHour;
  int endMinute;
  String semester;
  String room;
  int colorIndex;
  // Course duration — null = open-ended.
  DateTime? courseStartDate;
  DateTime? courseEndDate;

  Course({
    required this.id,
    required this.name,
    required this.lecturer,
    this.code = '',
    this.dayOfWeek = 0,
    this.startHour = -1,
    this.startMinute = 0,
    this.endHour = -1,
    this.endMinute = 0,
    this.semester = '',
    this.room = '',
    this.colorIndex = 0,
    this.courseStartDate,
    this.courseEndDate,
  });

  bool get hasSchedule =>
      dayOfWeek >= 1 && dayOfWeek <= 7 && startHour >= 0 && endHour >= 0;

  bool get hasDateRange =>
      courseStartDate != null && courseEndDate != null;

  /// Whether [day] falls inside this course's date range (inclusive).
  /// If no range is set, every day counts as "within".
  bool containsDate(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    if (courseStartDate != null) {
      final s = DateTime(courseStartDate!.year, courseStartDate!.month,
          courseStartDate!.day);
      if (d.isBefore(s)) return false;
    }
    if (courseEndDate != null) {
      final e = DateTime(courseEndDate!.year, courseEndDate!.month,
          courseEndDate!.day);
      if (d.isAfter(e)) return false;
    }
    return true;
  }

  bool isStartDate(DateTime day) =>
      courseStartDate != null &&
      day.year == courseStartDate!.year &&
      day.month == courseStartDate!.month &&
      day.day == courseStartDate!.day;

  bool isEndDate(DateTime day) =>
      courseEndDate != null &&
      day.year == courseEndDate!.year &&
      day.month == courseEndDate!.month &&
      day.day == courseEndDate!.day;

  /// Pretty label e.g. "Tue 10:00 AM – 12:00 PM"
  String get scheduleLabel {
    if (!hasSchedule) return '';
    return '${_dayShort(dayOfWeek)} ${_fmt(startHour, startMinute)} – ${_fmt(endHour, endMinute)}';
  }

  static String _dayShort(int d) =>
      ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d];
  static String _dayFull(int d) => [
        '',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ][d];

  static String _fmt(int h, int m) {
    final period = h >= 12 ? 'PM' : 'AM';
    final hh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final mm = m.toString().padLeft(2, '0');
    return '$hh:$mm $period';
  }

  String get dayFullName => _dayFull(dayOfWeek);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'lecturer': lecturer,
        'dayOfWeek': dayOfWeek,
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
        'semester': semester,
        'room': room,
        'colorIndex': colorIndex,
        'courseStartDate': courseStartDate?.toIso8601String(),
        'courseEndDate': courseEndDate?.toIso8601String(),
      };

  factory Course.fromJson(Map<String, dynamic> j) => Course(
        id: j['id'] as String,
        name: j['name'] as String,
        code: (j['code'] ?? '') as String,
        lecturer: (j['lecturer'] ?? '') as String,
        dayOfWeek: (j['dayOfWeek'] ?? 0) as int,
        startHour: (j['startHour'] ?? -1) as int,
        startMinute: (j['startMinute'] ?? 0) as int,
        endHour: (j['endHour'] ?? -1) as int,
        endMinute: (j['endMinute'] ?? 0) as int,
        semester: (j['semester'] ?? '') as String,
        room: (j['room'] ?? '') as String,
        colorIndex: (j['colorIndex'] ?? 0) as int,
        courseStartDate: j['courseStartDate'] == null
            ? null
            : DateTime.parse(j['courseStartDate'] as String),
        courseEndDate: j['courseEndDate'] == null
            ? null
            : DateTime.parse(j['courseEndDate'] as String),
      );
}
