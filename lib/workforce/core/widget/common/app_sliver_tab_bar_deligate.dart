import 'package:flutter/material.dart';

class AppSliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  AppSliverTabBarDelegate({required this.tabBar, this.backgroundColor});

  TabBar tabBar;
  Color? backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(AppSliverTabBarDelegate oldDelegate) {
    return false;
  }
}
