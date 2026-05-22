import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/study_data_provider.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsProvider();
  final auth = AuthProvider();
  final study = StudyDataProvider();

  // Bootstrap saved theme + session
  await settings.bootstrap();
  await auth.bootstrap();
  await study.setUser(auth.user?.id);

  // Whenever auth changes (login/logout/profile), keep study data in sync.
  auth.addListener(() {
    study.setUser(auth.user?.id);
  });

  runApp(VidyalayaApp(
    settings: settings,
    auth: auth,
    study: study,
  ));
}

class VidyalayaApp extends StatelessWidget {
  final SettingsProvider settings;
  final AuthProvider auth;
  final StudyDataProvider study;
  const VidyalayaApp({
    super.key,
    required this.settings,
    required this.auth,
    required this.study,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: study),
      ],
      child: Consumer<SettingsProvider>(
        builder: (_, s, __) => MaterialApp(
          title: 'Vidyalaya',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: s.themeMode,
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }
    return auth.isLoggedIn ? const MainShell() : const SignInScreen();
  }
}
