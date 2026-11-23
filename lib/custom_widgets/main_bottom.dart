import 'package:flutter/material.dart';

import '../ui/ck_theme.dart';
import '../ui/glass.dart';

/// Floating liquid-glass dock with a sliding highlight.
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<NavItemData> items;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottom > 0 ? bottom : 14),
      child: Glass(
        radius: 30,
        blur: 22,
        tint: const Color(0x2E0E2F66),
        height: 68,
        padding: const EdgeInsets.all(6),
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth / items.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: CkMotion.slow,
                curve: Curves.easeOutBack,
                left: w * selectedIndex,
                top: 0,
                bottom: 0,
                width: w,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: CkColors.orangeTint,
                    border: Border.all(color: CkColors.orangeStroke),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x40F07E22),
                          blurRadius: 18,
                          spreadRadius: -4),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final sel = index == selectedIndex;
                  return Expanded(
                    child: Pressable(
                      scale: .9,
                      onTap: () => onItemTapped(index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            scale: sel ? 1.12 : 1,
                            duration: CkMotion.base,
                            curve: CkMotion.spring,
                            child: Image.asset(
                              item.icon,
                              height: 22,
                              color: sel ? CkColors.orangeSoft : CkColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: CkMotion.base,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              color: sel ? CkColors.text : CkColors.textMuted,
                            ),
                            child: Text(item.label,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class NavItemData {
  final String icon;
  final String label;

  NavItemData({required this.icon, required this.label});
}
