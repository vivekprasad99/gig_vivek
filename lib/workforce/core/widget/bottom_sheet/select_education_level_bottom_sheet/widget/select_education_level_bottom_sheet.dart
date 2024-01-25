import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_education_level_bottom_sheet/cubit/select_education_level_cubit.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final _selectEducationLevelCubit = sl<SelectEducationLevelCubit>();

void showSelectEducationLevelBottomSheet(BuildContext context, Function(String?) onSubmitTap) {
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
        builder: (_, controller) {
          return Column(
            children: [
              buildCloseIcon(),
              buildEducationLevelRadioButtons(controller),
              buildSubmitButton(onSubmitTap),
            ],
          );
        },
      );
    },
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

Widget buildEducationLevelRadioButtons(ScrollController scrollController) {
  return Flexible(
    child: SingleChildScrollView(
      controller: scrollController,
      child: StreamBuilder<int?>(
        stream: _selectEducationLevelCubit.selectedEducationLevel,
        builder: (context, selectedWorkedBefore) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_12),
            child: Column(
              children: [
                Row(
                  children: [
                    Radio<int?>(
                      value: 1,
                      groupValue: selectedWorkedBefore.data,
                      onChanged:
                      _selectEducationLevelCubit.changeSelectedEducationLevel,
                    ),
                    Text('below_10th'.tr, style: Get.context?.textTheme.bodyText1)
                  ],
                ),
                Row(
                  children: [
                    Radio<int?>(
                      value: 2,
                      groupValue: selectedWorkedBefore.data,
                      onChanged:
                      _selectEducationLevelCubit.changeSelectedEducationLevel,
                    ),
                    Text('10th_pass'.tr, style: Get.context?.textTheme.bodyText1)
                  ],
                ),
                Row(
                  children: [
                    Radio<int?>(
                      value: 3,
                      groupValue: selectedWorkedBefore.data,
                      onChanged:
                      _selectEducationLevelCubit.changeSelectedEducationLevel,
                    ),
                    Text('12th_pass'.tr, style: Get.context?.textTheme.bodyText1)
                  ],
                ),
                Row(
                  children: [
                    Radio<int?>(
                      value: 4,
                      groupValue: selectedWorkedBefore.data,
                      onChanged:
                      _selectEducationLevelCubit.changeSelectedEducationLevel,
                    ),
                    Text('pursuing_graduation'.tr, style: Get.context?.textTheme.bodyText1)
                  ],
                ),
                Row(
                  children: [
                    Radio<int?>(
                      value: 5,
                      groupValue: selectedWorkedBefore.data,
                      onChanged:
                      _selectEducationLevelCubit.changeSelectedEducationLevel,
                    ),
                    Text('graduate'.tr, style: Get.context?.textTheme.bodyText1)
                  ],
                ),
                Row(
                  children: [
                    Radio<int?>(
                      value: 6,
                      groupValue: selectedWorkedBefore.data,
                      onChanged:
                      _selectEducationLevelCubit.changeSelectedEducationLevel,
                    ),
                    Text('post_graduate'.tr, style: Get.context?.textTheme.bodyText1)
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

Widget buildSubmitButton(Function(String?) onSubmitTap) {
  return Padding(
    padding: const EdgeInsets.all(Dimens.padding_24),
    child: RaisedRectButton(
      text: 'submit'.tr,
      onPressed: () {
        var educationLevel = _selectEducationLevelCubit.educationLevel;
        onSubmitTap(educationLevel);
        MRouter.pop(null);
      },
    ),
  );
}