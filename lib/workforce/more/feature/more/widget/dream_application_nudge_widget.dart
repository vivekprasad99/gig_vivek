import 'package:awign/workforce/auth/data/model/dream_application_completion_stage.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class DreamApplicationNudgeWidget extends StatelessWidget {
  final Widget bottomWidget;
  final UserData? currentUser;
  const DreamApplicationNudgeWidget(
      {required this.currentUser, required this.bottomWidget, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const SizedBox();
    } else if (currentUser?.userProfile?.dreamApplicationCompletionPercentage ==
            100 ||
        currentUser?.userProfile?.dreamApplicationCompletionStage ==
            DreamApplicationCompletionStage.completed) {
      return const SizedBox();
    } else {
      return Card(
        margin: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_8),
        ),
        child: Stack(
          children: [
            Positioned(
                top: 5,
                left: 35,
                right: 65,
                child: SvgPicture.asset('assets/images/ic_stars.svg')),
            Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_20, Dimens.padding_16, Dimens.padding_20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'dream_application'.tr,
                              style: Get.textTheme.bodyText1Bold
                                  ?.copyWith(color: AppColors.backgroundBlack),
                            ),
                            const SizedBox(height: Dimens.padding_8),
                            Text(
                              'let_us_know_your_professional_details_so_that_we_can_match'
                                  .tr,
                              style: Get.textTheme.caption?.copyWith(
                                  color: AppColors.backgroundGrey800),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Dimens.padding_16),
                      SvgPicture.asset(
                          'assets/images/ic_dream_application_nudge.svg'),
                    ],
                  ),
                  const SizedBox(height: Dimens.padding_16),
                  bottomWidget
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
