import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VDivider extends StatelessWidget {
  Color? dividerColor;
  double? dividerThickness;

  VDivider({Key? key, this.dividerColor, this.dividerThickness})
      : super(key: key) {
    dividerColor ??= Get.theme.dividerColor;
    dividerThickness ??= Dimens.dividerWidth_1;
  }

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      color: dividerColor,
      thickness: dividerThickness,
    );
  }
}
