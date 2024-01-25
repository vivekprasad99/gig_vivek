import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/model/language.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectedLanguageTile extends StatelessWidget {
  final int index;
  final Languages language;

  const SelectedLanguageTile(
      {Key? key,
        required this.index,
        required this.language})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.padding_8),
      child: Text(language.name ?? '', style: Get.context?.textTheme.bodyText1),
    );
  }
}
