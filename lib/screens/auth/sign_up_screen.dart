import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _student = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _studentError;
  String? _passwordError;
  String? _confirmError;
  String? _bannerMsg;
  bool _loading = false;
  bool _passwordFocused = false;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _student.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _validateLocally() {
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _phoneError = null;
      _studentError = null;
      _passwordError = null;
      _confirmError = null;
      _bannerMsg = null;
    });
    bool ok = true;
    if (_firstName.text.trim().isEmpty) {
      setState(() => _firstNameError = 'First name is required');
      ok = false;
    }
    if (_lastName.text.trim().isEmpty) {
      setState(() => _lastNameError = 'Last name is required');
      ok = false;
    }
    if (_email.text.trim().isEmpty) {
      setState(() => _emailError = 'Email is required');
      ok = false;
    } else if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(_email.text.trim())) {
      setState(() => _emailError = 'Enter a valid email');
      ok = false;
    }
    if (_phone.text.trim().isEmpty) {
      setState(() => _phoneError = 'Phone number is required');
      ok = false;
    } else if (!AuthService.isValidPhone(_phone.text)) {
      setState(() => _phoneError = 'Enter at least 7 digits');
      ok = false;
    }
    if (_student.text.trim().isEmpty) {
      setState(() => _studentError = 'Student ID is required');
      ok = false;
    }
    if (_password.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      ok = false;
    } else if (!AuthService.isStrong(_password.text)) {
      setState(() => _passwordError = 'Password does not meet all requirements');
      ok = false;
    }
    if (_confirm.text != _password.text) {
      setState(() => _confirmError = 'Passwords do not match');
      ok = false;
    }
    return ok;
  }

  Future<void> _submit() async {
    if (!_validateLocally()) return;
    setState(() => _loading = true);
    final res = await context.read<AuthProvider>().register(
          firstName: _firstName.text,
          lastName: _lastName.text,
          email: _email.text,
          studentId: _student.text,
          phone: _phone.text,
          password: _password.text,
          confirmPassword: _confirm.text,
          startSession: false, // Force re-login per requirement #3
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!res.success) {
      setState(() {
        _bannerMsg = res.error!.message;
        if (res.error == AuthError.phoneAlreadyRegistered) {
          _phoneError = 'Mobile number already used';
        }
        if (res.error == AuthError.emailAlreadyRegistered) {
          _emailError = 'Email already registered';
        }
        if (res.error == AuthError.studentIdRequired) {
          _studentError = 'Student ID is required';
        }
      });
      return;
    }
    // Show success page, then route to sign in
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _SignUpSuccessScreen(email: _email.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(),
              const SizedBox(height: 24),
              Text('Create account',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text('Join Vidyalaya to plan smarter',
                  style: TextStyle(color: context.textSecondary)),
              const SizedBox(height: 22),
              if (_bannerMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.errorRed, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_bannerMsg!,
                              style: const TextStyle(
                                  color: AppColors.errorRed, fontSize: 13))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                        label: 'First Name',
                        controller: _firstName,
                        errorText: _firstNameError,
                        prefixIcon: Icons.person_outline),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppTextField(
                        label: 'Last Name',
                        controller: _lastName,
                        errorText: _lastNameError,
                        prefixIcon: Icons.person_outline),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                  label: 'Email',
                  controller: _email,
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined),
              const SizedBox(height: 14),
              AppTextField(
                  label: 'Phone Number',
                  controller: _phone,
                  errorText: _phoneError,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined),
              const SizedBox(height: 14),
              AppTextField(
                  label: 'Student ID',
                  controller: _student,
                  errorText: _studentError,
                  prefixIcon: Icons.badge_outlined),
              const SizedBox(height: 14),
              Focus(
                onFocusChange: (f) => setState(() => _passwordFocused = f),
                child: AppTextField(
                    label: 'Password',
                    controller: _password,
                    obscureText: true,
                    errorText: _passwordError,
                    prefixIcon: Icons.lock_outline),
              ),
              if (_passwordFocused || _password.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                PasswordRulesIndicator(password: _password.text),
              ],
              const SizedBox(height: 14),
              AppTextField(
                  label: 'Confirm Password',
                  controller: _confirm,
                  obscureText: true,
                  errorText: _confirmError,
                  prefixIcon: Icons.lock_outline),
              const SizedBox(height: 22),
              PrimaryButton(
                  label: 'Create Account',
                  loading: _loading,
                  onPressed: _submit),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already registered? ',
                      style: TextStyle(color: context.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Sign In',
                        style: TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown after successful registration. Auto-redirects to Sign In after 2.5s,
/// or user can tap "Continue".
class _SignUpSuccessScreen extends StatefulWidget {
  final String email;
  const _SignUpSuccessScreen({required this.email});

  @override
  State<_SignUpSuccessScreen> createState() => _SignUpSuccessScreenState();
}

class _SignUpSuccessScreenState extends State<_SignUpSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) _goToSignIn();
    });
  }

  void _goToSignIn() {
    // Stash the welcome banner on the AuthProvider so the Sign In screen
    // (rendered by _AuthGate) can read it on its next build, then pop all
    // routes back to root. This keeps _AuthGate in the navigator stack so
    // login can correctly trigger MainShell.
    context.read<AuthProvider>().setPostSignupBanner(
          message: 'Sign Up Completed! Please sign in to continue.',
          email: widget.email,
        );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: AppColors.successGreen, size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                'Sign Up Completed',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Your account has been created successfully.\nRedirecting you to Sign In…',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Continue to Sign In',
                icon: Icons.arrow_forward,
                onPressed: _goToSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
