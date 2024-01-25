import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class YourLocationButton extends StatelessWidget {
  final Color textColor;
  final Color borderColor;
  final String? text;
  final double width;
  final double height;
  final double radius;
  final double textTBPadding;
  final VoidCallback? onPressed;

  const YourLocationButton({
    Key? key,
    this.textColor = AppColors.primaryMain,
    this.borderColor = AppColors.primaryMain,
    this.text,
    this.width = double.infinity,
    this.height = Dimens.btnHeight_48,
    this.radius = Dimens.radius_8,
    this.textTBPadding = Dimens.padding_8,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: MaterialButton(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor),
            borderRadius: BorderRadius.circular(radius),
          ),
          splashColor: AppColors.backgroundWhite,
          color: AppColors.backgroundWhite,
          elevation: 0,
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset("assets/images/ic_my_location.svg"),
              const SizedBox(width: Dimens.margin_8),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: textTBPadding,
                ),
                child: Text(
                  text ?? "",
                  style:
                      context.textTheme.bodyText2?.copyWith(color: textColor),
                ),
              ),
            ],
          )),
    );
  }
}
