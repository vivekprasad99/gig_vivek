import 'package:awign/workforce/core/config/permission/awign_permission_constants.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/data/work_listing_details_arguments.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApplicationHistoryTile extends StatelessWidget {
  final int index;
  final WorkApplicationEntity workApplication;
  final UserData? currentUser;
  final Function(int index, WorkApplicationEntity workApplication) onReApplyTap;

  const ApplicationHistoryTile(
      {Key? key,
      required this.index,
      required this.currentUser,
      required this.workApplication,
      required this.onReApplyTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(0, Dimens.margin_8, 0, Dimens.margin_16),
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.only(
                left: Dimens.margin_24, right: Dimens.margin_24, bottom: 0),
            elevation: Dimens.margin_4,
            shape: RoundedRectangleBorder(
                borderRadius: setDate(workApplication).isNullOrEmpty
                    ? BorderRadius.circular(Dimens.margin_16)
                    : const BorderRadius.only(
                        topLeft: Radius.circular(Dimens.margin_16),
                        topRight: Radius.circular(Dimens.margin_16))),
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.all(Radius.circular(Dimens.radius_12))),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: Dimens.margin_24),
                        width: Dimens.iconSize_28,
                        height: Dimens.iconSize_28,
                        child: Image.network(workApplication.icon ?? ''),
                      ),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.only(right: 10, top: 10),
                        decoration: const BoxDecoration(
                            color: AppColors.warning200,
                            borderRadius: BorderRadius.all(
                                Radius.circular(Dimens.radius_4))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(setStatus(workApplication),
                              textAlign: TextAlign.center),
                        ),
                      )
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: Dimens.margin_8, top: Dimens.margin_8),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        workApplication.workListingTitle ?? '',
                        style: Get.textTheme.bodyMedium?.copyWith(
                            color: AppColors.black,
                            fontSize: Dimens.font_16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  buildReApplyButton(),
                ],
              ),
            ),
          ),
          Visibility(
            visible: !setDate(workApplication).isNullOrEmpty,
            child: Container(
              padding: const EdgeInsets.only(
                  top: Dimens.margin_4,
                  bottom: Dimens.margin_4,
                  left: Dimens.margin_24),
              margin: const EdgeInsets.only(
                  left: Dimens.margin_24, right: Dimens.margin_24, bottom: 0),
              decoration: const BoxDecoration(
                  color: AppColors.backgroundGrey400,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(Dimens.margin_16),
                      bottomRight: Radius.circular(Dimens.margin_16))),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  setDate(workApplication) ?? '',
                  style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.backgroundGrey800,
                      fontSize: Dimens.font_12),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildReApplyButton() {
    bool visibility = false;
    if (setStatus(workApplication) != 'Rejected' &&
        (currentUser?.permissions?.awign
                ?.contains(AwignPermissionConstants.listings) ??
            false)) {
      visibility = true;
    }
    return Visibility(
      visible: visibility,
      child: Container(
        height: Dimens.margin_38,
        margin: const EdgeInsets.fromLTRB(Dimens.margin_4, Dimens.margin_24,
            Dimens.margin_4, Dimens.margin_4),
        child: RaisedRectButton(
          text: 'reapply'.tr,
          onPressed: () => {
            MRouter.pushNamed(MRouter.workListingDetailsWidget,
                arguments: WorkListingDetailsArguments(
                    workApplication.workListingId?.toString() ?? '-1',
                    fromRoute: MRouter.applicationHistoryWidget)),
          },
        ),
      ),
    );
  }

  String setStatus(WorkApplicationEntity workApplication) {
    switch (workApplication.applicationStatus) {
      case ApplicationStatus.genericRejected:
        return "Rejected by Awign";
      case ApplicationStatus.executionCompleted:
        return "Execution Completed";
      case ApplicationStatus.backedOut:
        return "Backed Out";
      case ApplicationStatus.created:
        return "Created";
      case ApplicationStatus.disqualified:
        return "Disqualified";
      default:
        return "Rejected";
    }
  }

  String? setDate(WorkApplicationEntity workApplication) {
    switch (workApplication.applicationStatus) {
      case ApplicationStatus.genericRejected:
        if (workApplication.rejectedAt != null) {
          return "Rejected On : ${workApplication.rejectedAt!.getFormattedDateTime(StringUtils.dateTimeFormatDMHMA)}";
        } else {
          return null;
        }

      case ApplicationStatus.executionCompleted:
        if (workApplication.executionCompletedAt != null) {
          return "Execution Completed On : ${workApplication.rejectedAt!.getFormattedDateTime(StringUtils.dateTimeFormatDMHMA)}";
        } else {
          return null;
        }

      case ApplicationStatus.backedOut:
        if (workApplication.backedOutAt != null) {
          return "Backed Out On : ${workApplication.backedOutAt!.getFormattedDateTime(StringUtils.dateTimeFormatDMHMA)}";
        } else {
          return null;
        }
      default:
        if (workApplication.archivedStatus == true) {
          return "Rejected On: ${workApplication.updatedAt!.getFormattedDateTime(StringUtils.dateTimeFormatDMHMA)}";
        } else {
          return null;
        }
    }
  }
}
