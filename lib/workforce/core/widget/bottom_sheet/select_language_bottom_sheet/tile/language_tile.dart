import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/model/language.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageTile extends StatelessWidget {
  final int index;
  final Languages language;
  final Function(int index, Languages language) onLanguageTap;

  const LanguageTile(
      {Key? key,
      required this.index,
      required this.language,
      required this.onLanguageTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
      child: Row(
        children: [
          Checkbox(
            value: language.isSelected,
            onChanged: (v) {
              onLanguageTap(index, language);
            },
          ),
          Text(language.name ?? '', style: Get.context?.textTheme.bodyText1)
        ],
      ),
    );
  }
}
