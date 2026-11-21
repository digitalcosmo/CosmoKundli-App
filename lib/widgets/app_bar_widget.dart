import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? leading;
  final double? elevation;
  final Widget? titleWidget;

  const GlassAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
    this.leading,
    this.elevation,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: AppTheme.bgPrimary.withOpacity(0.8),
          elevation: elevation ?? 0,
          leading: showBack
              ? (leading ??
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ))
              : leading,
          title: titleWidget ??
              Text(
                title,
                style: AppTheme.headingMedium,
              ),
          centerTitle: true,
          actions: actions,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
