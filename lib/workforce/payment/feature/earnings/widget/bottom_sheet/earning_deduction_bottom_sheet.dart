import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/calculate_deduction_response.dart';
import 'package:awign/workforce/payment/feature/earnings/widget/bottom_sheet/early_withdrawl_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showEarningDeductionBottomSheet(BuildContext context,CalculateDeductionResponse? calculateDeductionResponse) {
  showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return  EarningDeductionBottomSheet(calculateDeductionResponse);
      });
}

class EarningDeductionBottomSheet extends StatelessWidget {
  final CalculateDeductionResponse? calculateDeductionResponse;
  const EarningDeductionBottomSheet(this.calculateDeductionResponse,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_20,
        Dimens.padding_32,
        Dimens.padding_20,
        Dimens.padding_48,
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
          const SizedBox(
            height: Dimens.padding_8,
          ),
          Image.asset(
            "assets/images/deduction.png",
          ),
          const SizedBox(
            height: Dimens.padding_8,
          ),
          Text('what_are_deductions'.tr,
              style: context.textTheme.bodyText1?.copyWith(
                  color: AppColors.backgroundGrey900,
                  fontWeight: FontWeight.w700,
                  fontSize: Dimens.font_18)),
          const SizedBox(
            height: Dimens.padding_16,
          ),
          Text('what_are_deductions_desc'.tr,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyText1?.copyWith(
                  color: AppColors.backgroundBlack,
                  fontWeight: FontWeight.w400,
                  fontSize: Dimens.font_14)),
          const SizedBox(
            height: Dimens.padding_16,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text('deduction_categories_one'.tr,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyText1?.copyWith(
                        color: AppColors.backgroundBlack,
                        fontWeight: FontWeight.w400,)),
              ),
            ],
          ),
          const SizedBox(
            height: Dimens.padding_16,
          ),
          MyInkWell(
            onTap: (){
              MRouter.pop(null);
              // showEarlyWithdrawlBottomSheet(context,calculateDeductionResponse!);
              MRouter.pushNamed(MRouter.earlyRedemptionPolicyWidget, arguments: calculateDeductionResponse);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('know_more'.tr,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryMain,
                        fontWeight: FontWeight.w400,)),
                const Icon(Icons.arrow_forward_ios,size: Dimens.padding_12,color: AppColors.primaryMain,),
              ],
            ),
          ),
          const SizedBox(
            height: Dimens.padding_20,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text('deduction_categories_two'.tr,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyText1?.copyWith(
                      color: AppColors.backgroundBlack,
                      fontWeight: FontWeight.w400,)),
              ),
            ],
          ),
          const SizedBox(
            height: Dimens.padding_16,
          ),
          MyInkWell(
            onTap: (){
              MRouter.pop(null);
              MRouter.pushNamed(MRouter.faqAndSupportWidget, arguments: {});
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('know_more'.tr,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryMain,
                      fontWeight: FontWeight.w400,)),
                const Icon(Icons.arrow_forward_ios,size: Dimens.padding_12,color: AppColors.primaryMain,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
