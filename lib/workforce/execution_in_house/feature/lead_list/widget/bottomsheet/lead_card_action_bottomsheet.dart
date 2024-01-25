import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../data/model/lead_view_config_entity.dart';
import '../../helper/lead_constant.dart';

showLeadCardActionBottomSheet(BuildContext context, String action,
    List<Columns> columns, Lead lead, Function(int position) onActionClicked) {
  showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return LeadCardActionBottomSheet(
            action: action,
            columns: columns,
            lead: lead,
            onActionClicked: onActionClicked);
      });
}

class LeadCardActionBottomSheet extends StatelessWidget {
  final String action;
  final List<Columns> columns;
  final Lead lead;
  final Function(int position) onActionClicked;

  const LeadCardActionBottomSheet(
      {Key? key,
      required this.action,
      required this.columns,
      required this.lead,
      required this.onActionClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Dimens.padding_24, horizontal: Dimens.padding_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHeadText(),
          const SizedBox(height: Dimens.margin_24),
          buildListActionButtons(),
        ],
      ),
    );
  }

  Widget buildHeadText() {
    return Text('call'.tr,
        style: Get.context?.textTheme.bodyText1Bold
            ?.copyWith(color: AppColors.black, fontWeight: FontWeight.w600));
  }

  Widget buildListActionButtons() {
    return Expanded(
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          String actionName = "";
          String actionIcon = "";
          switch (action) {
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
                onActionClicked(index);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(actionName),
                  SvgPicture.asset(actionIcon),
                ],
              ));
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            height: Dimens.margin_16,
          );
        },
        itemCount: columns.length,
      ),
    );
  }
}
