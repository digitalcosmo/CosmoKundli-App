import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';

class GlassDropdown<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final String? label;
  final String? Function(T?)? validator;

  const GlassDropdown({
    super.key,
    required this.items,
    this.selectedValue,
    this.onChanged,
    this.hint,
    this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTheme.labelMedium),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppTheme.gmBg,
            borderRadius: BorderRadius.circular(AppTheme.controlRadius),
            border: Border.all(color: AppTheme.gmBorder),
          ),
          child: DropdownButtonFormField<T>(
            value: selectedValue,
            items: items,
            onChanged: onChanged,
            validator: validator,
            dropdownColor: AppTheme.bgSecondary,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textMuted),
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
