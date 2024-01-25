import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CustomTextIconButton extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final String? text;
  final String? svgIcon;
  final String? rightSideSvgIcon;
  final String? rightSideGIF;
  final double width;
  final double height;
  final double radius;
  final double textTBPadding;
  final double iconPadding;
  final IconData? iconData;
  final Color? iconColor;
  final double? iconSize;
  final TextStyle textStyle;
  final VoidCallback? onPressed;


  CustomTextIconButton(this.textStyle, {
    this.backgroundColor = AppColors.transparent,
    this.borderColor = AppColors.transparent,
    this.text,
    this.svgIcon,
    this.rightSideSvgIcon,
    this.rightSideGIF,
    this.width = double.infinity,
    this.height = Dimens.btnHeight_48,
    this.radius = Dimens.radius_8,
    this.textTBPadding = Dimens.padding_8,
    this.iconPadding = Dimens.padding_8,
    this.iconData,
    this.iconColor,
    this.iconSize  = Dimens.iconSize_12,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: Align(
        alignment: Alignment.centerLeft,
        child: MyInkWell(
          onTap: () {
            if(onPressed != null) {
              onPressed!();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: textTBPadding,
                  ),
                  child: Row(
                    children: [
                      buildSvgIcon(),
                      buildIcon(),
                      Text(
                        text ?? "",
                        style: textStyle,
                      ),
                      buildRightSideSvgIcon(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSvgIcon() {
    if(svgIcon != null) {
      return Padding(
        padding: EdgeInsets.only(right: iconPadding),
        child: SizedBox(
          width: Dimens.iconSize_16,
          height: Dimens.iconSize_16,
          child: SvgPicture.asset(
            svgIcon!,
            color: iconColor,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildRightSideSvgIcon() {
    if(rightSideSvgIcon != null) {
      return Padding(
        padding: EdgeInsets.only(right: iconPadding,top: Dimens.padding_8),
        child: SizedBox(
          width: Dimens.iconSize_40,
          height: Dimens.iconSize_40,
          child: SvgPicture.asset(
            rightSideSvgIcon!,
          ),
        ),
      );
    } else if (rightSideGIF != null && rightSideGIF!.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(right: iconPadding,top: Dimens.padding_8),
        child: SizedBox(
          width: Dimens.iconSize_100,
          height: Dimens.iconSize_100,
          child: Image.asset(
            rightSideGIF!,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildIcon() {
    if(iconData != null) {
      return Padding(
        padding: EdgeInsets.only(right: iconPadding),
        child: Icon(iconData, color: iconColor, size: iconSize),
      );
    } else {
      return const SizedBox();
    }
  }
}
