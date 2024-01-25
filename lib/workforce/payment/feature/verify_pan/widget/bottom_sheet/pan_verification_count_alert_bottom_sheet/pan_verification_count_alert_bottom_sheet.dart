import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';
import '../../../../../../core/router/router.dart';
import '../../../../../data/model/pan_details_response.dart';

void showPANVerificationCountAlertBottomSheet(BuildContext context, PANDetailsResponse panDetailsResponse) {
  showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return PANVerificationCountAlertBottomSheet(panDetailsResponse);
      });
}

class PANVerificationCountAlertBottomSheet extends StatelessWidget {
  final PANDetailsResponse panDetailsResponse;
  const PANVerificationCountAlertBottomSheet(this.panDetailsResponse, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_32,
        Dimens.padding_16,
        Dimens.padding_16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimens.padding_8),
          buildTitle(context),
          const SizedBox(height: Dimens.padding_24),
          buildMessage(context),
          const SizedBox(height: Dimens.padding_24),
          buildBottomButtons(),
          const SizedBox(height: Dimens.padding_16),
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    String title = 'alert'.tr;
    if(panDetailsResponse.data?.panDetails?.thirdPartyVerifiedCount == 3) {
      title = 'too_many_attempts'.tr;
    }
    return Text(title,
        style: context.textTheme.bodyText1?.copyWith(
            color: AppColors.backgroundGrey800,
            fontWeight: FontWeight.w700,
            fontSize: Dimens.font_18));
  }

  Widget buildMessage(BuildContext context) {
    String message = sprintf('you_have_only_x_attempts_left_to_verify_the_pan'.tr,
        [3 - (panDetailsResponse.data?.panDetails?.thirdPartyVerifiedCount ?? 0)]);
    if(panDetailsResponse.data?.panDetails?.thirdPartyVerifiedCount == 3) {
      message = 'please_contact_support_to_get_your_pan_card_verified'.tr;
    }
    return Text(message,
        style: context.textTheme.bodyText1?.copyWith(
            color: AppColors.backgroundBlack,
            fontWeight: FontWeight.w400,
            fontSize: Dimens.font_14));
  }

  Widget buildBottomButtons() {
    return RaisedRectButton(
      text: 'okay'.tr.toTitleCase(),
      height: Dimens.btnHeight_40,
      backgroundColor: AppColors.primaryMain,
      onPressed: () {
        MRouter.pop(null);
      },
    );
  }
}
