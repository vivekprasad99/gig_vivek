import 'package:awign/packages/flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/custom_dialog.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomTimePickerDialog(
    BuildContext context, Function(DateTime?) onSelectTime) {
  showDialog<bool>(
    context: context,
    builder: (_) => CustomDialog(
      child: SelectTimeDialog(onSelectTime),
    ),
  );
}

class SelectTimeDialog extends StatelessWidget {
  final Function(DateTime?) onSelectTime;
  DateTime? dateTime;

  SelectTimeDialog(this.onSelectTime, {Key? key}) : super(key: key);

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: AppColors.backgroundWhite,
          child: Stack(
            children: [
              buildTitle(context),
            ],
          ),
        ),
        buildTimePicker(),
        Container(
          color: AppColors.backgroundWhite,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildCancelButton(context),
              buildSetTimeButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_24, Dimens.margin_24, Dimens.margin_24, 0),
      child: Text('select_time'.tr,
          style:
              context.textTheme.headline5?.copyWith(color: AppColors.primaryMain)),
    );
  }

  Widget buildTimePicker() {
    return Container(
      color: AppColors.backgroundWhite,
      child: TimePickerSpinner(
        isShowSeconds: true,
        normalTextStyle: Get.textTheme.bodyText1,
        highlightedTextStyle:
            Get.textTheme.bodyText1?.copyWith(color: AppColors.primaryMain),
        isForce2Digits: true,
        onTimeChange: (time) {
          dateTime = time;
        },
      ),
    );
  }

  Widget buildSetTimeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_12, Dimens.padding_8,
          Dimens.padding_24, Dimens.padding_16),
      child: MyInkWell(
        onTap: () {
          onSelectTime(dateTime);
          MRouter.pop(null);
        },
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_8),
          child: Text(
            'set_time'.tr,
            style:
                context.textTheme.bodyText1?.copyWith(color: AppColors.primaryMain),
          ),
        ),
      ),
    );
  }

  Widget buildCancelButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_24, Dimens.padding_8,
          Dimens.padding_12, Dimens.padding_16),
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_8),
          child: Text(
            'cancel'.tr,
            style: context.textTheme.bodyText1?.copyWith(color: AppColors.error400),
          ),
        ),
      ),
    );
  }
}
