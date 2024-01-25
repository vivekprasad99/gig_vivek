import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ComeBackLateWidget extends StatelessWidget {
  const ComeBackLateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: Dimens.btnWidth_100,
        ),
        buildComeBackImage(),
        const SizedBox(
          height: Dimens.padding_24,
        ),
        buildComeBackLaterText(),
        const SizedBox(
          height: Dimens.padding_8,
        ),
        buildLeaderboardText(),
        const SizedBox(
          height: Dimens.padding_24,
        ),
        buildGoTOofficeButton(),
      ],
    );
  }

  Widget buildComeBackImage() {
    return CircleAvatar(
        radius: Dimens.btnWidth_100,
        backgroundColor: AppColors.backgroundWhite,
        child: Stack(
          children: [
            Image.asset('assets/images/come_back_later.png'),
            Positioned(
                right: -40,
                top: 0,
                child: Image.asset(
                  'assets/images/confetti_colorful.png',
                ))
          ],
        ));
  }

  Widget buildComeBackLaterText() {
    return Text(
      'come_back_later'.tr,
      style: Get.context?.textTheme.titleMedium?.copyWith(
          color: AppColors.backgroundBlack,
          fontSize: Dimens.font_16,
          fontWeight: FontWeight.w600),
    );
  }

  Widget buildLeaderboardText() {
    return Text(
      'leaderboard_will_start'.tr,
      textAlign: TextAlign.center,
      style: Get.context?.textTheme.titleMedium?.copyWith(
          color: AppColors.backgroundGrey800,
          fontSize: Dimens.font_14,
          fontWeight: FontWeight.w400),
    );
  }

  Widget buildGoTOofficeButton() {
    return RaisedRectButton(
      text: 'go_to_office'.tr,
      onPressed: () {
        MRouter.pushNamedAndRemoveUntil(MRouter.officeWidget);
      },
      width: Dimens.padding_200,
    );
  }
}
