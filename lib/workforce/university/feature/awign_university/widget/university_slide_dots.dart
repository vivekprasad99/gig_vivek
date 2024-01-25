import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class UniversitySlideDots extends StatelessWidget {
  final bool isActive;
  const UniversitySlideDots(this.isActive,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin:  const EdgeInsets.symmetric(horizontal: Dimens.margin_4),
      height: isActive ? Dimens.margin_8 : Dimens.margin_8,
      width: isActive ? Dimens.margin_8 : Dimens.margin_8,
      decoration: BoxDecoration(
          color: isActive ? AppColors.backgroundWhite : AppColors.secondary2200,
          borderRadius:
          const BorderRadius.all(Radius.circular(Dimens.radius_12))),
    );
  }
}
