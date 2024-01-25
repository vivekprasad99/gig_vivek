import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showWorkAssignedBottomBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return const WorkAssignedBottomSheetWidget();
    },
  );
}

class WorkAssignedBottomSheetWidget extends StatefulWidget {
  const WorkAssignedBottomSheetWidget({Key? key}) : super(key: key);

  @override
  State<WorkAssignedBottomSheetWidget> createState() =>
      WorkAssignedBottomSheetWidgetState();
}

class WorkAssignedBottomSheetWidgetState
    extends State<WorkAssignedBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildCloseIcon(),
          buildIcon(),
          const SizedBox(height: Dimens.padding_16),
          buildTitle(),
          buildSubTitle(),
          buildGotItButton(),
        ],
      ),
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
            Dimens.padding_16, Dimens.padding_16),
        child: MyInkWell(
          onTap: () {
            MRouter.pop(null);
          },
          child: const Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildIcon() {
    return SvgPicture.asset(
      'assets/images/ic_work_assigned.svg',
    );
  }

  Widget buildTitle() {
    return Text(
      'work_assigned'.tr,
      textAlign: TextAlign.center,
      style: Get.textTheme.headline6,
    );
  }

  Widget buildSubTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Text(
        'work_has_been_assigned_to_you_please_start_working'.tr,
        textAlign: TextAlign.center,
        style: Get.textTheme.bodyText2
            ?.copyWith(color: AppColors.backgroundGrey800),
      ),
    );
  }

  Widget buildGotItButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
          Dimens.padding_16, Dimens.padding_32),
      child: RaisedRectButton(
        text: 'got_it'.tr,
        elevation: 0,
        onPressed: () {
          MRouter.pop(null);
        },
      ),
    );
  }
}
