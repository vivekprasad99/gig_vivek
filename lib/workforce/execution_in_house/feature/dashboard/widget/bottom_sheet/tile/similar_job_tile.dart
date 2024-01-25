import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/circle_avatar/custom_circle_avatar.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SimilarJobTile extends StatelessWidget {
  final int index;
  final WorkApplicationEntity workApplicationEntity;
  final Function(int, WorkApplicationEntity) onJobSelected;

  const SimilarJobTile({
    Key? key,
    required this.index,
    required this.workApplicationEntity,
    required this.onJobSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: MyInkWell(
        onTap: () {
          onJobSelected(index, workApplicationEntity);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.backgroundGrey400),
            borderRadius: BorderRadius.circular(Dimens.radius_8),
          ),
          child: Container(
            padding: const EdgeInsets.all(Dimens.padding_16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildIcon(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildApplicationName(),
                      buildEarningText(),
                    ],
                  ),
                ),
                buildRightArrow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIcon() {
    if (workApplicationEntity.icon != null) {
      return CustomCircleAvatar(
          url: workApplicationEntity.icon, radius: Dimens.radius_20);
    } else {
      return const SizedBox();
    }
  }

  Widget buildApplicationName() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Dimens.padding_16, 0, Dimens.padding_16, 0),
      child: Text(
        workApplicationEntity.workListingTitle ?? '',
        style: Get.textTheme.bodyText1Medium
            ?.copyWith(color: AppColors.backgroundBlack),
      ),
    );
  }

  Widget buildEarningText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0.0),
      child: Text('${workApplicationEntity.potentialEarning?.getEarningText()}',
          style: Get.context?.textTheme.bodyText2
              ?.copyWith(color: AppColors.backgroundGrey800)),
    );
  }

  Widget buildRightArrow() {
    return SvgPicture.asset(
      'assets/images/ic_arrow_right.svg',
    );
  }
}
