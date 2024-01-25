import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showWhatsAppBottomSheet(
    BuildContext context, Function() onDisableTap, Function() onCancelTap) {
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
        return WhatsAppBottomSheet(onDisableTap, onCancelTap);
      });
}

class WhatsAppBottomSheet extends StatelessWidget {
  final Function() onDisableTap;
  final Function() onCancelTap;

  const WhatsAppBottomSheet(this.onDisableTap, this.onCancelTap, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_32,
        Dimens.padding_16,
        Dimens.padding_48,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'disable_whatsapp_notifications'.tr,
                style: Get.context?.textTheme.titleLarge?.copyWith(
                    color: AppColors.black, fontSize: Dimens.font_16),
              ),
              MyInkWell(
                onTap: () {
                  onCancelTap();
                },
                child: const CircleAvatar(
                  backgroundColor: AppColors.backgroundGrey700,
                  radius: Dimens.padding_12,
                  child: Icon(
                    Icons.close,
                    color: AppColors.backgroundWhite,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimens.margin_16),
          Text(
            'you_wont_recieve_notification'.tr,
            style: Get.context?.textTheme.titleLarge?.copyWith(
                color: AppColors.black,
                fontSize: Dimens.font_14,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: Dimens.margin_16),
          Row(
            children: [
              Expanded(
                child: RaisedRectButton(
                  text: 'disable'.tr,
                  onPressed: () {
                    onDisableTap();
                  },
                  backgroundColor: AppColors.error400,
                ),
              ),
              const SizedBox(width: Dimens.margin_16),
              Expanded(
                child: RaisedRectButton(
                  text: 'cancel'.tr,
                  textColor: AppColors.black,
                  borderColor: AppColors.backgroundGrey400,
                  onPressed: () {
                    onCancelTap();
                  },
                  backgroundColor: AppColors.transparent,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
