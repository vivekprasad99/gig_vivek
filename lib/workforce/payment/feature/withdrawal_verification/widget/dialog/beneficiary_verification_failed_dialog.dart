import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showBeneficiaryVerificationFailedDialog(
    BuildContext c,
    int? index,
    Beneficiary beneficiary,
    String message,
    Function(int?, Beneficiary) onDeleteTap) {
  showDialog(
    context: c,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          decoration: BoxDecoration(
            color: Get.theme.backgroundColor,
            borderRadius:
                const BorderRadius.all(Radius.circular(Dimens.radius_16)),
          ),
          padding: const EdgeInsets.all(Dimens.padding_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/images/ic_error_info.svg'),
                      const SizedBox(width: Dimens.padding_12),
                      Text('verification_failed'.tr,
                          style: Get.textTheme.bodyText1Bold
                              ?.copyWith(color: AppColors.backgroundBlack)),
                    ],
                  ),
                  MyInkWell(
                    onTap: () {
                      MRouter.pop(null);
                    },
                    child: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(height: Dimens.padding_8),
              Text('message',
                  style: Get.textTheme.bodyText2
                      ?.copyWith(color: AppColors.backgroundGrey800)),
              const SizedBox(height: Dimens.padding_32),
              Align(
                alignment: Alignment.topRight,
                child: RaisedRectButton(
                  text: 'delete_this_account'.tr,
                  width: Dimens.btnWidth_200,
                  height: Dimens.btnHeight_40,
                  backgroundColor: AppColors.error400,
                  onPressed: () {
                    MRouter.pop(null);
                    onDeleteTap(index, beneficiary);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
