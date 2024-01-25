import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoundButton extends StatelessWidget {
  final Function onTap;
  final String? iconUrl;
  final IconData? iconData;
  final Widget? customIcon;
  final String? text;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final double padding;

  const RoundButton({
    required this.onTap,
    this.iconUrl,
    this.iconData,
    this.customIcon,
    this.text,
    this.color,
    this.backgroundColor,
    this.size = 30.0,
    this.iconSize = 10.0,
    this.padding = 0.0,
  }) : assert((iconUrl != null) ^ (iconData != null) ^ (customIcon != null));

  @override
  Widget build(BuildContext context) {
    Widget? icon;
    if (iconUrl != null) {
      icon = SizedBox();
    } else if (iconData != null) {
      icon = Icon(
        iconData,
        size: iconSize,
        color: color ??
            (context.isDarkMode ? AppColors.backgroundWhite : AppColors.backgroundGrey800),
      );
    } else if (customIcon != null) {
      icon = customIcon!;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyInkWell(
          onTap: onTap,
          borderRadius: size + padding,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Material(
              color: backgroundColor ?? context.theme.dividerColor,
              shape: CircleBorder(),
              elevation: 10,
              child: SizedBox(
                width: size,
                height: size,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Dimens.padding_16),
                  child: icon,
                ),
              ),
            ),
          ),
        ),
        if (text != null) SizedBox(height: 8.0),
        if (text != null)
          SizedBox(
            width: 56.0,
            child: Text(
              text ?? "",
              textAlign: TextAlign.center,
              style: context.textTheme.button?.copyWith(
                color: AppColors.primaryMain,
                fontSize: 10.0,
              ),
            ),
          ),
      ],
    );
  }
}
