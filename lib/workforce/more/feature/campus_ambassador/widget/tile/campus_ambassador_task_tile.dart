import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../../core/widget/buttons/my_ink_well.dart';

class CampusAmbassadorTaskTile extends StatelessWidget {
  final CampusAmbassadorTasks campusAmbassadorTasks;
  final Function(CampusAmbassadorTasks campusAmbassadorTasks) onViewTaskTap;
  const CampusAmbassadorTaskTile({Key? key,required this.campusAmbassadorTasks,required this.onViewTaskTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
      child: MyInkWell(
        onTap: () {
          onViewTaskTap(campusAmbassadorTasks);
        },
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimens.radius_8),
            ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/images/ic_logo_awign.svg',height: Dimens.iconSize_28,
                ),
                const SizedBox(height: Dimens.margin_12),
                Text(
                  campusAmbassadorTasks.worklistingName ?? "",
                  style: Get.context?.textTheme.labelSmall?.copyWith(
                      color: AppColors.backgroundGrey700,
                      fontSize: Dimens.font_16,
                      fontWeight: FontWeight.w500),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }


}
