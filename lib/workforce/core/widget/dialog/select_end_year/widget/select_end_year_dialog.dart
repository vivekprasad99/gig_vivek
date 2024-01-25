import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/custom_dialog.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

void showSelectEndYearDialog(
    BuildContext context, Function(int?) onYearTap) {
  showDialog<bool>(
    context: context,
    builder: (_) => CustomDialog(
      child: SelectEndYearDialog(onYearTap),
    ),
  );
}

class SelectEndYearDialog extends StatelessWidget {
  Function(int?) onYearTap;
  List<Widget> yearWidgetList = [];
  List<int> yearList = [];
  late int selectedYear;

  SelectEndYearDialog(this.onYearTap, {Key? key}) : super(key: key) {
    int year = DateTime.now().year;
    int maxYear = year;
    int minYear = year - 50;
    for (int i = minYear; i <= maxYear; i++) {
      yearWidgetList.add(Text('$i'));
      yearList.add(i);
    }
    selectedYear = yearList[yearWidgetList.length - 1];
  }

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
      children: [
        Container(
          color: context.theme.appBarColor,
          child: Stack(
            children: [
              buildTitle(context),
              buildCloseIcon(),
            ],
          ),
        ),
        buildYearPicker(),
        Container(
          color: context.theme.appBarColor,
          width: double.infinity,
          child: buildSetButton(context),
        ),
      ],
    );
  }

  Widget buildTitle(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: Dimens.margin_16),
        child: Text('choose_end_year'.tr,
            style:
            context.textTheme.headline7Bold.copyWith(color: AppColors.backgroundWhite)),
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

  Widget buildYearPicker() {
    return Container(
      height: 200,
      child: CupertinoPicker(
        backgroundColor: Colors.white,
        itemExtent: 25,
        diameterRatio: 1,
        useMagnifier: true,
        magnification: 1.3,
        squeeze: 2,
        scrollController:
        FixedExtentScrollController(initialItem: yearList.length - 1),
        children: yearWidgetList,
        onSelectedItemChanged: (value) {
          selectedYear = yearList[value];
        },
      ),
    );
  }

  Widget buildSetButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.padding_8),
        child: MyInkWell(
          onTap: () {
            onYearTap(selectedYear);
            MRouter.pop(null);
          },
          child: Padding(
            padding: const EdgeInsets.all(Dimens.padding_8),
            child: Text(
              'set'.tr,
              style:
              context.textTheme.bodyText1?.copyWith(color: AppColors.backgroundWhite),
            ),
          ),
        ),
      ),
    );
  }
}
