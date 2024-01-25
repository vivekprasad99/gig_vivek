import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widget/buttons/raised_rect_button.dart';

void showNoUpComingBottomSheet(BuildContext context) {
  showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return const NoUpComingEarningBottomSheet();
      });
}

class NoUpComingEarningBottomSheet extends StatelessWidget {
  const NoUpComingEarningBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.padding_16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/ic_no_upcoming_earning.png'),
          const SizedBox(
            height: Dimens.margin_16,
          ),
          Text('no_upcoming_earnings_found'.tr,
              style: Get.context?.textTheme.bodyMedium?.copyWith(
                  color: AppColors.black,
                  fontSize: Dimens.font_20,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: Dimens.margin_24,),
          RaisedRectButton(text: 'okay'.tr, height: Dimens.btnHeight_40,
          onPressed: () {
            MRouter.pop(null);
          },)
        ],
      ),
    );
  }
}
