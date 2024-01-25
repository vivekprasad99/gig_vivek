import 'dart:collection';
import 'dart:core';

import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/helper/lead_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/helper.dart';
import '../../../../../core/widget/theme/theme_manager.dart';
import '../../../../data/model/lead_entity.dart';
import '../../../../data/model/lead_view_config_entity.dart';

void showMoreActionBottomSheet(BuildContext context, List<Columns> moreActions,
    Lead lead, Function(String action, Columns column) onCallBridgeClicked) {
  showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.4,
          maxChildSize: 0.4,
          builder: (BuildContext _, ScrollController scrollController) {
            return MoreActionBottomSheet(
                moreActions: moreActions,
                lead: lead,
                onCallBridgeClicked: onCallBridgeClicked);
          },
        );
      });
}

class MoreActionBottomSheet extends StatelessWidget {
  final List<Columns> moreActions;
  final Lead lead;
  final Function(String actions, Columns column) onCallBridgeClicked;

  const MoreActionBottomSheet(
      {Key? key,
      required this.moreActions,
      required this.lead,
      required this.onCallBridgeClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimens.padding_16, vertical: Dimens.margin_28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildMoreAction(),
          const SizedBox(height: Dimens.margin_8,),
          HDivider(),
          const SizedBox(height: Dimens.margin_8,),
          buildSetActionButtons(),
        ],
      ),
    );
  }

  Widget buildMoreAction() {
    return Text('more_action'.tr,
        style: Get.context?.textTheme.bodyText2Bold?.copyWith(
            color: AppColors.black,
            fontSize: Dimens.font_28,
            fontWeight: FontWeight.w600));
  }

  Widget buildSetActionButtons() {
    LinkedHashMap<String?, List<Columns>?>? groupedActions =
        getGroupedActions(moreActions);
    if (groupedActions == null) return const SizedBox();

    return Expanded(
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: groupedActions.entries.length,
          itemBuilder: (context, index) {
            String actionName = "";
            String actionIcon = "";
            switch (groupedActions.entries.elementAt(index).key) {
              case ColumnAction.WHATSAPP:
                actionName = 'whatsapp'.tr;
                actionIcon = 'assets/images/ic_whatsapp_violet.svg';
                break;
              case ColumnAction.CALL:
                actionName = 'call'.tr;
                actionIcon = 'assets/images/ic_call_violet.svg';
                break;
              case ColumnAction.BRIDGE_CALL:
                actionName = 'call_bridge'.tr;
                actionIcon = 'assets/images/ic_bridge_violet.svg';
                break;
              case ColumnAction.LOCATION:
                actionName = 'location'.tr;
                actionIcon = 'assets/images/ic_location_violet.svg';
                break;
              case ColumnAction.EMAIL:
                actionName = 'email'.tr;
                actionIcon = 'assets/images/ic_mail_violet.svg';
                break;
              case ColumnAction.MORE:
                actionName = 'more_action'.tr;
                actionIcon = 'assets/images/ic_mail_violet.svg';
            }
            return MyInkWell(
                onTap: () {
                  if(actionValueEmpty(groupedActions.entries.elementAt(index).value, lead)) {
                    Helper.showInfoToast('action_not_set'.tr);
                  } else {
                    onCallBridgeClicked(actionName,
                        groupedActions.entries.elementAt(index).value![0]);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundGrey300,
                        borderRadius: BorderRadius.all(
                          Radius.circular(Dimens.radius_20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(actionIcon),
                      ),
                    ),
                    Text(actionName)
                  ],
                ));
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: MediaQuery.of(context).size.width/15,
            );
          }),
    );
  }

  LinkedHashMap<String?, List<Columns>?>? getGroupedActions(
      List<Columns>? moreActions) {
    if (moreActions == null) return null;

    LinkedHashMap<String?, List<Columns>?> groupedActions =
        LinkedHashMap<String?, List<Columns>?>();
    for (Columns column in moreActions) {
      String? action = column.action;
      if (action == null || column.uid == null) continue;

      List<Columns>? actionColumns = groupedActions[action];
      actionColumns ??= <Columns>[];
      actionColumns.add(column);
      groupedActions[action] = actionColumns;
    }
    return groupedActions;
  }

  bool actionValueEmpty(List<Columns>? columns, Lead lead) {
    if (columns == null) return false;
    int nonNullColumns = 0;
    for (Columns column in columns) {
      if (lead.get(column.uid!) != null) {
        nonNullColumns ++;
      }
    }
    return nonNullColumns == 0;
  }
}
