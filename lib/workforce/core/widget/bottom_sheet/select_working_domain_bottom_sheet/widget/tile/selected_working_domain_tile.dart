import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/model/working_domain.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectedWorkingDomainTile extends StatelessWidget {
  final int index;
  final WorkingDomain workingDomain;

  const SelectedWorkingDomainTile(
      {Key? key, required this.index, required this.workingDomain})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.padding_8),
      child: Text(workingDomain.name, style: Get.context?.textTheme.bodyText1),
    );
  }
}
