import 'package:awign/workforce/core/data/model/notification_response.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';

class NotificationTile extends StatelessWidget {
  final int index;
  final Notifications notifications;
  final Function(int index, Notifications notifications) onNotificationTap;

  const NotificationTile(
      {Key? key,
      required this.index,
      required this.notifications,
      required this.onNotificationTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyInkWell(
      onTap: () {
        onNotificationTap(index, notifications);
      },
      child: Container(
        color: notifications.status == Constants.acknowledged
            ? AppColors.backgroundWhite
            : AppColors.primary100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              visualDensity: const VisualDensity(
                vertical: -2,
              ),
              minVerticalPadding: 16,
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryMain,
                child: SvgPicture.asset(
                  'assets/images/ic_awign_logo.svg',
                  color: AppColors.backgroundWhite,
                  height: Dimens.iconSize_16,
                ),
              ),
              title: Text(
                notifications.title ?? '',
                style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.black,
                    fontSize: Dimens.font_14,
                    fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: Dimens.padding_8,
                  ),
                  Text(
                    notifications.notification_text ?? '',
                    style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.black,
                        fontSize: Dimens.font_12,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(
                    height: Dimens.padding_8,
                  ),
                  Text(
                    notifications.created_at?.getDateWithDDMMMYYYYFormat() ??
                        '',
                    style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.black,
                        fontSize: Dimens.font_12,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            HDivider(),
          ],
        ),
      ),
    );
  }
}
