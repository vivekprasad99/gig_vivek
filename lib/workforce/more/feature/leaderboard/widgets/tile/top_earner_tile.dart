import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/data/model/earning_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TopEarnerTile extends StatelessWidget {
  final EarningResponse topEarner;
  final int index;
  const TopEarnerTile({Key? key, required this.topEarner,required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radius_8),
          ),
          child: Container(
            width: Dimens.margin_120,
            padding: const EdgeInsets.all(Dimens.padding_16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTopPerformerNameText(),
                const SizedBox(height: Dimens.margin_8),
                buildTopPerformerValueText(),
              ],
            ),
          ),
        ),
        buildTopPerformerBadge(),
      ],
    );
  }

  // }

  Widget buildTopPerformerNameText() {
    return Padding(
      padding: const EdgeInsets.only(top: Dimens.margin_20),
      child: Text(
        '${topEarner.userData![index].name}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Get.context?.textTheme.titleLarge?.copyWith(
            color: AppColors.backgroundGrey900,
            fontSize: Dimens.padding_12,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget buildTopPerformerValueText() {
    return Text(
      topEarner.pillar == 'earning' ? '${Constants.rs} ${StringUtils.getIndianFormatNumber(topEarner.userData![index].data)}' : '${topEarner.userData![index].data} Tasks',
      style: Get.context?.textTheme.titleLarge?.copyWith(
          color: AppColors.backgroundBlack,
          fontSize: Dimens.padding_12,
          fontWeight: FontWeight.w700),
    );
  }

  Widget buildTopPerformerBadge() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        decoration: BoxDecoration(
          color: getColor(topEarner.userData![index].rank!)[Constants.bgColor],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimens.radius_16),
            bottomRight: Radius.circular(Dimens.radius_16),
          ),
        ),
        padding: const EdgeInsets.all(Dimens.margin_8),
        margin: const EdgeInsets.only(top: Dimens.margin_4),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/medal.svg',
              color: getColor(topEarner.userData![index].rank!)[Constants.badgeColor],
            ),
            Text(
              '#${topEarner.userData![index].rank}',
              style: Get.context?.textTheme.titleLarge?.copyWith(
                  color: AppColors.backgroundBlack,
                  fontSize: Dimens.padding_12,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Color> getColor(int rank) {
    switch (rank) {
      case 1:
        return {
          Constants.bgColor: AppColors.warning200,
          Constants.badgeColor: AppColors.warning300
        };
      case 2:
        return {
          Constants.bgColor: AppColors.backgroundGrey300,
          Constants.badgeColor: AppColors.backgroundGrey800
        };
      case 3:
        return {
          Constants.bgColor: AppColors.backgroundPink,
          Constants.badgeColor: AppColors.backgroundDarkPink
        };
      case 4:
        return {
          Constants.bgColor: AppColors.secondary2100,
          Constants.badgeColor: AppColors.secondary2400
        };
      case 5:
        return {
          Constants.bgColor: AppColors.success100,
          Constants.badgeColor: AppColors.success300
        };
      default:
        return {
          Constants.bgColor: AppColors.warning200,
          Constants.badgeColor: AppColors.warning300
        };
    }
  }
}
