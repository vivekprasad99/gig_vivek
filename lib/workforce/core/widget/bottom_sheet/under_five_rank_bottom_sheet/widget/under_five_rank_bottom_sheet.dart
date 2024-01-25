import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showUnderFiveRankBottomSheet(
    BuildContext context,int? rank) {
  showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return  UnderFiveRankBottomSheet(rank ?? 0);
      });
}

class UnderFiveRankBottomSheet extends StatelessWidget {
  final int? rank;
  const UnderFiveRankBottomSheet(this.rank,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16,
          Dimens.padding_16,
          Dimens.padding_16,
          Dimens.padding_32,
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyInkWell(
            onTap: () {
              MRouter.pop(null);
            },
            child: const Align(
              alignment: Alignment.topRight,
              child: CircleAvatar(
                backgroundColor: AppColors.backgroundGrey700,
                radius: Dimens.padding_12,
                child: Icon(
                  Icons.close,
                  color: AppColors.backgroundWhite,
                  size: Dimens.padding_16,
                ),
              ),
            ),
          ),
          CircleAvatar(
            radius: 40,
            backgroundColor: getColor(rank!)["bg_color"],
            child: SvgPicture.asset(
              'assets/images/medal.svg',
              color: getColor(rank!)["badge_color"],
              height: Dimens.margin_36,
            ),
          ),
          const SizedBox(height: Dimens.margin_24),
          Text(
            'Rank ${rank ?? ""}',
            style: Get.context?.textTheme.titleLarge?.copyWith(
                color: AppColors.black,
                fontSize: Dimens.font_24,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Dimens.margin_16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
            child: RichText(
              textAlign: TextAlign.center,
                text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: 'rank_one_desc'.tr,style: Get.context?.textTheme.titleLarge
                          ?.copyWith(color: AppColors.backgroundGrey900,fontSize: Dimens.padding_16,fontWeight: FontWeight.w500),),
                      TextSpan(text: '${getColor(rank! ?? 0)["in_words"]}',style: Get.context?.textTheme.titleLarge
                          ?.copyWith(color: AppColors.black,fontSize: Dimens.padding_16,fontWeight: FontWeight.w500),),
                      TextSpan(text: 'rank_three_desc'.tr,style: Get.context?.textTheme.titleLarge
                          ?.copyWith(color: AppColors.backgroundGrey900,fontSize: Dimens.padding_16,fontWeight: FontWeight.w500),),
                    ]
                )),
          ),
          const SizedBox(height: Dimens.margin_16),
          RaisedRectButton(
            text:  'awesome'.tr,
            onPressed: () {
              MRouter.pop(null);
            },
          )
        ],
      ),
    );
  }

  Map<String, dynamic> getColor(int rank) {
    switch (rank) {
      case 1:
        return {"in_words": "first", "badge_color": AppColors.warning300,"bg_color": AppColors.warning200};
      case 2:
        return {"in_words": "second", "badge_color": AppColors.backgroundGrey800,"bg_color": AppColors.backgroundGrey300};
      case 3:
        return {"in_words": "third", "badge_color": AppColors.backgroundDarkPink,"bg_color": AppColors.backgroundDarkPink};
      case 4:
        return {"in_words": "fourth", "badge_color": AppColors.secondary2400,"bg_color": AppColors.secondary2100};
      case 5:
        return {"in_words": "fifth", "badge_color": AppColors.success300,"bg_color": AppColors.success300};
      default:
        return {"in_words": "fifth", "badge_color": AppColors.warning300,"bg_color": AppColors.warning200};
    }
  }
}
