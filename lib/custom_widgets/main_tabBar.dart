import 'package:flutter/material.dart';

import '../ui/ck_theme.dart';
import '../ui/glass.dart';

/// Segmented liquid-glass tabs.
class MainTabBar extends StatelessWidget {
  final List<TabItem> tabItems;
  final TabController? controller;

  const MainTabBar(
      {super.key, required this.tabItems, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
          child: Glass(
            radius: CkRadius.pill,
            padding: const EdgeInsets.all(4),
            shadow: false,
            child: TabBar(
              controller: controller,
              isScrollable: tabItems.length > 3,
              tabAlignment:
                  tabItems.length > 3 ? TabAlignment.start : TabAlignment.fill,
              dividerHeight: 0,
              splashBorderRadius: BorderRadius.circular(CkRadius.pill),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(CkRadius.pill),
                gradient: CkColors.cta,
                boxShadow: const [
                  BoxShadow(color: Color(0x44F56720), blurRadius: 12),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: CkColors.textSecondary,
              labelStyle:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
              labelPadding: const EdgeInsets.symmetric(horizontal: 14),
              onTap: (index) => controller?.animateTo(index),
              tabs: tabItems
                  .map((tab) => Tab(height: 38, text: tab.text))
                  .toList(),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            children: tabItems.map((tab) => tab.content).toList(),
          ),
        ),
      ],
    );
  }
}

class TabItem {
  final String text;
  final Widget content;

  TabItem({required this.text, required this.content});
}
