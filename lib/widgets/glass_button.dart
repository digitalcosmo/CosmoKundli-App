import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double? height;
  final Color? color;
  final IconData? icon;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppTheme.accent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width ?? double.infinity,
      height: height ?? 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
          child: Container(
            decoration: BoxDecoration(
              color: isOutlined ? Colors.transparent : buttonColor,
              borderRadius: BorderRadius.circular(AppTheme.controlRadius),
              border: Border.all(
                color: isOutlined ? buttonColor : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: isOutlined
                  ? null
                  : [
                      BoxShadow(
                        color: buttonColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOutlined ? buttonColor : Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: isOutlined ? buttonColor : Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isOutlined ? buttonColor : Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
