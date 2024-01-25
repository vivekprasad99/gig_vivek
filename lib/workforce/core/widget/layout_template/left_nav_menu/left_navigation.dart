import 'package:awign/workforce/core/data/model/navigation_item.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/layout_template/left_nav_menu/cubit/left_navigation_cubit.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class LeftNavigation extends StatelessWidget {
  static List<String?> get possibleRoutes =>
      _navigationItems.map((e) => e.navigateTo).toList();

  /*static Direction getDirectionBetween(
      String routeNameFrom, String routeNameTo) {
    final itemNames = _navigationItems.map((item) => item.navigateTo).toList();

    final indexFrom = itemNames.indexOf(routeNameFrom);
    final indexTo = itemNames.indexOf(routeNameTo);

    if (indexFrom == -1 || indexTo == -1) return Direction.LEFT;

    return indexTo > indexFrom ? Direction.RIGHT : Direction.LEFT;
  }*/

  static List<NavigationItem> get _navigationItems => [
        /*NavigationItem(
          iconUrl: 'assets/images/home_active.png',
          navigateTo: Mrouter.superAdminDashboardRoute,
          text: 'Dashboard',
        ),
        NavigationItem(
          iconUrl: 'assets/images/home_active.png',
          navigateTo: Mrouter.shopManagementRoute,
          text: 'Shop Management',
        ),
        NavigationItem(
          iconUrl: 'assets/images/home_active.png',
          navigateTo: Mrouter.adminLoginRoute,
          text: 'Logout',
        ),*/
      ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<LeftNavigationCubit>(),
      child: StreamBuilder<bool>(
          stream: sl<LeftNavigationCubit>().isLeftNavigationVisible,
          builder: (context, isLeftNavigationVisible) {
            if (isLeftNavigationVisible.hasData &&
                isLeftNavigationVisible.data!) {
              return Container(
                width: 250,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceDark,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.backgroundGrey200,
                      offset: Offset(3, 5),
                      blurRadius: Dimens.radius_16,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NavBarLogo(),
                    Expanded(
                      child: ListView(
                        children: [
                          for (final item in _navigationItems)
                            LeftNavBarMenu(item)
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (isLeftNavigationVisible.hasData &&
                !isLeftNavigationVisible.data!) {
              return SizedBox();
            } else {
              return SizedBox();
            }
          }),
    );
  }
}

class NavBarLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.padding_16),
      child: SizedBox(
        height: 50,
        width: 100,
        child: Image.asset(
          "assets/images/logo.png",
        ),
      ),
    );
  }
}

class LeftNavBarMenu extends StatelessWidget {
  final NavigationItem item;

  LeftNavBarMenu(this.item);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeftNavigationCubit, String>(
      builder: (context, state) {
        final selected = state == item.navigateTo;
        //final color = selected ? AppColors.secondary : AppColors.coolGray3;
        final color = selected
            ? AppColors.secondary
            : Get.isDarkMode
                ? AppColors.backgroundGrey200
                : AppColors.backgroundGrey200;
        Widget icon;
        if (item.iconUrl != null && item.iconUrl!.isNotEmpty) {
          icon = Image.asset(
            item.iconUrl!,
            width: 25,
            height: 25,
            color: color,
          );
        } else {
          icon = SizedBox();
        }
        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.all(Dimens.padding_8),
            child: Material(
              //elevation: 10,
              color: AppColors.transparent,
              child: MyInkWell(
                onTap: () {
                  if (selected != null) {
                    /*MRouter.pushReplacementNamed(item.navigateTo!,
                        isLocal: item.navigateTo! == MRouter.adminLoginRoute
                            ? false
                            : true);*/
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(Dimens.padding_8),
                  child: Row(
                    children: [
                      Container(
                        width: 24.0,
                        height: 24.0,
                        padding: EdgeInsets.all(Dimens.padding_8),
                        child: icon,
                      ),
                      SizedBox(width: Dimens.padding_8),
                      Text(
                        item.text ?? "",
                        style:
                            context.textTheme.headline5?.copyWith(color: color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
