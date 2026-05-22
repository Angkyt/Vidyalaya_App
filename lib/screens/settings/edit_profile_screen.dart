import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _studentId;

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _avatarPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().user;
    _firstName = TextEditingController(text: u?.firstName ?? '');
    _lastName = TextEditingController(text: u?.lastName ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
    _studentId = TextEditingController(text: u?.studentId ?? '');
    _avatarPath = u?.avatarPath;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _studentId.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Library'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (_avatarPath != null && _avatarPath!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: AppColors.errorRed),
                title: const Text('Remove photo',
                    style: TextStyle(color: AppColors.errorRed)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _avatarPath = '');
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      // Copy to app documents dir so it persists
      final docs = await getApplicationDocumentsDirectory();
      final filename =
          'avatar_${DateTime.now().millisecondsSinceEpoch}${_ext(picked.path)}';
      final destPath = '${docs.path}/$filename';
      await File(picked.path).copy(destPath);
      if (!mounted) return;
      setState(() => _avatarPath = destPath);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e')),
      );
    }
  }

  String _ext(String path) {
    final i = path.lastIndexOf('.');
    if (i < 0) return '.jpg';
    return path.substring(i);
  }

  Future<void> _save() async {
    setState(() {
      _firstNameError =
          _firstName.text.trim().isEmpty ? 'First name is required' : null;
      _lastNameError =
          _lastName.text.trim().isEmpty ? 'Last name is required' : null;
      _emailError = _email.text.trim().isEmpty
          ? 'Email is required'
          : !RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(_email.text.trim())
              ? 'Enter a valid email'
              : null;
      _phoneError = _phone.text.trim().isEmpty
          ? 'Phone number is required'
          : !AuthService.isValidPhone(_phone.text)
              ? 'Enter at least 7 digits'
              : null;
    });
    if (_firstNameError != null ||
        _lastNameError != null ||
        _emailError != null ||
        _phoneError != null) return;

    setState(() => _saving = true);
    final ok = await context.read<AuthProvider>().updateProfile(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          avatarPath: _avatarPath ?? '',
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
          backgroundColor: AppColors.successGreen,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update profile. Please try again.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = context.watch<AuthProvider>().user?.initials ?? '?';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(showBack: true),
              const SizedBox(height: 18),
              const PageTitle('Edit Profile'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          ProfileAvatar(
                            initials: initials,
                            imagePath: _avatarPath,
                            size: 100,
                            showEditBadge: true,
                            onTap: _pickImage,
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            icon: const Icon(Icons.camera_alt_outlined,
                                size: 16),
                            label: const Text('Change photo'),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.teal),
                            onPressed: _pickImage,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'First Name',
                            controller: _firstName,
                            errorText: _firstNameError,
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppTextField(
                            label: 'Last Name',
                            controller: _lastName,
                            errorText: _lastNameError,
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Email',
                      controller: _email,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Phone',
                      controller: _phone,
                      errorText: _phoneError,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Student ID',
                      controller: _studentId,
                      prefixIcon: Icons.badge_outlined,
                      readOnly: true,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 12, color: context.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Student ID is fixed and cannot be changed.',
                            style: TextStyle(
                                fontSize: 11,
                                color: context.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                label: 'Save Changes',
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
