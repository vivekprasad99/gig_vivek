import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showOnlineTestExitBottomSheet(BuildContext context, Function() onExitTap) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return OnlineTestExitBottomSheetWidget(onExitTap);
    },
  );
}

class OnlineTestExitBottomSheetWidget extends StatefulWidget {
  final Function() onExitTap;

  const OnlineTestExitBottomSheetWidget(this.onExitTap, {Key? key})
      : super(key: key);

  @override
  _SelectSignatureWidgetState createState() => _SelectSignatureWidgetState();
}

class _SelectSignatureWidgetState
    extends State<OnlineTestExitBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildCloseIcon(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: Dimens.padding_24),
            child: Text(
              'are_you_sure_you_want_to_quit'.tr,
              textAlign: TextAlign.center,
              style:
                  Get.textTheme.headline5?.copyWith(color: AppColors.backgroundWhite),
            ),
          ),
          buildExitButton(),
          buildCancelButton(),
        ],
      ),
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
          child: Icon(Icons.close, color: AppColors.backgroundWhite),
        ),
      ),
    );
  }

  Widget buildExitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.margin_32, Dimens.margin_16, 0),
      child: RaisedRectButton(
        text: 'yes_i_want_to_quit'.tr,
        backgroundColor: AppColors.error400,
        onPressed: () {
          widget.onExitTap();
        },
      ),
    );
  }

  Widget buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_16,
          Dimens.margin_16, Dimens.margin_16),
      child: CustomTextButton(
        text: 'cancel'.tr,
        backgroundColor: AppColors.transparent,
        borderColor: AppColors.grey,
        onPressed: () {
          MRouter.pop(null);
        },
      ),
    );
  }
}
