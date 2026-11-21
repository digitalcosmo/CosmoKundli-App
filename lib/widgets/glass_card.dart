import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Color? color;
  final double? width;
  final double? height;
  final bool enableBlur;

  const GlassCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.color,
    this.width,
    this.height,
    this.enableBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.cardRadius),
      child: BackdropFilter(
        filter: enableBlur
            ? ImageFilter.blur(sigmaX: AppTheme.gmBlur, sigmaY: AppTheme.gmBlur)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          margin: margin,
          decoration: BoxDecoration(
            color: color ?? AppTheme.gmBg,
            borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.cardRadius),
            border: Border.all(color: AppTheme.gmBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}
