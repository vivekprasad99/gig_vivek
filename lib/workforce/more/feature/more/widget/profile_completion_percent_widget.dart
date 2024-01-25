import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileCompletionPercentWidget extends StatelessWidget {
  final UserData currentUser;
  final bool? isBottomSheet;
  const ProfileCompletionPercentWidget(this.currentUser,{Key? key,this.isBottomSheet = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percent = 0;
    if (currentUser.userProfile?.dreamApplicationCompletionPercentage != null) {
      percent =
          ((currentUser.userProfile?.dreamApplicationCompletionPercentage! ??
                  0) /
              100);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: isBottomSheet! ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          children: [
            Visibility(
              visible: isBottomSheet!,
              child: Text(
                'my_application'.tr,
                style: Get.textTheme.caption2Medium
                    .copyWith(color: AppColors.backgroundGrey800),
              ),
            ),
            Text(
              '${currentUser.userProfile?.dreamApplicationCompletionPercentage} ${'complete_with_percent'.tr}',
              style: Get.textTheme.caption2Medium
                  .copyWith(color: AppColors.backgroundBlack),
            ),
          ],
        ),
        const SizedBox(height: Dimens.padding_6),
        LinearProgressIndicator(
          value: percent,
          color: AppColors.success400,
          backgroundColor: AppColors.backgroundGrey300,
          minHeight: Dimens.linearProgressIndicatorHeight4,
        ),
      ],
    );
  }
}
