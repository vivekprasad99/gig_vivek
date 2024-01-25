import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/custom_dialog.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

void showSelectCameraOrGalleryDialog(
    BuildContext context, Function(UploadFromOption?) onSelectUploadFrom) {
  showDialog<bool>(
    context: context,
    builder: (_) => CustomDialog(
      child: SelectCameraOrGalleryDialog(onSelectUploadFrom),
    ),
  );
}

class SelectCameraOrGalleryDialog extends StatelessWidget {
  final Function(UploadFromOption?) onSelectUploadFrom;

  const SelectCameraOrGalleryDialog(this.onSelectUploadFrom, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_32)),
      ),
      child: InternetSensitive(
        child: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimens.padding_8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildTitle(context),
              buildCloseIcon(),
            ],
          ),
          buildCameraText(context),
          buildGalleryText(context),
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Dimens.padding_16),
      child: Text('choose'.tr, style: context.textTheme.headline7Bold),
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: const Padding(
          padding: EdgeInsets.all(Dimens.padding_16),
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildCameraText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimens.padding_16, vertical: Dimens.padding_8),
      child: MyInkWell(
        onTap: () {
          onSelectUploadFrom(UploadFromOption.camera);
        },
        child: Text('take_photo'.tr, style: context.textTheme.bodyText1),
      ),
    );
  }

  Widget buildGalleryText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimens.padding_16, vertical: Dimens.padding_8),
      child: MyInkWell(
        onTap: () {
          onSelectUploadFrom(UploadFromOption.gallery);
        },
        child: Text('pick_from_gallery'.tr, style: context.textTheme.bodyText1),
      ),
    );
  }
}
