import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/application_question/application_question_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../buttons/raised_rect_button.dart';

void showSelectCameraOrGalleryBottomSheet(
    BuildContext context, Function(UploadFromOptionEntity?) onSelectOption) {
  showModalBottomSheet(
    context: context,
    // isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return SelectCameraOrGalleryWidget(onSelectOption);
          },
        ),
      );
    },
  );
}

class SelectCameraOrGalleryWidget extends StatefulWidget {
  final Function(UploadFromOptionEntity?) onSelectOption;

  const SelectCameraOrGalleryWidget(this.onSelectOption, {Key? key})
      : super(key: key);

  @override
  State<SelectCameraOrGalleryWidget> createState() =>
      SelectCameraOrGalleryWidgetState();
}

class SelectCameraOrGalleryWidgetState
    extends State<SelectCameraOrGalleryWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildCloseIcon(),
            buildTakePhotoWidget(),
            const SizedBox(height: Dimens.padding_16),
            buildChooseFromGalleryWidget(),
          ],
        ),
      ),
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
          widget.onSelectOption(null);
        },
        child: const Padding(
          padding: EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16, 0, Dimens.padding_16),
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildTakePhotoWidget() {
    return RaisedRectButton(
      text: 'take_a_photo'.tr,
      height: Dimens.btnHeight_40,
      backgroundColor: AppColors.primaryMain,
      onPressed: () {
        MRouter.pop(null);
        widget.onSelectOption(UploadFromOptionEntity.camera);
      },
    );
  }

  Widget buildChooseFromGalleryWidget() {
    return RaisedRectButton(
        text: 'choose_from_gallery'.tr,
        height: Dimens.btnHeight_40,
        backgroundColor: AppColors.transparent,
        borderColor: AppColors.primaryMain,
        textColor: AppColors.primaryMain,
        onPressed: () {
          MRouter.pop(null);
          widget.onSelectOption(UploadFromOptionEntity.gallery);
        });
  }
}
