import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/data/model/user_earning_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserEarningsWidget extends StatelessWidget {
  final UserEarningResponse userEarning;

  const UserEarningsWidget({Key? key, required this.userEarning})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.radius_8),
          color: AppColors.primary600,
        ),
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildBadgeWidget(),
                const SizedBox(height: Dimens.margin_16),
                buildEarningText(),
                const SizedBox(height: Dimens.margin_16),
                buildRankDescription(),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Image.asset(
                'assets/images/confetti_colorful.png',
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildBadgeWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SvgPicture.asset(
          'assets/images/medal.svg',
          color: getColor(userEarning.rank!)[Constants.badgeColor],
          height: Dimens.font_24,
        ),
        const SizedBox(width: Dimens.margin_8),
        Text(
          'Rank ${userEarning.rank}',
          style: Get.context?.textTheme.titleLarge?.copyWith(
              color: AppColors.backgroundGrey100,
              fontSize: Dimens.padding_16,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget buildEarningText() {
    return Text(
      NumberFormat.currency(
              locale: 'HI', name: "", decimalDigits: 0, symbol: '₹ ')
          .format(userEarning.data),
      style: Get.context?.textTheme.titleLarge?.copyWith(
          color: AppColors.backgroundGrey100,
          fontSize: Dimens.padding_32,
          fontWeight: FontWeight.w600),
    );
  }

  Widget buildRankDescription() {
    return RichText(
        text: TextSpan(children: <TextSpan>[
      TextSpan(
        text: 'rank_one_desc'.tr,
        style: Get.context?.textTheme.titleLarge?.copyWith(
            color: AppColors.backgroundGrey100,
            fontSize: Dimens.padding_16,
            fontWeight: FontWeight.w500),
      ),
      TextSpan(
        text: '${getColor(userEarning.rank!)["in_words"]}',
        style: Get.context?.textTheme.titleLarge?.copyWith(
            color: AppColors.backgroundGrey100,
            fontSize: Dimens.padding_16,
            fontWeight: FontWeight.w500),
      ),
      TextSpan(
        text: 'rank_two_desc'.tr,
        style: Get.context?.textTheme.titleLarge?.copyWith(
            color: AppColors.backgroundGrey100,
            fontSize: Dimens.padding_16,
            fontWeight: FontWeight.w500),
      ),
    ]));
  }

  Map<String, dynamic> getColor(int rank) {
    switch (rank) {
      case 1:
        return {
          "in_words": "first",
          Constants.badgeColor: AppColors.warning300
        };
      case 2:
        return {
          "in_words": "second",
          Constants.badgeColor: AppColors.backgroundGrey800
        };
      case 3:
        return {
          "in_words": "third",
          Constants.badgeColor: AppColors.backgroundDarkPink
        };
      case 4:
        return {
          "in_words": "fourth",
          Constants.badgeColor: AppColors.secondary2400
        };
      case 5:
        return {
          "in_words": "fifth",
          Constants.badgeColor: AppColors.success300
        };
      default:
        return {
          "in_words": "fifth",
          Constants.badgeColor: AppColors.warning300
        };
    }
  }
}
