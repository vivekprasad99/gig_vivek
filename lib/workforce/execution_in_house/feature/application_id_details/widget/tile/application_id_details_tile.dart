import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/widget/buttons/my_ink_well.dart';
import '../../../../../core/widget/buttons/raised_rect_button.dart';

class ApplicationIdDetailsTile extends StatelessWidget {
  final String applicationID;
  final String? id;

  const ApplicationIdDetailsTile(this.applicationID, this.id, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildIdNameWidget('application_id'.tr, Icons.info_outline,
                    context, 'application_id_description'.tr),
                buildIdNameWidget('execution_id'.tr, Icons.info_outline,
                    context, 'execution_id_description'.tr)
              ],
            ),
            const SizedBox(height: Dimens.margin_12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildIdValueWidget(
                    applicationID.toString(), Icons.copy_rounded, context),
                buildIdValueWidget(id!, Icons.copy_rounded, context)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIdValueWidget(String name, IconData icon, BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Flexible(
            child: Text(
              name,
              style: Get.context?.textTheme.bodyText1Bold
                  ?.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: Dimens.margin_8),
          MyInkWell(
              onTap: () {
                final value = ClipboardData(text: name);
                Clipboard.setData(value);
                Helper.showInfoToast('Text Copied');
              },
              child: Icon(icon, color: AppColors.backgroundGrey700)),
        ],
      ),
    );
  }

  Widget buildIdNameWidget(
      String name, IconData icon, BuildContext context, String description) {
    return Row(
      children: [
        Text(
          name,
          style: Get.context?.textTheme.bodyLarge
              ?.copyWith(color: AppColors.black),
        ),
        const SizedBox(width: Dimens.margin_8),
        MyInkWell(
            onTap: () {
              showIdDetailsBottomSheet(context, name, description);
            },
            child: Icon(icon, color: AppColors.backgroundGrey700)),
      ],
    );
  }

  void showIdDetailsBottomSheet(
      BuildContext context, String name, String description) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimens.radius_16),
            topRight: Radius.circular(Dimens.radius_16),
          ),
        ),
        builder: (_) {
          return buildIdDetails(name, description);
        });
  }

  Widget buildIdDetails(String name, String description) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_32,
        Dimens.padding_16,
        Dimens.padding_16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: Get.context?.textTheme.titleLarge
                    ?.copyWith(color: AppColors.black),
              ),
              MyInkWell(
                onTap: () {
                  MRouter.pop(null);
                },
                child: const CircleAvatar(
                  backgroundColor: AppColors.backgroundGrey700,
                  radius: 12,
                  child: Icon(
                    Icons.close,
                    color: AppColors.backgroundWhite,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimens.margin_12),
          Text(
            description,
            style: Get.context?.textTheme.bodyLarge
                ?.copyWith(color: AppColors.backgroundGrey900),
          ),
          const SizedBox(height: Dimens.margin_12),
          buildSubmitButton(),
        ],
      ),
    );
  }

  Widget buildSubmitButton() {
    return RaisedRectButton(
      text: 'got_it'.tr,
      fontSize: Dimens.font_18,
      onPressed: () {
        MRouter.pop(null);
      },
    );
  }
}
