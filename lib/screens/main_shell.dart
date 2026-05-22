import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import 'dashboard/dashboard_screen.dart';
import 'course/course_list_screen.dart';
import 'calendar/calendar_screen.dart';
import 'wellbeing/wellbeing_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _screens = const [
    DashboardScreen(),
    CourseListScreen(),
    CalendarScreen(),
    WellbeingScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
