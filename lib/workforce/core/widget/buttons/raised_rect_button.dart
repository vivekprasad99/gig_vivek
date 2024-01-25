import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class RaisedRectButton extends StatelessWidget {
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
  BehaviorSubject<ButtonStatus>? buttonStatus;

  RaisedRectButton({
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
    this.buttonStatus,
    this.fontSize,
    this.textStyle,
  }) {
    buttonStatus ??
        BehaviorSubject<ButtonStatus>.seeded(ButtonStatus(isEnable: true));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ButtonStatus>(
        stream: buttonStatus?.stream,
        builder: (context, snapshot) {
          String buttonText = text ?? '';
          if ((snapshot.data?.isLoading ?? false) &&
              snapshot.data?.message != null) {
            buttonText = snapshot.data!.message!;
          } else if ((snapshot.data?.isSuccess ?? false) &&
              snapshot.data?.message != null) {
            buttonText = snapshot.data!.message!;
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
                splashColor: (snapshot.data?.isEnable) == false
                    ? backgroundColor
                    : AppColors.backgroundGrey500,
                color: (snapshot.data == null)
                    ? backgroundColor
                    : (snapshot.data!.isEnable ||
                            snapshot.data!.isLoading ||
                            snapshot.data!.isSuccess)
                        ? backgroundColor
                        : AppColors.backgroundGrey500,
                onPressed: () {
                  if (onPressed != null && snapshot.data == null) {
                    onPressed!();
                  } else if (onPressed != null &&
                      snapshot.data != null &&
                      snapshot.data!.isEnable &&
                      !snapshot.data!.isLoading &&
                      !snapshot.data!.isSuccess) {
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
                          buildLoadingWidget(snapshot.data),
                          buildSuccessWidget(snapshot.data),
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
        });
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
