import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/browser_helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/calculate_deduction_response.dart';
import 'package:awign/workforce/payment/feature/earnings/widget/bottom_sheet/tile/early_withdrawl_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showEarlyWithdrawlBottomSheet(BuildContext context,CalculateDeductionResponse calculateDeductionResponse) {
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
        return  EarlyWithdrawlBottomSheet(calculateDeductionResponse);
      });
}

class EarlyWithdrawlBottomSheet extends StatelessWidget {
  final CalculateDeductionResponse calculateDeductionResponse;
  const EarlyWithdrawlBottomSheet(this.calculateDeductionResponse,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
        builder: (_, controller) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16,
              Dimens.padding_16,
              Dimens.padding_16,
              Dimens.padding_32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: Dimens.padding_8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildEarlyWithdrawlText(),
                    buildCloseIcon(),
                  ],
                ),
                const SizedBox(
                  height: Dimens.padding_8,
                ),
                buildWithdrawlChargesDescCard(),
                HDivider(dividerColor: AppColors.backgroundGrey400),
                buildWithdrawlChargesLabel(),
                const SizedBox(
                  height: Dimens.padding_8,
                ),
                buildEarlyWithdrawlList(controller),
                HDivider(dividerColor: AppColors.backgroundGrey400),
                buildTotalDeductionWidget()
              ],
            ),
          );
        }
          );
  }

  Widget buildCloseIcon() {
    return MyInkWell(
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
    );
  }

  Widget buildEarlyWithdrawlText()
  {
    return Text('early_withdrawal_charges'.tr,
        style: Get.context!.textTheme.bodyText1?.copyWith(
            color: AppColors.backgroundBlack,
            fontWeight: FontWeight.w600,
            fontSize: Dimens.font_18));
  }

  Widget buildWithdrawlChargesDescCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  const Icon(
                    Icons.info,
                    color: AppColors.black,
                    size: Dimens.padding_20,
                  ),
                  const SizedBox(
                    width: Dimens.padding_16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                            'charges_depend_on_desc'
                                .tr,
                            style: Get.context!
                                .textTheme
                                .bodyText2
                                ?.copyWith(color: AppColors.backgroundBlack, fontWeight: FontWeight.w500,fontSize: Dimens.font_10)),
                        const SizedBox(
                          height: Dimens.padding_8,
                        ),
                        MyInkWell(
                          onTap:
                              () {
                                BrowserHelper.customTab(
                                    Get.context!, "https://www.awign.com/terms_and_conditions");
                              },
                          child: Text(
                               'terms_and_condition_applied'.tr,
                              style: Get.context!.textTheme.bodyText2?.copyWith(color: AppColors.primaryMain, fontWeight: FontWeight.w400, fontSize: Dimens.font_10)),
                        ),
                      ],
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget buildWithdrawlChargesLabel()
  {
    return Row(
      children: [
        Expanded(
          child: Text("approval_date".tr,
            textAlign: TextAlign.start,
            style: Get.textTheme.bodySmall!.copyWith(
                color: AppColors.backgroundBlack,
                fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text("upcoming_account".tr,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodySmall!.copyWith(
                color: AppColors.backgroundBlack,
                fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text("charges_on".tr,
            textAlign: TextAlign.right,
            style: Get.textTheme.bodySmall!.copyWith(
                color: AppColors.backgroundBlack,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget buildTotalDeductionWidget()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("total_deduction".tr,
          textAlign: TextAlign.start,
          style: Get.textTheme.bodyMedium!.copyWith(
              color: AppColors.backgroundBlack,
              fontWeight: FontWeight.w500),
        ),
        Text('- ${calculateDeductionResponse.deductions![1].amount}',
          textAlign: TextAlign.start,
          style: Get.textTheme.bodyMedium!.copyWith(
              color: AppColors.error400,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget buildEarlyWithdrawlList(ScrollController scrollController) {
    return Expanded(
      child: ListView.builder(
        itemCount: calculateDeductionResponse.approvedPayouts?.length,
        controller: scrollController,
        itemBuilder: (_, i) {
          return EarlyWithdrawlTile(approvedPayouts: calculateDeductionResponse.approvedPayouts![i],);
            },
          ),
    );
      }
}

