import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void updateApplicationBottomSheet(
    BuildContext context, Function() onContinueTap) {
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
        return UpdateApplicationBottomSheet(onContinueTap,);
      });
}

class UpdateApplicationBottomSheet extends StatelessWidget {
  final Function() onContinueTap;
  const UpdateApplicationBottomSheet(this.onContinueTap,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_24,
        Dimens.padding_16,
        Dimens.padding_40,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'are_you_sure'.tr,
                style: Get.context?.textTheme.titleLarge?.copyWith(
                    color: AppColors.black,),
              ),
              MyInkWell(
                onTap: () {
                  MRouter.pop(null);
                },
                child: const CircleAvatar(
                  backgroundColor: AppColors.backgroundGrey700,
                  radius: Dimens.padding_12,
                  child: Icon(
                    Icons.close,
                    color: AppColors.backgroundWhite,
                    size: Dimens.padding_16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimens.padding_24,),
          Text(
            'updating_your_application'.tr,
            style: Get.context?.textTheme.bodyLarge?.copyWith(
              color: AppColors.backgroundGrey900,),
          ),
          const SizedBox(height: Dimens.padding_24,),
          RaisedRectButton(
            text: 'confirm'.tr,
            onPressed: () {
              onContinueTap();
            },
          ),
        ],
      ),
    );
  }
}
