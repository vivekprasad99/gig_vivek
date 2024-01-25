import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/circle_avatar/custom_circle_avatar.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExecutionTile extends StatelessWidget {
  final int index;
  final Execution execution;
  final Function(int index, Execution execution, String projectRole)
      onViewExecutionTap;

  const ExecutionTile(
      {Key? key,
      required this.index,
      required this.execution,
      required this.onViewExecutionTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Card(
        color: (execution.archivedStatus == true)
            ? AppColors.backgroundGrey300
            : AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_16),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildIcon(),
                  buildMark(),
                ],
              ),
              buildProjectName(),
              buildProjectDescription(),
              buildProjectRoleList(),
              buildWorkStartDate(),
              buildBottomButton(),
              buildOrganizationTag(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIcon() {
    if (execution.projectIcon != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
        child: CustomCircleAvatar(
            url: execution.projectIcon, radius: Dimens.radius_20),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildMark() {
    Widget markWidget = const SizedBox();
    if (execution.archivedStatus == true) {
      markWidget = buildMarkAndText('closed'.tr, AppColors.backgroundGrey600);
    } else {
      switch (execution.status) {
        case ExecutionStatus.approved:
          break;
        case ExecutionStatus.started:
          if ((execution.leadAllotmentType ==
                      ExecutionLeadAllotmentType.provided &&
                  execution.leadAssignedStatus == null) ||
              (execution.leadAllotmentType == null &&
                  execution.leadAssignedStatus == null)) {
            markWidget = buildMarkAndText('wait_listed'.tr, AppColors.yellow);
          } else if ((execution.leadAllotmentType ==
                      ExecutionLeadAllotmentType.selfCreated &&
                  execution.leadAssignedStatus == null) ||
              (execution.leadAssignedStatus ==
                  ExecutionLeadAssignedStatus.firstLeadAssigned)) {
            markWidget = buildMarkAndText('active'.tr, AppColors.success300);
          } else {
            markWidget = const SizedBox();
          }
          break;
        case ExecutionStatus.added:
          markWidget = buildMarkAndText('active'.tr, AppColors.success300);
          break;
        case ExecutionStatus.durationExtended:
        case ExecutionStatus.halted:
          markWidget = buildMarkAndText('on_hold'.tr, AppColors.orange);
          break;
        case ExecutionStatus.certificateIssued:
        case ExecutionStatus.certificateRequested:
        case ExecutionStatus.backedOut:
        case ExecutionStatus.completed:
        case ExecutionStatus.submitted:
          markWidget = buildMarkAndText('completed'.tr, AppColors.link200);
          break;
        case ExecutionStatus.blacklisted:
        case ExecutionStatus.disqualified:
        case ExecutionStatus.rejected:
          markWidget = buildMarkAndText('disqualified'.tr, AppColors.error400);
          break;
      }
    }
    return markWidget;
  }

  Widget buildMarkAndText(String text, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(right: Dimens.padding_16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_16)),
          border: Border.all(
            color: AppColors.backgroundGrey400,
            width: Dimens.border_1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: Dimens.margin_4),
                height: Dimens.margin_8,
                width: Dimens.margin_8,
                decoration: BoxDecoration(
                    color: dotColor,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(Dimens.radius_12))),
              ),
              Text(text, style: Get.textTheme.bodyText2),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProjectName() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Text(
        execution.projectName ?? '',
        style: Get.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget buildProjectDescription() {
    if (execution.description != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
        child: Text(
          execution.description ?? '',
          style: Get.textTheme.bodyText2
              ?.copyWith(color: AppColors.backgroundGrey800),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildProjectRoleList() {
    if (execution.projectRoles != null) {
      if (execution.projectRoles!.length > 1) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'View As:',
                style: Get.textTheme.bodyText2SemiBold
                    ?.copyWith(color: AppColors.backgroundGrey900),
              ),
              const SizedBox(height: Dimens.padding_8),
              ListView.separated(
                itemCount: execution.projectRoles!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: Dimens.padding_8),
                itemBuilder: (context, index) {
                  return buildProjectRoleTile(execution.projectRoles![index]);
                },
                separatorBuilder: (context, index) {
                  return HDivider(dividerColor: AppColors.backgroundGrey400);
                },
              )
            ],
          ),
        );
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }

  Widget buildProjectRoleTile(String projectRole) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.padding_8),
      child: MyInkWell(
        onTap: () {
          onViewExecutionTap(index, execution, projectRole);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                projectRole,
                style: Get.textTheme.bodyText2Medium
                    ?.copyWith(color: AppColors.primaryMain),
              ),
            ),
            buildWorkStartDateAccordingToProjectRole(projectRole),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.backgroundGrey700, size: Dimens.iconSize_16),
          ],
        ),
      ),
    );
  }

  Widget buildWorkStartDateAccordingToProjectRole(String projectRole) {
    RequestWorkCardDetails requestWorkCardDetails =
        execution.getRequestWorkCardDetails(projectRole);
    if (requestWorkCardDetails.dateTitle != null &&
        requestWorkCardDetails.date != null) {
      return Expanded(
        child: Text(
          requestWorkCardDetails.date ?? '',
          style: Get.textTheme.bodyText2
              ?.copyWith(color: AppColors.backgroundBlack),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildWorkStartDate() {
    if (execution.projectRoles != null && execution.projectRoles!.length == 1) {
      RequestWorkCardDetails requestWorkCardDetails =
          execution.getRequestWorkCardDetails(execution.projectRoles?[0]);
      if (requestWorkCardDetails.dateTitle != null &&
          requestWorkCardDetails.date != null) {
        return Container(
          margin: const EdgeInsets.fromLTRB(
              Dimens.margin_8, Dimens.margin_8, Dimens.margin_8, 0),
          padding: const EdgeInsets.all(Dimens.padding_8),
          decoration: const BoxDecoration(
            color: AppColors.warning100,
            borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_4)),
          ),
          child: Row(
            children: [
              Text(
                requestWorkCardDetails.dateTitle ?? '',
                style: Get.textTheme.bodyText2Medium
                    ?.copyWith(color: AppColors.backgroundBlack),
              ),
              Text(
                requestWorkCardDetails.date ?? '',
                style: Get.textTheme.bodyText2SemiBold
                    ?.copyWith(color: AppColors.warning300),
              ),
            ],
          ),
        );
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }

  Widget buildBottomButton() {
    Widget button = const SizedBox();
    switch (execution.status) {
      case ExecutionStatus.approved:
        button = buildButton('sign_offer_letter'.tr);
        break;
      default:
        button = buildButton('view'.tr);
    }
    return button;
  }

  Widget buildButton(String text) {
    if (execution.projectRoles != null && execution.projectRoles!.length > 1) {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_24,
            Dimens.margin_16, Dimens.margin_16),
        child: RaisedRectButton(
          height: Dimens.btnHeight_40,
          text: text,
          onPressed: () {
            String projectRole = '';
            if (execution.projectRoles != null &&
                execution.projectRoles!.isNotEmpty) {
              projectRole = execution.projectRoles?[0] ?? '';
            }
            onViewExecutionTap(index, execution, projectRole);
          },
        ),
      );
    }
  }

  Widget buildOrganizationTag() {
    if (execution.orgDisplayName != null) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundGrey400,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(Dimens.radius_16),
            bottomRight: Radius.circular(Dimens.radius_16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_8),
          child: Row(
            children: [
              const Icon(Icons.wallet_travel,
                  color: AppColors.success300, size: Dimens.iconSize_16),
              const SizedBox(width: Dimens.padding_8),
              Text(
                'Working with ${execution.orgDisplayName}',
                style: Get.textTheme.bodyText2
                    ?.copyWith(color: AppColors.success300),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
