import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
              const PageTitle('About Us'),
              const SizedBox(height: 16),
              const SizedBox(height: 22),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'V',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Vidyalaya',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Smart school management mobile app',
                        style: TextStyle(
                            fontSize: 13, color: context.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Expanded(
                child: ListView(
                  children: [
                    _row(context, 'Who we are',
                        'Vidyalaya helps students, parents, and teachers stay connected through schedules, updates, attendance, and communication tools.'),
                    const SizedBox(height: 10),
                    _row(context, 'Our mission',
                        'To simplify everyday school communication and student wellbeing in one place.'),
                    const SizedBox(height: 10),
                    _row(context, 'Version', 'App Version 2.0.0'),
                    const SizedBox(height: 10),
                    _row(context, 'Contact', 'www.vidyalaya.com'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String title, String subtitle) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(fontSize: 12, color: context.textSecondary)),
        ],
      ),
    );
  }
}
