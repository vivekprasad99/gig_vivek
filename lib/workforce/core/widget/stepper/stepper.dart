import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CustomStepper extends StatelessWidget {
  final String icon1;
  final String? icon1Text;
  final Color? icon1TextColor;
  final Color? hDivider1;
  final String icon2;
  final String? icon2Text;
  final Color? icon2TextColor;
  final Color? hDivider2;
  final String? icon3Text;
  final Color? icon3TextColor;
  final String icon3;

  const CustomStepper(
      {Key? key,
      required this.icon1,
      this.icon1Text = "General",
      this.icon1TextColor = AppColors.textColor,
      this.hDivider1,
      required this.icon2,
      this.icon2Text = "Location",
      this.icon2TextColor = AppColors.textColor,
      this.hDivider2,
      required this.icon3,
      this.icon3Text = "Educational",
      this.icon3TextColor = AppColors.textColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.margin_56),
          child: Row(
            children: [
              SvgPicture.asset(icon1),
              Expanded(
                  child: HDivider(
                dividerColor: hDivider1,
                dividerThickness: Dimens.dividerHeight_3,
              )),
              SvgPicture.asset(icon2),
              Expanded(
                  child: HDivider(
                dividerColor: hDivider2,
                dividerThickness: Dimens.dividerHeight_3,
              )),
              SvgPicture.asset(icon3),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Dimens.padding_12, Dimens.padding_12, Dimens.padding_12, 0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  child: Center(
                    child: Text(
                      icon1Text ?? "",
                      style: Get.textTheme.caption?.copyWith(fontSize: Dimens.font_12,
                      fontWeight: (Get.textTheme.caption?.color != icon1TextColor) ? FontWeight.w700 : FontWeight.w400, color: icon1TextColor),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  child: Center(
                    child: Text(
                      icon2Text ?? "",
                      style: Get.textTheme.caption?.copyWith(fontSize: Dimens.font_12,
                          fontWeight: (Get.textTheme.bodyText2?.color != icon2TextColor) ? FontWeight.w700 : FontWeight.w400, color: icon2TextColor),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  child: Center(
                    child: Text(
                      icon3Text ?? "",
                      style: Get.textTheme.caption?.copyWith(fontSize: Dimens.font_12,
                          fontWeight: (Get.textTheme.bodyText2?.color != icon3TextColor) ? FontWeight.w700 : FontWeight.w400, color: icon3TextColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
