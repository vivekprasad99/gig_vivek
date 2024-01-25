import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/calculate_deduction_response.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class EarlyWithdrawlTile extends StatelessWidget {
  final ApprovedPayouts approvedPayouts;
  const EarlyWithdrawlTile({Key? key,required this.approvedPayouts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  const EdgeInsets.all(Dimens.padding_4),
      child: Row(
        children: [
          Expanded(
            child: Text("${StringUtils.getDayMonthAndYear(approvedPayouts.dueDate!)}",
              textAlign: TextAlign.start,
              style: Get.textTheme.bodySmall!.copyWith(
                  color: AppColors.backgroundGrey800,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text("${approvedPayouts.amount}",
              textAlign: TextAlign.center,
              style: Get.textTheme.bodySmall!.copyWith(
                  color: AppColors.backgroundGrey800,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text("${approvedPayouts.discount}",
              textAlign: TextAlign.center,
              style: Get.textTheme.bodySmall!.copyWith(
                  color: AppColors.error400,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
