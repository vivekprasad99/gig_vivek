import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../../core/data/local/repository/logging_event/helper/logging_section_names.dart';

void showMaxBeneficiaryBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return const MaxBeneficiaryBottomSheetWidget();
    },
  );
}

class MaxBeneficiaryBottomSheetWidget extends StatefulWidget {
  const MaxBeneficiaryBottomSheetWidget({Key? key}) : super(key: key);

  @override
  State<MaxBeneficiaryBottomSheetWidget> createState() =>
      _MaxBeneficiaryBottomSheetWidgetState();
}

class _MaxBeneficiaryBottomSheetWidgetState
    extends State<MaxBeneficiaryBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    LoggingData loggingData = LoggingData(
        event: LoggingEvents.maximumAccountReached,
        action: LoggingActions.clicked,
        pageName: LoggingPageNames.earnings,
        sectionName: LoggingSectionNames.manageBeneficiaries);
    CaptureEventHelper.captureEvent(loggingData: loggingData);

    return DraggableScrollableSheet(
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.radius_16),
              topRight: Radius.circular(Dimens.radius_16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'maximum_account_reached'.tr,
                      textAlign: TextAlign.center,
                      style: Get.textTheme.headline7Bold,
                    ),
                    buildCloseIcon(),
                  ],
                ),
              ),
              buildSubTitle(),
            ],
          ),
        );
      },
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: const Icon(Icons.close),
      ),
    );
  }

  Widget buildSubTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
      child: RichText(
        text: TextSpan(
          style: context.textTheme.bodyText1,
          children: <TextSpan>[
            TextSpan(
              text: 'maximum_5_accounts_have_been_reached'.tr,
            ),
            TextSpan(
              text: 'contact_customer_support'.tr,
              style: context.textTheme.bodyText1
                  ?.copyWith(color: AppColors.link300),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  MRouter.pushNamed(MRouter.faqAndSupportWidget);
                },
            ),
            TextSpan(
              text: 'for_further_assistance'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
