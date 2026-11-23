import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../ui/ck_theme.dart';
import '../ui/glass.dart';

class MainButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final bool isItalic;
  final double radius;
  final double width;
  final bool isLoading;

  const MainButton(
      {super.key,
      required this.text,
      this.onTap,
      this.isItalic = false,
      this.radius = 18,
      this.width = 80,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        width: width.w,
        decoration: BoxDecoration(
          gradient: CkColors.cta,
          borderRadius: BorderRadius.circular(CkRadius.control),
          border: Border.all(color: const Color(0x66FFFFFF)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x55F56720), blurRadius: 22, offset: Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            // specular sheen
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 24,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(CkRadius.control)),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x40FFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
            Center(
              child: AnimatedSwitcher(
                duration: CkMotion.base,
                child: isLoading
                    ? const SizedBox(
                        key: ValueKey('l'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.4),
                      )
                    : Text(
                        text,
                        key: const ValueKey('t'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .3,
                              fontStyle:
                                  isItalic ? FontStyle.italic : FontStyle.normal,
                            ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
