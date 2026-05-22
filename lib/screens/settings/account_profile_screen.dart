import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key});

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This will permanently remove your account, all your courses, and all your assignments. This action cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete forever',
                  style: TextStyle(color: AppColors.errorRed))),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final ok = await context.read<AuthProvider>().deleteAccount();
    if (!context.mounted) return;
    if (ok) {
      // Pop AccountProfileScreen → Settings → MainShell back to root.
      // _AuthGate is now showing SignInScreen because _user is null, so
      // the user lands directly on the Sign In page.
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted'),
          backgroundColor: AppColors.errorRed,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete account. Please try again.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(showBack: true),
              const SizedBox(height: 18),
              const PageTitle('Profile'),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    ProfileAvatar(
                      initials: user?.initials ?? '?',
                      imagePath: user?.avatarPath,
                      size: 96,
                    ),
                    const SizedBox(height: 14),
                    Text(user?.fullName ?? '',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '',
                        style: TextStyle(
                            color: context.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _InfoCard(
                rows: [
                  _InfoRow(
                      icon: Icons.person_outline,
                      label: 'First Name',
                      value: user?.firstName ?? ''),
                  _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Last Name',
                      value: user?.lastName ?? ''),
                  _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user?.email ?? ''),
                  _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: user?.phone.isNotEmpty == true
                          ? user!.phone
                          : '—'),
                  _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Student ID',
                      value: user?.studentId.isNotEmpty == true
                          ? user!.studentId
                          : '—',
                      locked: true),
                ],
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Edit Profile',
                icon: Icons.edit_outlined,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen()),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedTealButton(
                label: 'Change Password',
                trailingIcon: Icons.lock_outline,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen()),
                ),
              ),
              const SizedBox(height: 10),
              // Delete Account — destructive action, below Change Password.
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmAndDelete(context),
                  icon: const Icon(Icons.delete_forever_outlined, size: 18),
                  label: const Text('Delete Account'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorRed,
                    side: const BorderSide(color: AppColors.errorRed),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: rows),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool locked;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: context.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (locked)
            Tooltip(
              message: 'Student ID is fixed and cannot be changed',
              child: Icon(Icons.lock_outline,
                  size: 16, color: context.textHint),
            ),
        ],
      ),
    );
  }
}
