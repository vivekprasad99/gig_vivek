import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/cupertino.dart';

class SlideDots extends StatelessWidget {
  final bool isActive;

  const SlideDots(this.isActive, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: Dimens.margin_4),
      height: isActive ? Dimens.margin_4 : Dimens.margin_4,
      width: isActive ? Dimens.margin_28 : Dimens.margin_28,
      decoration: BoxDecoration(
          color: isActive ? AppColors.backgroundGrey900 : AppColors.backgroundGrey500,
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_12))),
    );
  }
}
