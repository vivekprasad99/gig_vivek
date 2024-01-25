import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/university/data/model/slide.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_shadow/simple_shadow.dart';

class UniversitySlideItem extends StatelessWidget {
  final int index;
  const UniversitySlideItem(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget image = SimpleShadow(
        color: AppColors.primaryMain,
        sigma: Dimens.margin_8,
        child: Image.network(universitySlideList[index].imageUrl,width: 350,fit: BoxFit.cover));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: Dimens.padding_80),
          child: Text('Awign',
              textAlign: TextAlign.center,
              style: context.textTheme.headline7?.copyWith(color: AppColors.backgroundWhite)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: Dimens.padding_8),
          child: Text('University',
              textAlign: TextAlign.center,
              style: context.textTheme.headline3?.copyWith(color: AppColors.backgroundWhite,fontWeight: FontWeight.w500)),
        ),
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
          child: Text(universitySlideList[index].title,
              textAlign: TextAlign.center,
              style: context.textTheme.headline6?.copyWith(color: AppColors.backgroundWhite)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Dimens.padding_48,
              Dimens.padding_12, Dimens.padding_48, Dimens.padding_12),
          child: Text(
            universitySlideList[index].description,
            textAlign: TextAlign.center,
            style:
            context.textTheme.bodyText1
                ?.copyWith(color: AppColors.backgroundWhite,fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }
}
