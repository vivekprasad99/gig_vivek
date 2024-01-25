import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_event_helper.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../../../core/data/remote/capture_event/capture_event_helper.dart';
import '../../../../../../core/data/remote/capture_event/logging_data.dart';
import '../../../../../../core/router/router.dart';
import '../../../../../data/model/pan_details_response.dart';

void showConfirmPANNameBottomSheet(BuildContext context, PANDetailsResponse panDetailsResponse,
    {VoidCallback? onConfirmTap, VoidCallback? onWrongNameTap}) {
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
        return ConfirmPANNameBottomSheet(panDetailsResponse, onConfirmTap, onWrongNameTap);
      });
}

class ConfirmPANNameBottomSheet extends StatelessWidget {
  final VoidCallback? onConfirmTap;
  final VoidCallback? onWrongNameTap;
  final PANDetailsResponse panDetailsResponse;
  const ConfirmPANNameBottomSheet(this.panDetailsResponse, this.onConfirmTap, this.onWrongNameTap, {Key? key}) : super(key: key);

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
    String title = '';
    if(panDetailsResponse.status == PANDetailsResponse.success) {
      title = 'confirm_pan'.tr;
    } else if(panDetailsResponse.status == PANDetailsResponse.error && panDetailsResponse.statusCode == 422) {
      title = 'too_many_attempts'.tr;
      LoggingData loggingData = LoggingData(
          event: LoggingEvents.panVerificationThresholdCrossed,
          pageName: LoggingPageNames.panDetails,
          sectionName: '${LoggingSectionNames.profileSection}, ${LoggingSectionNames.withdrawalJourney}');
      CaptureEventHelper.captureEvent(loggingData: loggingData);
    } else if(panDetailsResponse.status == PANDetailsResponse.error && panDetailsResponse.statusCode == 409) {
      title = 'pan_already_exist'.tr;
    } else if(panDetailsResponse.status == PANDetailsResponse.error) {
      title = 'pan_does_not_exist'.tr;
    }
    return Text(title,
        style: context.textTheme.bodyText1?.copyWith(
            color: AppColors.backgroundGrey800,
            fontWeight: FontWeight.w700,
            fontSize: Dimens.font_18));
  }

  Widget buildMessage(BuildContext context) {
    String message = '';
    if(panDetailsResponse.status == PANDetailsResponse.error) {
      message = panDetailsResponse.message ?? '';
    } else if(panDetailsResponse.data?.panDetails?.name != panDetailsResponse.data?.panDetails?.panName) {
      message = '${'hello'.tr} ${panDetailsResponse.data?.panDetails?.panName}, ${'your_current_name'.tr} '
          '‘${panDetailsResponse.data?.panDetails?.name}’ ${'in_your_profile_section_will_get_updated_to'.tr} ‘${panDetailsResponse.data?.panDetails?.panName}’.';
    } else if(panDetailsResponse.data?.panDetails?.name == panDetailsResponse.data?.panDetails?.panName) {
      message = '${'hello'.tr} ${panDetailsResponse.data?.panDetails?.panName}, ${'your_current_name'.tr} '
          '‘${panDetailsResponse.data?.panDetails?.name}’ ${'please_confirm_if_we_have_identified_the_correct_name'.tr} ‘${panDetailsResponse.data?.panDetails?.panName}’';
    }
    return Text(message,
        style: context.textTheme.bodyText1?.copyWith(
            color: AppColors.backgroundBlack,
            fontWeight: FontWeight.w400,
            fontSize: Dimens.font_14));
  }

  Widget buildBottomButtons() {
    if(panDetailsResponse.status == PANDetailsResponse.success) {
      return Column(
        children: [
          RaisedRectButton(
            text: '${'i_confirm_i_am'.tr} ${panDetailsResponse.data?.panDetails?.panName ?? ''}',
            height: Dimens.btnHeight_40,
            backgroundColor: AppColors.primaryMain,
            onPressed: () {
              MRouter.pop(null);
              if(onConfirmTap != null) {
                LoggingData loggingData = LoggingData(
                    action: LoggingActions.iConfirmName,
                    pageName: LoggingPageNames.panDetails,
                    sectionName: '${LoggingSectionNames.profileSection}, ${LoggingSectionNames.withdrawalJourney}');
                CaptureEventHelper.captureEvent(loggingData: loggingData);
                onConfirmTap!();
              }
            },
          ),
          const SizedBox(height: Dimens.padding_8),
          RaisedRectButton(
            text: 'wrong_name_try_again'.tr,
            height: Dimens.btnHeight_40,
            backgroundColor: AppColors.transparent,
            borderColor: AppColors.transparent,
            textColor: AppColors.primaryMain,
            onPressed: () {
              LoggingData loggingData = LoggingData(
                  action: LoggingActions.wrongNameTryAgain,
                  pageName: LoggingPageNames.panDetails,
                  sectionName: '${LoggingSectionNames.profileSection}, ${LoggingSectionNames.withdrawalJourney}');
              CaptureEventHelper.captureEvent(loggingData: loggingData);
              MRouter.pop(null);
              if(onWrongNameTap != null) {
                onWrongNameTap!();
              }
            },
          ),
        ],
      );
    } else {
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
}
