import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../buttons/raised_rect_button.dart';

void showEnableLocationServiceBottomSheet(BuildContext context, Function onOKTapped) {
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
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.3,
        maxChildSize: 0.3,
        builder: (_, controller) {
          return EnableLocationServiceWidget(onOKTapped);
        },
      );
    },
  );
}

class EnableLocationServiceWidget extends StatelessWidget {
  final Function onOKTapped;
  const EnableLocationServiceWidget(this.onOKTapped, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: Column(
        children: [
          buildCloseIcon(),
          const SizedBox(height: Dimens.margin_16),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildLocationIcon(),
              buildTitleText(),
            ],
          ),
          const SizedBox(height: Dimens.padding_16),
          buildDescriptionText(),
          buildOKButton(),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
          child: SvgPicture.asset('assets/images/ic_close_circle.svg'),
        ),
      ),
    );
  }

  Widget buildLocationIcon() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: SvgPicture.asset("assets/images/ic_location.svg"),
    );
  }

  Widget buildTitleText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_8, 0, Dimens.padding_16, 0),
      child: Text(
        'enable_location'.tr,
        style: Get.textTheme.bodyText1SemiBold
            ?.copyWith(color: AppColors.backgroundBlack),
      ),
    );
  }

  Widget buildDescriptionText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text(
        'please_enable_your_location_in_order_to_work'.tr,
        style:
        Get.textTheme.bodyText2?.copyWith(color: AppColors.backgroundGrey800),
      ),
    );
  }

  Widget buildOKButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_32, Dimens.padding_24, Dimens.padding_32, 0),
      child: RaisedRectButton(
        text: 'ok'.tr,
        onPressed: () {
          MRouter.pop(null);
          onOKTapped();
        },
      ),
    );
  }
}
