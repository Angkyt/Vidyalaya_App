import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/course.dart';
import '../models/assignment.dart';

class StudyDataProvider extends ChangeNotifier {
  String? _userId;
  List<Course> _courses = [];
  List<Assignment> _assignments = [];

  List<Course> get courses => List.unmodifiable(_courses);
  List<Assignment> get assignments => List.unmodifiable(_assignments);

  String _kCourses() => 'courses_${_userId}_v2';
  String _kAssignments() => 'assignments_${_userId}_v2';

  Future<void> setUser(String? userId) async {
    _userId = userId;
    if (userId == null) {
      _courses = [];
      _assignments = [];
      notifyListeners();
      return;
    }
    await _load();
    // No demo seeding — new users start with an empty dashboard.
    // Courses and assignments are added by the user manually.
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final cRaw = prefs.getString(_kCourses());
    final aRaw = prefs.getString(_kAssignments());
    _courses = cRaw == null
        ? []
        : (jsonDecode(cRaw) as List)
            .map((e) => Course.fromJson(e as Map<String, dynamic>))
            .toList();
    _assignments = aRaw == null
        ? []
        : (jsonDecode(aRaw) as List)
            .map((e) => Assignment.fromJson(e as Map<String, dynamic>))
            .toList();
  }

  Future<void> _persist() async {
    if (_userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCourses(),
        jsonEncode(_courses.map((c) => c.toJson()).toList()));
    await prefs.setString(_kAssignments(),
        jsonEncode(_assignments.map((a) => a.toJson()).toList()));
  }

  // ---------- Course CRUD ----------
  Future<Course> addCourse({
    required String name,
    required String lecturer,
    String code = '',
    int dayOfWeek = 0,
    int startHour = -1,
    int startMinute = 0,
    int endHour = -1,
    int endMinute = 0,
    String room = '',
    String semester = '',
    int colorIndex = 0,
    DateTime? courseStartDate,
    DateTime? courseEndDate,
  }) async {
    final c = Course(
      id: const Uuid().v4(),
      name: name,
      code: code,
      lecturer: lecturer,
      dayOfWeek: dayOfWeek,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      room: room,
      semester: semester,
      colorIndex: colorIndex,
      courseStartDate: courseStartDate,
      courseEndDate: courseEndDate,
    );
    _courses.add(c);
    await _persist();
    notifyListeners();
    return c;
  }

  Future<void> updateCourse(Course updated) async {
    final idx = _courses.indexWhere((c) => c.id == updated.id);
    if (idx >= 0) {
      _courses[idx] = updated;
      await _persist();
      notifyListeners();
    }
  }

  Future<void> deleteCourse(String courseId) async {
    _courses.removeWhere((c) => c.id == courseId);
    _assignments.removeWhere((a) => a.courseId == courseId);
    await _persist();
    notifyListeners();
  }

  Course? courseById(String id) {
    for (final c in _courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ---------- Assignment CRUD ----------
  Future<Assignment> addAssignment({
    required String courseId,
    required String title,
    required DateTime dueDate,
    String notes = '',
    Priority priority = Priority.medium,
    String reminder = '1 day before',
  }) async {
    final a = Assignment(
      id: const Uuid().v4(),
      courseId: courseId,
      title: title,
      dueDate: dueDate,
      notes: notes,
      priority: priority,
      reminder: reminder,
    );
    _assignments.add(a);
    await _persist();
    notifyListeners();
    return a;
  }

  Future<void> updateAssignment(Assignment a) async {
    final i = _assignments.indexWhere((x) => x.id == a.id);
    if (i >= 0) {
      _assignments[i] = a;
      await _persist();
      notifyListeners();
    }
  }

  Future<void> deleteAssignment(String id) async {
    _assignments.removeWhere((a) => a.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> setProgress(String id, int progress) async {
    final i = _assignments.indexWhere((x) => x.id == id);
    if (i < 0) return;
    final a = _assignments[i];
    a.progress = progress.clamp(0, 100);
    if (a.progress >= 100) {
      a.status = AssignmentStatus.completed;
    } else if (a.progress > 0) {
      a.status = AssignmentStatus.inProgress;
    } else {
      a.status = AssignmentStatus.pending;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> markComplete(String id) async {
    final i = _assignments.indexWhere((x) => x.id == id);
    if (i < 0) return;
    _assignments[i].status = AssignmentStatus.completed;
    _assignments[i].progress = 100;
    await _persist();
    notifyListeners();
  }

  // ---------- Derived ----------
  List<Assignment> assignmentsForCourse(String courseId) =>
      _assignments.where((a) => a.courseId == courseId).toList();

  /// Returns assignments due on this date.
  List<Assignment> assignmentsOn(DateTime day) {
    return _assignments.where((a) =>
        a.dueDate.year == day.year &&
        a.dueDate.month == day.month &&
        a.dueDate.day == day.day).toList();
  }

  /// Courses meeting on this date — must be the right weekday AND inside
  /// the course's start/end date range (if one is set).
  List<Course> classesOn(DateTime day) {
    final dow = day.weekday; // 1..7
    return _courses
        .where((c) =>
            c.dayOfWeek == dow && c.hasSchedule && c.containsDate(day))
        .toList();
  }

  /// Courses whose semester/duration starts on this date.
  List<Course> coursesStartingOn(DateTime day) {
    return _courses.where((c) => c.isStartDate(day)).toList();
  }

  /// Courses whose semester/duration ends on this date.
  List<Course> coursesEndingOn(DateTime day) {
    return _courses.where((c) => c.isEndDate(day)).toList();
  }

  int progressForCourse(String courseId) {
    final list = assignmentsForCourse(courseId);
    if (list.isEmpty) return 0;
    final sum = list.fold<int>(0, (s, a) => s + a.progress);
    return (sum / list.length).round();
  }

  int dueTaskCount(String courseId) =>
      assignmentsForCourse(courseId)
          .where((a) => a.status != AssignmentStatus.completed)
          .length;

  List<Assignment> get upcoming {
    final list = [..._assignments]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list
        .where((a) => a.status != AssignmentStatus.completed)
        .toList();
  }

  /// Anything not completed AND (overdue OR within 48 hours of due).
  List<Assignment> get urgentOrOverdue {
    return _assignments
        .where((a) =>
            a.status != AssignmentStatus.completed &&
            (a.isOverdue || a.isUrgent))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Pending = not completed.
  List<Assignment> get pending {
    return _assignments
        .where((a) => a.status != AssignmentStatus.completed)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
}
