import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class WellbeingScreen extends StatefulWidget {
  const WellbeingScreen({super.key});

  @override
  State<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends State<WellbeingScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _running = false;

  static const _tips = [
    "Take a deep breath. You've got this.",
    "Drink a glass of water — your brain runs on hydration.",
    "Stand up and stretch for 30 seconds.",
    "Look 20 feet away for 20 seconds to rest your eyes.",
    "A short walk now beats burnout later.",
    "Progress, not perfection. One task at a time.",
    "Your worth isn't measured by your productivity.",
    "Rest is part of the work, not a reward for it.",
    "Five slow breaths can reset a stressed mind.",
    "Done is better than perfect.",
  ];

  @override
  void initState() {
    super.initState();
    _tipIndex = DateTime.now().millisecondsSinceEpoch % _tips.length;
  }

  late int _tipIndex;

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _running = true;
      _elapsed = Duration.zero;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _nextTip() {
    setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(),
            const SizedBox(height: 18),
            Text('Wellbeing',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text("Avoid burnout. Take care of yourself.",
                style:
                    TextStyle(color: context.textSecondary, fontSize: 13)),
            const SizedBox(height: 18),

            // Motivational card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.teal, Color(0xFF0F6E66)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.format_quote, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text('Daily Reminder',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_tips[_tipIndex],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3)),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _nextTip,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Next tip',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Break timer
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.timer_outlined, color: AppColors.teal),
                      SizedBox(width: 8),
                      Text('Study Break Timer',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(_fmt(_elapsed),
                        style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                            letterSpacing: 2)),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      _running
                          ? 'Break in progress — relax fully'
                          : 'Start a focus break',
                      style: TextStyle(
                          color: context.textSecondary, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.textPrimary,
                            side: BorderSide(color: context.borderColor),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            _stopTimer();
                            setState(() => _elapsed = Duration.zero);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                          label: Text(_running ? 'Pause' : 'Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _running ? _stopTimer : _startTimer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Break Reminder Interval — wellbeing-related, lives here
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notifications_active_outlined,
                          color: AppColors.teal),
                      SizedBox(width: 8),
                      Text('Break Reminder Interval',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Get nudged to take a break every ${settings.breakIntervalMinutes} minutes',
                    style: TextStyle(
                        fontSize: 12, color: context.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [15, 25, 30, 45, 60, 90].map((m) {
                      final selected = settings.breakIntervalMinutes == m;
                      return PillChip(
                        label: '$m min',
                        selected: selected,
                        activeColor: AppColors.teal,
                        onTap: () => settings.setBreakInterval(m),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Tips grid
            Text('Quick wellbeing tips',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ..._tips.take(5).map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.spa,
                              color: AppColors.teal, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(t,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
