import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'about_us_screen.dart';
import 'account_profile_screen.dart';
import 'help_support_screen.dart';
import 'notification_preferences_screen.dart';
import 'privacy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final settings = context.watch<SettingsProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(),
            const SizedBox(height: 18),
            Text('Settings',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),

            // Profile pill (tap to open Account / Profile)
            AppCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AccountProfileScreen()),
              ),
              child: Row(
                children: [
                  ProfileAvatar(
                    initials: user?.initials ?? '?',
                    imagePath: user?.avatarPath,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.fullName ?? 'Guest',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(user?.email ?? '',
                            style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: context.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Appearance
            Text('Appearance',
                style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4)),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: _SwitchRow(
                icon: Icons.dark_mode_outlined,
                label: 'Dark mode',
                value: settings.isDark,
                onChanged: settings.setDark,
              ),
            ),
            const SizedBox(height: 18),

            // Notifications
            Text('Notifications',
                style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4)),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: _NavRow(
                icon: Icons.notifications_active_outlined,
                label: 'Notification Preferences',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationPreferencesScreen()),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Account
            Text('Account',
                style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4)),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _NavRow(
                    icon: Icons.shield_outlined,
                    label: 'Privacy',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyScreen()),
                    ),
                  ),
                  _NavRow(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen()),
                    ),
                  ),
                  _NavRow(
                    icon: Icons.info_outline,
                    label: 'About Us',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AboutUsScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Logout
            OutlinedButton.icon(
              onPressed: () async {
                final ok = await _confirmLogout(context);
                if (ok != true || !context.mounted) return;
                await context.read<AuthProvider>().logout();
                // No manual navigation — AuthGate rebuilds to SignInScreen.
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.errorRed,
                side: const BorderSide(color: AppColors.errorRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmLogout(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('You will need to sign in again to access your data.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout',
                  style: TextStyle(color: AppColors.errorRed))),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavRow(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.textSecondary),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
            Icon(Icons.chevron_right,
                size: 18, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.textSecondary),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.teal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
