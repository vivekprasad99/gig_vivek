import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_payout_entity.dart';
import 'package:awign/workforce/execution_in_house/feature/leadpayout/cubit/leadpayout_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../core/data/firebase/remote_config/remote_config_helper.dart';

void showLeadPayoutBottomSheet(
    BuildContext context, String leadPayoutId, String executionId) {
  showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return LeadPayoutBottomSheet(leadPayoutId, executionId);
      });
}

class LeadPayoutBottomSheet extends StatefulWidget {
  final String leadPayoutId;
  final String executionId;

  const LeadPayoutBottomSheet(this.leadPayoutId, this.executionId, {Key? key})
      : super(key: key);

  @override
  State<LeadPayoutBottomSheet> createState() => _LeadPayoutBottomSheetState();
}

class _LeadPayoutBottomSheetState extends State<LeadPayoutBottomSheet> {
  final LeadpayoutCubit _leadpayoutCubit = sl<LeadpayoutCubit>();

  @override
  void initState() {
    super.initState();
    _leadpayoutCubit.getPayoutDetails(widget.leadPayoutId, widget.executionId);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) {
          return Container(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_20,
                  Dimens.margin_32, Dimens.padding_20, Dimens.padding_16),
              child: StreamBuilder<List<LeadPayoutEntity>>(
                stream: _leadpayoutCubit.leadPayout,
                builder: (context, leadPayoutListStream) {
                  if (leadPayoutListStream.hasData &&
                      leadPayoutListStream.data!.isNotEmpty) {
                    return buildLeadPayoutList(
                        controller, leadPayoutListStream.data!);
                  } else {
                    return const SizedBox();
                  }
                },
              ));
        });
  }

  Widget buildLeadPayoutList(ScrollController scrollController,
      List<LeadPayoutEntity> leadPayoutListStream) {
    return ListView.builder(
        itemCount: leadPayoutListStream.length,
        controller: scrollController,
        itemBuilder: (_, i) {
          String url = getFileType(leadPayoutListStream[i].status!);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tooltip(
                    message: leadPayoutListStream[i].description,
                    triggerMode: TooltipTriggerMode.tap,
                    child: Row(
                      children: [
                        Text(
                          leadPayoutListStream[i]
                              .payoutSubType!
                              .toCapitalized(),
                          style: Get.context?.textTheme.labelLarge?.copyWith(
                              color: AppColors.black,
                              fontSize: Dimens.font_18,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: Dimens.padding_4),
                        const Icon(Icons.info_outline, color: AppColors.black)
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(url),
                      const SizedBox(width: Dimens.padding_8),
                      Text(
                        leadPayoutListStream[i].status!,
                        style: Get.context?.textTheme.labelLarge?.copyWith(
                            color: AppColors.backgroundGrey800,
                            fontSize: Dimens.font_14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Dimens.padding_12),
              buildLeadPayoutdata("Amount",
                  "${Constants.rs} ${leadPayoutListStream[i].amount.toString()}"),
              const SizedBox(height: Dimens.padding_8),
              Visibility(
                visible: RemoteConfigHelper.instance()
                    .showLeadPayoutDate,
                child: buildLeadPayoutdata(
                    "Due date",
                    leadPayoutListStream[i]
                        .dueDate!
                        .getFormattedDateTime(StringUtils.dateTimeFormatDMHMA)),
              ),
              const SizedBox(height: Dimens.padding_8),
              buildLeadPayoutdata(
                  "Created at",
                  leadPayoutListStream[i]
                      .createdAt!
                      .getDateWithDDMMMYYYYFormat()),
              const SizedBox(height: Dimens.padding_8),
              HDivider()
            ],
          );
        });
  }

  Widget buildLeadPayoutdata(String name, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            name,
            style: Get.context?.textTheme.labelLarge?.copyWith(
                color: AppColors.backgroundGrey700,
                fontSize: Dimens.font_14,
                fontWeight: FontWeight.w400),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: Get.context?.textTheme.labelLarge?.copyWith(
                color: AppColors.black,
                fontSize: Dimens.font_14,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String getFileType(String filetype) {
    switch (filetype) {
      case "processing":
        return "assets/images/rectangle_orange.svg";
      case "redeemed":
        return "assets/images/rectangle_green.svg";
      case "withdrawable":
        return "assets/images/rectangle_blue.svg";
      case "partiallyredeemed":
        return "assets/images/rectangle_green_white.svg";
      case "partiallywithdrawable":
        return "assets/images/rectangle_blue_white.svg";
      default:
        return "assets/images/image.svg";
    }
  }
}
