import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final double? borderRadius;
  final int itemCount;

  const LoadingWidget({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.gmBg,
      highlightColor: AppTheme.gmHighlight.withOpacity(0.1),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: height ?? 80,
              width: width ?? double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.gmBg,
                borderRadius: BorderRadius.circular(
                  borderRadius ?? AppTheme.cardRadius,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                strokeWidth: 3,
              ),
            ),
          ),
      ],
    );
  }
}
