import 'dart:async';

import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ThanksFeedbackWidget extends StatefulWidget {
  const ThanksFeedbackWidget({Key? key}) : super(key: key);

  @override
  State<ThanksFeedbackWidget> createState() => _ThanksFeedbackWidgetState();
}

class _ThanksFeedbackWidgetState extends State<ThanksFeedbackWidget> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      MRouter.pop(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.margin_16,
            Dimens.padding_16, MediaQuery.of(context).viewInsets.bottom),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: MyInkWell(
                      onTap: () {
                        MRouter.pop(null);
                      },
                      child: SvgPicture.asset(
                          'assets/images/ic_close_circle.svg'))),
              Image.asset('assets/images/bigStar.png'),
              Text(
                'thanks_for_sharing_your_feedback'.tr,
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyText1?.copyWith(
                    color: AppColors.backgroundBlack,
                    fontSize: Dimens.font_28,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: Dimens.padding_36),
            ]));
  }
}
