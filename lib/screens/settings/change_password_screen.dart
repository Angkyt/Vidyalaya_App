import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _newPwd = TextEditingController();
  final _confirm = TextEditingController();

  String? _currentError;
  String? _newError;
  String? _confirmError;
  String? _bannerMsg;
  bool _saving = false;
  bool _newFocused = false;

  @override
  void initState() {
    super.initState();
    _newPwd.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _current.dispose();
    _newPwd.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _currentError =
          _current.text.isEmpty ? 'Current password is required' : null;
      _newError = _newPwd.text.isEmpty
          ? 'New password is required'
          : !AuthService.isStrong(_newPwd.text)
              ? 'Password does not meet all requirements'
              : null;
      _confirmError =
          _confirm.text != _newPwd.text ? 'Passwords do not match' : null;
      _bannerMsg = null;
    });
    if (_currentError != null ||
        _newError != null ||
        _confirmError != null) return;

    setState(() => _saving = true);
    final ok = await context.read<AuthProvider>().updateProfile(
          currentPassword: _current.text,
          newPassword: _newPwd.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated'),
          backgroundColor: AppColors.successGreen,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      setState(() => _bannerMsg =
          'Current password is incorrect, or new password is not strong enough.');
    }
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
              const PageTitle('Change Password'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    if (_bannerMsg != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  AppColors.errorRed.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.errorRed, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(_bannerMsg!,
                                    style: const TextStyle(
                                        color: AppColors.errorRed,
                                        fontSize: 13))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    AppTextField(
                      label: 'Current Password',
                      controller: _current,
                      obscureText: true,
                      errorText: _currentError,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 14),
                    Focus(
                      onFocusChange: (f) =>
                          setState(() => _newFocused = f),
                      child: AppTextField(
                        label: 'New Password',
                        controller: _newPwd,
                        obscureText: true,
                        errorText: _newError,
                        prefixIcon: Icons.lock_outline,
                      ),
                    ),
                    if (_newFocused || _newPwd.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      PasswordRulesIndicator(password: _newPwd.text),
                    ],
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Confirm New Password',
                      controller: _confirm,
                      obscureText: true,
                      errorText: _confirmError,
                      prefixIcon: Icons.lock_outline,
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                label: 'Update Password',
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
