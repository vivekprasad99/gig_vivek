import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HowAppWorksWidget extends StatelessWidget {
  const HowAppWorksWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(context),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      topPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
              isCollapsable: true,
              title: 'how_the_app_works'.tr,
            ),
          ];
        },
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16,
            Dimens.padding_48,
            Dimens.padding_16,
            Dimens.padding_16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/how_the_app_works.png',
                  width: Dimens.imageWidth_200, height: Dimens.imageHeight_200),
              Text(
                'how_the_app_works'.tr,
                style: Get.context?.textTheme.titleLarge
                    ?.copyWith(color: AppColors.black),
              ),
              const SizedBox(height: Dimens.margin_12),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.padding_8),
                child: Text(
                  'how_the_app_works_description'.tr,
                  textAlign: TextAlign.center,
                  style: Get.context?.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.backgroundGrey800),
                ),
              ),
              const SizedBox(height: Dimens.margin_36),
              RaisedRectButton(
                height: Dimens.btnHeight_40,
                text: 'see_demo_videos_work_better'.tr,
                onPressed: () {
                  MRouter.pushNamed(MRouter.demoVideosWidget, arguments: {});
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: Dimens.padding_16),
                child: MyInkWell(
                  onTap: (){
                    MRouter.pushNamed(MRouter.faqAndSupportWidget, arguments: {});
                  },
                  child: RichText(
                    text: TextSpan(
                      style: context.textTheme.bodyText1
                          ?.copyWith(color: AppColors.backgroundGrey800),
                      children: <TextSpan>[
                        const TextSpan(
                          text:
                          'Still have an ',
                        ),
                         TextSpan(
                            text: 'Unresolved Issue ?',
                            style: context.textTheme.bodyText1
                                ?.copyWith(color: AppColors.primaryMain),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
