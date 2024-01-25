import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showWhatsappNotificationBottomSheet(
    BuildContext context, Function() onEnableTap, Function() onLaterTap,Function() onCloseTap) {
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
        return WhatsappNotificationBottomSheet(onEnableTap, onLaterTap,onCloseTap);
      });
}

class WhatsappNotificationBottomSheet extends StatelessWidget {
  final Function() onEnableTap;
  final Function() onLaterTap;
  final Function() onCloseTap;
  const WhatsappNotificationBottomSheet(this.onEnableTap, this.onLaterTap,this.onCloseTap,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            SvgPicture.asset(
              'assets/images/whatsapp_notification.svg',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width * 1,
            ),
            Positioned(
              top: Dimens.padding_20,
              right: Dimens.padding_20,
              child: MyInkWell(
                onTap: () {
                  onCloseTap();
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
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Dimens.padding_12,
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16),
          child: Text(
            'by_enabling_this_feature_you_can_receive_all'.tr,
            textAlign: TextAlign.center,
            style: Get.textTheme.headline7SemiBold.copyWith(
                color: AppColors.backgroundBlack,
                fontSize: Dimens.font_14,
                fontWeight: FontWeight.w400),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
          child: RaisedRectButton(
            text: 'enable'.tr,
            onPressed: () {
              onEnableTap();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, 0, Dimens.padding_16, 0),
          child: RaisedRectButton(
            text: 'i_ll_do_it_later'.tr,
            fontSize: Dimens.font_16,
            backgroundColor: AppColors.transparent,
            textColor: AppColors.primaryMain,
            onPressed: () {
              onLaterTap();
            },
          ),
        )
      ],
    );
  }
}
