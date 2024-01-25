import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widget/theme/theme_manager.dart';

class EmptyEarningCard extends StatelessWidget {
  const EmptyEarningCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            Dimens.radius_8),
      ),
      child: Container(
        padding: const EdgeInsets.all(
            Dimens.padding_16),
        child: Column(
          children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'withdrawable_earnings'
                          .tr,
                      style: context.textTheme.bodyText2?.copyWith(
                          color: AppColors
                              .backgroundGrey900,
                          fontWeight:
                          FontWeight
                              .w500,
                          fontSize:
                          Dimens.font_16)),
                  Text(
                      '0',
                      style: context.textTheme.bodyText2?.copyWith(
                          color: AppColors
                              .backgroundGrey800,
                          fontWeight:
                          FontWeight
                              .w500,
                          fontSize:
                          Dimens.font_16)),
                ],
              ),
            const SizedBox(
                height: Dimens.padding_16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/images/earning_rocket.png"),
                RaisedRectButton(
                  borderColor: AppColors.primaryMain,
                  height: Dimens.margin_40,
                  textColor: AppColors.primaryMain,
                  backgroundColor: AppColors.backgroundWhite,
                  rightIcon: const Icon(Icons.arrow_forward,color: AppColors.primaryMain,size: Dimens.font_16,),
                  width: Dimens.btnWidth_180,
                  text: 'find_more_work'.tr,
                  onPressed: () {
                    MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
