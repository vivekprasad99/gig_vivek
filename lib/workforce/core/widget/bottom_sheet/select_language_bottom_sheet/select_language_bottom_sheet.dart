import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/cubit/select_language_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/model/language.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/tile/language_tile.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

final _selectLanguageCubit = sl<SelectLanguageCubit>();

void showSelectLanguageBottomSheet(BuildContext context, Function() onSubmitTap) {
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
              buildLanguageList(controller),
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

Widget buildLanguageList(ScrollController scrollController) {
  return StreamBuilder<List<Languages>>(
    stream: _selectLanguageCubit.languageListStream,
    builder: (context, languageList) {
      if (languageList.hasData) {
        return Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: languageList.data?.length,
            itemBuilder: (_, i) {
              return LanguageTile(
                index: i,
                language: languageList.data![i],
                onLanguageTap: (index, language) {
                  _selectLanguageCubit.updateLanguageList(index, language);
                },
              );
            },
          ),
        );
      } else {
        return AppCircularProgressIndicator();
      }
    },
  );
}

Widget buildSubmitButton(Function() onSubmitTap) {
  return Padding(
    padding: const EdgeInsets.all(Dimens.padding_24),
    child: RaisedRectButton(
      text: 'submit'.tr,
      onPressed: () {
        onSubmitTap();
        MRouter.pop(null);
      },
    ),
  );
}
