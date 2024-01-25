import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showThanksForSubmittingBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.3,
        maxChildSize: 0.3,
        builder: (_, controller) {
          return const ThanksForSubmittingWidget();
        },
      );
    },
  );
}

class ThanksForSubmittingWidget extends StatelessWidget {
  const ThanksForSubmittingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: Column(
        children: [
          buildCloseIcon(),
          const SizedBox(height: Dimens.margin_16),
          buildLottieIcon(),
          const SizedBox(height: Dimens.margin_16),
          buildTitleText(),
          const SizedBox(height: Dimens.padding_8),
          buildDescriptionText(),
          const SizedBox(height: Dimens.margin_32),
        ],
      ),
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
          child: SvgPicture.asset('assets/images/ic_close_circle.svg'),
        ),
      ),
    );
  }

  Widget buildLottieIcon() {
    // return Flexible(child: Lottie.network(Constants.submittingLottieURL));
    // return SvgPicture.asset('assets/images/ic_thanks_for_submitting.svg');
    return Image.asset(
      "assets/images/ic_thanks_for_submitting.png",
    );
  }

  Widget buildTitleText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text(
        'thanks_for_submitting'.tr,
        style: Get.textTheme.bodyText2SemiBold
            ?.copyWith(color: AppColors.backgroundBlack),
      ),
    );
  }

  Widget buildDescriptionText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text(
        'if_you_want_to_complete_your_profile'.tr,
        style:
            Get.textTheme.caption2.copyWith(color: AppColors.backgroundGrey800),
      ),
    );
  }
}
