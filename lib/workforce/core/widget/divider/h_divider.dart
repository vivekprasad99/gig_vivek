import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HDivider extends StatelessWidget {
  Color? dividerColor;
  double? dividerThickness;

  HDivider({Key? key, this.dividerColor, this.dividerThickness})
      : super(key: key) {
    dividerColor ??= Get.theme.dividerColor;
    dividerThickness ??= Dimens.dividerHeight_1;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: dividerThickness,
          ),
        ),
      ],
    );
  }
}
