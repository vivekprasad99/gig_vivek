import 'package:awign/workforce/auth/data/model/pan_details_entity.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/add_answer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_section_names.dart';
import '../../../../core/data/remote/capture_event/capture_event_helper.dart';
import '../../../../core/data/remote/capture_event/logging_data.dart';
import 'bottom_sheet/pan_details_bottom_sheet/pan_details_bottom_sheet.dart';

class AttachmentAnswerWidget extends StatelessWidget {
  final ScreenRow screenRow;
  final Function(ScreenRow screenRow) onAnswerAddOrUpdate;
  const AttachmentAnswerWidget(this.screenRow, this.onAnswerAddOrUpdate,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildAnsweredOrUnAnsweredWidget(context);
  }

  Widget buildAnsweredOrUnAnsweredWidget(BuildContext context) {
    if ((screenRow.question?.hasAnswered() ?? false)) {
      String? answerValue = screenRow.question?.answerUnit?.stringValue;
      DocumentDetailsData? documentDetailsData =
          screenRow.question?.answerUnit?.documentDetailsData;
      switch (screenRow.question!.uid) {
        case UID.resume:
          answerValue = 'added'.tr;
          break;
        case UID.panCard:
          if (documentDetailsData?.panDetails?.panStatus?.value != null) {
            answerValue = '${documentDetailsData!.panDetails!.panStatus!.value}'
                .toCapitalized();
          } else {
            answerValue = 'verified'.tr;
          }
          break;
        case UID.aadharCard:
          if (documentDetailsData?.aadharDetails?.aadharStatus?.value != null) {
            answerValue =
                '${documentDetailsData!.aadharDetails!.aadharStatus!.value}'
                    .toCapitalized();
          } else {
            answerValue = 'added'.tr;
          }
          break;
        case UID.drivingLicense:
          if (documentDetailsData
                  ?.drivingLicenceDetails?.drivingLicenceStatus?.value !=
              null) {
            answerValue =
                '${documentDetailsData!.drivingLicenceDetails!.drivingLicenceStatus!.value}'
                    .toCapitalized();
          } else {
            answerValue = 'added'.tr;
          }
          break;
      }
      return Expanded(
        child: MyInkWell(
          onTap: () {
            if (screenRow.question?.uid == UID.panCard ||
                screenRow.question?.uid == UID.aadharCard ||
                screenRow.question?.uid == UID.drivingLicense) {
              if (screenRow.question?.uid == UID.drivingLicense &&
                  screenRow.question?.answerUnit?.documentDetailsData
                          ?.drivingLicenceDetails?.drivingLicenceStatus ==
                      PanVerificationStatus.rejected) {
              } if (screenRow.question?.uid == UID.panCard) {
                LoggingData loggingData = LoggingData(
                    event: LoggingEvents.panView,
                    pageName: LoggingPageNames.panDetails,
                    sectionName: LoggingSectionNames.profileSection);
                CaptureEventHelper.captureEvent(loggingData: loggingData);
                showPANDetailsBottomSheet(context, screenRow.question?.answerUnit?.documentDetailsData);
                return;
              } else {
                return;
              }
            }
            if ((screenRow.question?.configuration?.isEditable ?? true)) {
              onAnswerAddOrUpdate(screenRow);
            }
          },
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answerValue ?? '',
                  style: Get.textTheme.bodyText2
                      ?.copyWith(color: AppColors.backgroundGrey900),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
              buildAddAnswerWidget(),
            ],
          ),
        ),
      );
    } else {
      return AddAnswerWidget(screenRow, onAnswerAddOrUpdate);
    }
  }

  Widget buildAddAnswerWidget() {
    if (screenRow.question?.uid == UID.panCard ||
        screenRow.question?.uid == UID.aadharCard ||
        screenRow.question?.uid == UID.drivingLicense) {
      if (screenRow.question?.uid == UID.drivingLicense &&
          screenRow.question?.answerUnit?.documentDetailsData
                  ?.drivingLicenceDetails?.drivingLicenceStatus ==
              PanVerificationStatus.rejected) {
        return AddAnswerWidget(screenRow, onAnswerAddOrUpdate, showText: false);
      } else {
        return const SizedBox();
      }
    } else {
      return AddAnswerWidget(screenRow, onAnswerAddOrUpdate, showText: false);
    }
  }
}
