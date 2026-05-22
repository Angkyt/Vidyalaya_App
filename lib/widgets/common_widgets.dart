import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'vidyalaya_logo.dart';

/// Top app header — always shows the Vidyalaya logo + wordmark.
/// Page titles render BELOW the header via [PageTitle].
///
/// IMPORTANT: header height stays constant whether or not the back/bell
/// icon is shown — IconButtons are size-constrained so they can't push
/// the header taller. This matches the compact look of the Wellbeing /
/// Dashboard / Settings tabs across every detail page.
class AppHeader extends StatelessWidget {
  final bool showBell;
  final VoidCallback? onBellTap;
  final bool showBack;
  const AppHeader({
    super.key,
    this.showBell = false,
    this.onBellTap,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          if (showBack)
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 18,
                onPressed: () => Navigator.maybePop(context),
              ),
            )
          else
            const SizedBox(width: 28),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const VidyalayaLogo(size: 24),
                  const SizedBox(width: 6),
                  Text(
                    'Vidyalaya',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (showBell)
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 18,
                onPressed: onBellTap,
              ),
            )
          else
            const SizedBox(width: 28),
        ],
      ),
    );
  }
}

/// Bold left-aligned page title shown below the [AppHeader].
/// Use this on detail/subpages for visual consistency with the
/// Courses ("All Courses") and Calendar ("Calendar") screens.
class PageTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const PageTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.isDark ? AppColors.teal : AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              (context.isDark ? AppColors.teal : AppColors.primary)
                  .withOpacity(0.6),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

class TealButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const TealButton(
      {super.key, required this.label, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

class OutlinedTealButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  const OutlinedTealButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingIcon = Icons.arrow_forward,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.tealLight.withOpacity(0.35),
          side: const BorderSide(color: AppColors.teal),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color:
                    context.isDark ? AppColors.tealLight : AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon,
                  size: 18,
                  color:
                      context.isDark ? AppColors.tealLight : AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final int? maxLines;
  final bool enabled;
  /// Show a small lock icon on the right when the field is locked.
  final bool readOnly;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.errorText,
    this.onChanged,
    this.prefixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          style: TextStyle(
            color: widget.readOnly ? context.textSecondary : context.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: context.textHint, fontSize: 14),
            filled: true,
            fillColor: context.inputColor,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: 18, color: context.textHint),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: context.textHint,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : (widget.readOnly
                    ? Icon(Icons.lock_outline,
                        size: 16, color: context.textHint)
                    : null),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColors.errorRed : Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColors.errorRed : Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColors.errorRed : AppColors.teal,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  size: 14, color: AppColors.errorRed),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: const TextStyle(
                      color: AppColors.errorRed, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? context.cardColor,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? activeColor;
  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final ac = activeColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? ac : context.cardColor,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: selected ? ac : context.borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : context.textPrimary,
          ),
        ),
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const items = [
    (Icons.dashboard_rounded, 'Dashboard'),
    (Icons.menu_book_rounded, 'Courses'),
    (Icons.calendar_today_rounded, 'Calendar'),
    (Icons.favorite_rounded, 'Wellbeing'),
    (Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: context.bgColor,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: selected
                        ? (context.isDark ? AppColors.teal : AppColors.primary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].$1,
                        size: 20,
                        color: selected ? Colors.white : context.textSecondary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].$2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color:
                              selected ? Colors.white : context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class CourseColors {
  static const palette = [
    AppColors.teal,
    AppColors.dotYellow,
    AppColors.dotBlue,
    Color(0xFFE76F51),
    Color(0xFF8E44AD),
    Color(0xFF16A085),
  ];
  static Color of(int i) => palette[i % palette.length];
}

/// A live indicator of which password rules are met / unmet.
class PasswordRulesIndicator extends StatelessWidget {
  final String password;
  const PasswordRulesIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final rules = <(String, bool)>[
      ('At least 8 characters', password.length >= 8),
      ('One uppercase letter', password.contains(RegExp(r'[A-Z]'))),
      ('One number', password.contains(RegExp(r'\d'))),
      (
        'One special character',
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/`~;]'))
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rules.map((r) {
          final met = r.$2;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  met ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 14,
                  color: met ? AppColors.successGreen : context.textHint,
                ),
                const SizedBox(width: 6),
                Text(
                  r.$1,
                  style: TextStyle(
                    fontSize: 12,
                    color: met ? context.textPrimary : context.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Round avatar (uses image if path provided, otherwise initials).
class ProfileAvatar extends StatelessWidget {
  final String? imagePath;
  final String initials;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;
  const ProfileAvatar({
    super.key,
    required this.initials,
    this.imagePath,
    this.size = 80,
    this.onTap,
    this.showEditBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    final inner = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.teal,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ClipOval(
        child: hasImage
            ? Image(
                image: _imageProvider(imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsBg(),
              )
            : _initialsBg(),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          inner,
          if (showEditBadge)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt,
                    color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _initialsBg() {
    return Container(
      color: AppColors.teal,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
        ),
      ),
    );
  }

  ImageProvider _imageProvider(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    return FileImage(File(path));
  }
}
