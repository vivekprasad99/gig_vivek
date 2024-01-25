import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextFieldLabel extends StatelessWidget {
  final String label;
  final Color? color;
  final FontWeight? fontWeight;
  const TextFieldLabel({Key? key, required this.label, this.color, this.fontWeight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(color == null) {
      return Text(label, style: Get.context?.textTheme.bodyText2Medium?.copyWith(color: AppColors.backgroundBlack, fontWeight: fontWeight ?? FontWeight.w400));
    } else {
      return Text(label, style: Get.context?.textTheme.bodyText2Medium?.copyWith(color: color, fontWeight: fontWeight ?? FontWeight.w400));
    }
  }
}
