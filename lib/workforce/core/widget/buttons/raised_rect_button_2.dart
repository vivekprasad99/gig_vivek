import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class RaisedRectButton2 extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final String? text;
  final String? svgIcon;
  final Icon? icon;
  final Icon? rightIcon;
  final double width;
  final double height;
  final double radius;
  final double textTBPadding;
  final double elevation;
  final VoidCallback? onPressed;
  final double? fontSize;
  final TextStyle? textStyle;
  ButtonStatus? buttonState;

  RaisedRectButton2({super.key,
    this.backgroundColor = AppColors.secondary,
    this.textColor = AppColors.backgroundWhite,
    this.borderColor = AppColors.transparent,
    this.text,
    this.svgIcon,
    this.icon,
    this.rightIcon,
    this.width = double.infinity,
    this.height = Dimens.btnHeight_48,
    this.radius = Dimens.radius_8,
    this.textTBPadding = Dimens.padding_8,
    this.elevation = 0,
    this.onPressed,
    this.buttonState,
    this.fontSize,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    String buttonText = text ?? '';
    if ((buttonState?.isLoading ?? false) &&
        buttonState?.message != null) {
      buttonText = buttonState!.message!;
    } else if ((buttonState?.isSuccess ?? false) &&
        buttonState?.message != null) {
      buttonText = buttonState!.message!;
    }
    return SizedBox(
      width: width,
      height: height,
      child: MaterialButton(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor),
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: elevation,
          splashColor: (buttonState?.isEnable) == false
              ? backgroundColor
              : AppColors.backgroundGrey500,
          color: (buttonState == null)
              ? backgroundColor
              : (buttonState!.isEnable ||
              buttonState!.isLoading ||
              buttonState!.isSuccess)
              ? backgroundColor
              : AppColors.backgroundGrey500,
          onPressed: () {
            if (onPressed != null && buttonState == null) {
              onPressed!();
            } else if (onPressed != null &&
                buttonState != null &&
                buttonState!.isEnable &&
                !buttonState!.isLoading &&
                !buttonState!.isSuccess) {
              onPressed!();
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: textTBPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildSvgIcon(),
                    buildIcon(),
                    buildLoadingWidget(buttonState),
                    buildSuccessWidget(buttonState),
                    Text(
                      buttonText,
                      overflow: TextOverflow.ellipsis,
                      style: Get.textTheme.bodyText1SemiBold!.copyWith(
                          color: textColor,
                          fontSize: fontSize ?? Dimens.font_14),
                    ),
                    buildRightIcon(),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget buildSvgIcon() {
    if (svgIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(right: Dimens.padding_8),
        child: SizedBox(
          width: Dimens.iconSize_16,
          height: Dimens.iconSize_16,
          child: SvgPicture.asset(
            svgIcon!,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildIcon() {
    if (icon != null) {
      return Padding(
        padding: const EdgeInsets.only(right: Dimens.padding_8),
        child: icon,
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildRightIcon() {
    if (rightIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(right: Dimens.padding_8),
        child: rightIcon,
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildLoadingWidget(ButtonStatus? buttonStatus) {
    if (buttonStatus?.isLoading ?? false) {
      return const Padding(
        padding: EdgeInsets.only(right: Dimens.padding_16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            backgroundColor: AppColors.grey,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildSuccessWidget(ButtonStatus? buttonStatus) {
    if (buttonStatus?.isSuccess ?? false) {
      return const Padding(
        padding: EdgeInsets.only(right: Dimens.padding_16),
        child: Icon(Icons.done, color: AppColors.backgroundWhite),
      );
    } else {
      return const SizedBox();
    }
  }
}
