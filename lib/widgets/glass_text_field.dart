import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';

class GlassTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffix;
  final Widget? prefix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool enabled;
  final TextInputAction? textInputAction;

  const GlassTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.suffix,
    this.prefix,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.enabled = true,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTheme.labelMedium,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          enabled: enabled,
          textInputAction: textInputAction,
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontSize: 14,
          ),
          cursorColor: AppTheme.accent,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            prefixIcon: prefix,
            filled: true,
            fillColor: AppTheme.gmBg,
            hintStyle: GoogleFonts.inter(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.controlRadius),
              borderSide: BorderSide(color: AppTheme.gmBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.controlRadius),
              borderSide: BorderSide(color: AppTheme.gmBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.controlRadius),
              borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.controlRadius),
              borderSide: const BorderSide(color: AppTheme.error),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.controlRadius),
              borderSide: BorderSide(color: AppTheme.gmBorder.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }
}
