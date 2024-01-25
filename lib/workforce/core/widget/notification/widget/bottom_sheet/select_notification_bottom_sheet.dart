import 'package:awign/workforce/core/data/model/notification_response.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';

void showNotificationBottomSheet(
    BuildContext context, Function() onNotificationTap,Notifications notifications) {
  showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return NotificationBottomSheet(onNotificationTap,notifications);
      });
}


class NotificationBottomSheet extends StatelessWidget {
  final Function() onNotificationTap;
  final Notifications notifications;
  const NotificationBottomSheet(this.onNotificationTap,this.notifications,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.margin_32,
          Dimens.padding_16, Dimens.margin_32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notifications.title ?? '',
            style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.black,
                fontSize: Dimens.font_14,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Dimens.margin_8),
          Text(
            notifications.created_at?.getDateWithDDMMMYYYYFormat() ?? '',
            style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.black,
                fontSize: Dimens.font_14,
                fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: Dimens.margin_8),
          Text(
            notifications.notification_text ?? '',
            style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.black,
                fontSize: Dimens.font_12,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: Dimens.margin_8),
          Visibility(
            visible: !notifications.image.isNullOrEmpty,
              child: Image.network(notifications.image ?? ""),
          ),
          const SizedBox(height: Dimens.margin_8),
          RaisedRectButton(
            height: Dimens.margin_40,
            text: 'okay'.tr,
            onPressed: () {
              onNotificationTap();
            },
            backgroundColor: AppColors.primaryMain,
          )
        ],
      ),
    );
  }
}
