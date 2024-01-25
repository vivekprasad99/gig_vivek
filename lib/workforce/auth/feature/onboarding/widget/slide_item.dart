import 'package:awign/workforce/auth/feature/onboarding/widget/model/slide.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:simple_shadow/simple_shadow.dart';

class SlideItem extends StatelessWidget {
  final int index;

  const SlideItem(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget image = SimpleShadow(
        child: SvgPicture.asset(slideList[index].imageUrl),
        color: Colors.grey,
        sigma: Dimens.margin_8);
    if(index == 2) {
      // image = Image.asset('assets/images/onboarding_3.png');
      image = SimpleShadow(
            child: Image.asset('assets/images/onboarding_3.png'),
            color: Colors.grey,
            sigma: Dimens.margin_8);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SimpleShadow(
              //     child: SvgPicture.asset(slideList[index].imageUrl),
              //     color: Colors.grey,
              //     sigma: Dimens.margin_8),
              Flexible(child: image)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
          child: Text(slideList[index].title,
              textAlign: TextAlign.center,
              style: context.textTheme.headline5?.copyWith(color: AppColors.primary900)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
              Dimens.padding_12, Dimens.padding_16, Dimens.padding_64),
          child: Text(
            slideList[index].description,
            textAlign: TextAlign.center,
            style:
            context.textTheme.bodyText2
                ?.copyWith(color: AppColors.backgroundGrey800),
          ),
        )
      ],
    );
  }
}
