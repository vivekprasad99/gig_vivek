import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/leaderboard/data/model/leaderboard_widget_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBarTile extends StatelessWidget {
  final int index;
  final NavBarData navBarData;
  final Function(int index, NavBarData navBarData) onNavBarTapped;

  const NavBarTile(
      {Key? key,
      required this.index,
      required this.navBarData,
      required this.onNavBarTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyInkWell(
      onTap: () {
        onNavBarTapped(index, navBarData);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16,
          Dimens.padding_8,
          Dimens.padding_16,
          Dimens.padding_8,
        ),
        margin: const EdgeInsets.symmetric(horizontal: Dimens.padding_4),
        decoration: BoxDecoration(
            color: navBarData.isSelected
                ? AppColors.backgroundGrey900
                : AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(Dimens.radius_32),
            border: Border.all(
              color: AppColors.backgroundGrey400,
              width: 2,
            )),
        child: Center(
          child: Text(
            navBarData.navBarItem!,
            style: Get.context?.textTheme.titleMedium?.copyWith(
                color: navBarData.isSelected
                    ? AppColors.backgroundWhite
                    : AppColors.backgroundGrey800,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
