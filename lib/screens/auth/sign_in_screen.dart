import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  /// If non-null, shown as a one-shot success banner above the form.
  final String? welcomeMessage;
  /// If provided, prefills the email field (used after sign up).
  final String? prefillEmail;

  const SignInScreen({super.key, this.welcomeMessage, this.prefillEmail});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final TextEditingController _email;
  final _password = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _bannerMsg;
  AuthError? _bannerKind;
  String? _successBanner;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Read the post-signup banner stashed by SignUpScreen on AuthProvider,
    // then immediately consume it so it doesn't reappear on later rebuilds.
    final auth = context.read<AuthProvider>();
    final stashedEmail = auth.postSignupEmail;
    final stashedMessage = auth.postSignupMessage;
    _email = TextEditingController(
        text: widget.prefillEmail ?? stashedEmail ?? '');
    _successBanner = widget.welcomeMessage ?? stashedMessage;
    if (stashedMessage != null) auth.consumePostSignupBanner();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _validateLocally() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _bannerMsg = null;
      _bannerKind = null;
      _successBanner = null;
    });
    bool ok = true;
    if (_email.text.trim().isEmpty) {
      setState(() => _emailError = 'Email is required');
      ok = false;
    } else if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(_email.text.trim())) {
      setState(() => _emailError = 'Enter a valid email');
      ok = false;
    }
    if (_password.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      ok = false;
    }
    return ok;
  }

  Future<void> _login() async {
    if (!_validateLocally()) return;
    setState(() => _loading = true);
    final res = await context.read<AuthProvider>().login(
          _email.text.trim(),
          _password.text,
        );
    if (!mounted) return;

    if (!res.success) {
      setState(() {
        _loading = false;
        _bannerMsg = res.error!.message;
        _bannerKind = res.error;
        if (res.error == AuthError.incorrectPassword) {
          _passwordError = 'Incorrect password';
        }
        if (res.error == AuthError.emailNotFound) {
          _emailError = 'No account found';
        }
      });
      return;
    }
    // On success, _AuthGate (in main.dart) is still the root route and is
    // watching AuthProvider, so it will rebuild and return MainShell in
    // place of this SignInScreen. We only need to reset our loading flag.
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(),
              const SizedBox(height: 28),
              Text('Welcome back',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text(
                'Sign in to manage classes and tasks',
                style: TextStyle(color: context.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 28),
              if (_successBanner != null) ...[
                _SuccessBanner(
                  message: _successBanner!,
                  onDismiss: () => setState(() => _successBanner = null),
                ),
                const SizedBox(height: 14),
              ],
              if (_bannerMsg != null) ...[
                _ErrorBanner(
                  message: _bannerMsg!,
                  showSignUp: _bannerKind == AuthError.emailNotFound,
                  onSignUp: _goSignUp,
                ),
                const SizedBox(height: 14),
              ],
              AppTextField(
                label: 'Email',
                hint: 'Enter your email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _password,
                obscureText: true,
                errorText: _passwordError,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPassword,
                  child: const Text('Forgot Password?',
                      style: TextStyle(color: AppColors.teal)),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                  label: 'Login', loading: _loading, onPressed: _login),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                      style: TextStyle(color: context.textSecondary)),
                  GestureDetector(
                    onTap: _goSignUp,
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                          color: AppColors.teal, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  void _showForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Forgot Password?'),
        content: const Text(
          'This is an offline app, so password recovery requires creating a new account or contacting support. '
          'In a production version with a backend, a reset link would be sent to your email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool showSignUp;
  final VoidCallback? onSignUp;
  const _ErrorBanner({
    required this.message,
    this.showSignUp = false,
    this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline,
              color: AppColors.errorRed, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                      color: AppColors.errorRed, fontSize: 13),
                ),
                if (showSignUp) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onSignUp,
                    child: const Text(
                      'Create a new account →',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _SuccessBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.successGreen, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppColors.successGreen, fontSize: 13)),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close,
                size: 16, color: AppColors.successGreen),
          ),
        ],
      ),
    );
  }
}
