import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/model/working_domain.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkingDomainTile extends StatelessWidget {
  final int index;
  final WorkingDomain workingDomain;
  final Function(int index, WorkingDomain workingDomain) onTap;

  const WorkingDomainTile(
      {Key? key,
      required this.index,
      required this.workingDomain,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
      child: Row(
        children: [
          Checkbox(
            value: workingDomain.isSelected,
            onChanged: (v) {
              onTap(index, workingDomain);
            },
          ),
          Text(workingDomain.name, style: Get.context?.textTheme.bodyText1)
        ],
      ),
    );
  }
}
