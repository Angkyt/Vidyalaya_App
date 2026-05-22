import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which categories of notifications the user wants to receive.
class NotifTypeFilter {
  bool assignments;
  bool assessments;
  bool announcements;
  NotifTypeFilter({
    this.assignments = true,
    this.assessments = true,
    this.announcements = true,
  });
  Map<String, dynamic> toJson() => {
        'assignments': assignments,
        'assessments': assessments,
        'announcements': announcements,
      };
  factory NotifTypeFilter.fromJson(Map<String, dynamic> j) => NotifTypeFilter(
        assignments: (j['assignments'] ?? true) as bool,
        assessments: (j['assessments'] ?? true) as bool,
        announcements: (j['announcements'] ?? true) as bool,
      );
}

class SettingsProvider extends ChangeNotifier {
  static const _kThemeMode = 'theme_mode_v1';
  static const _kNotifs = 'notifs_enabled_v1';
  static const _kReminders = 'reminders_enabled_v1';
  static const _kBreakInterval = 'break_interval_min_v1';
  static const _kWaterReminder = 'water_reminder_v1';
  static const _kStretchReminder = 'stretch_reminder_v1';
  static const _kLanguage = 'language_v1';
  static const _kTypeFilter = 'notif_type_filter_v1';
  static const _kMutedCourses = 'muted_courses_v1';

  ThemeMode _themeMode = ThemeMode.light;
  bool _notifsEnabled = true;
  bool _remindersEnabled = true;
  int _breakIntervalMinutes = 60;
  bool _waterReminder = true;
  bool _stretchReminder = true;
  String _language = 'English';
  NotifTypeFilter _typeFilter = NotifTypeFilter();
  // Set of course IDs the user has muted notifications for.
  Set<String> _mutedCourseIds = {};

  ThemeMode get themeMode => _themeMode;
  bool get notifsEnabled => _notifsEnabled;
  bool get remindersEnabled => _remindersEnabled;
  int get breakIntervalMinutes => _breakIntervalMinutes;
  bool get waterReminder => _waterReminder;
  bool get stretchReminder => _stretchReminder;
  String get language => _language;
  bool get isDark => _themeMode == ThemeMode.dark;
  NotifTypeFilter get typeFilter => _typeFilter;
  Set<String> get mutedCourseIds => Set.unmodifiable(_mutedCourseIds);

  bool isCourseMuted(String courseId) => _mutedCourseIds.contains(courseId);

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final tm = prefs.getString(_kThemeMode);
    _themeMode = tm == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _notifsEnabled = prefs.getBool(_kNotifs) ?? true;
    _remindersEnabled = prefs.getBool(_kReminders) ?? true;
    _breakIntervalMinutes = prefs.getInt(_kBreakInterval) ?? 60;
    _waterReminder = prefs.getBool(_kWaterReminder) ?? true;
    _stretchReminder = prefs.getBool(_kStretchReminder) ?? true;
    _language = prefs.getString(_kLanguage) ?? 'English';
    final tfRaw = prefs.getString(_kTypeFilter);
    if (tfRaw != null) {
      try {
        _typeFilter =
            NotifTypeFilter.fromJson(jsonDecode(tfRaw) as Map<String, dynamic>);
      } catch (_) {
        _typeFilter = NotifTypeFilter();
      }
    }
    final muted = prefs.getStringList(_kMutedCourses);
    if (muted != null) _mutedCourseIds = muted.toSet();
    notifyListeners();
  }

  Future<void> setDark(bool v) async {
    _themeMode = v ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, v ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setNotifsEnabled(bool v) async {
    _notifsEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifs, v);
    notifyListeners();
  }

  Future<void> setRemindersEnabled(bool v) async {
    _remindersEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminders, v);
    notifyListeners();
  }

  Future<void> setBreakInterval(int minutes) async {
    _breakIntervalMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBreakInterval, minutes);
    notifyListeners();
  }

  Future<void> setWaterReminder(bool v) async {
    _waterReminder = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kWaterReminder, v);
    notifyListeners();
  }

  Future<void> setStretchReminder(bool v) async {
    _stretchReminder = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kStretchReminder, v);
    notifyListeners();
  }

  Future<void> setLanguage(String v) async {
    _language = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, v);
    notifyListeners();
  }

  Future<void> setTypeFilter(NotifTypeFilter v) async {
    _typeFilter = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTypeFilter, jsonEncode(v.toJson()));
    notifyListeners();
  }

  Future<void> setCourseMuted(String courseId, bool muted) async {
    if (muted) {
      _mutedCourseIds.add(courseId);
    } else {
      _mutedCourseIds.remove(courseId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kMutedCourses, _mutedCourseIds.toList());
    notifyListeners();
  }
}
