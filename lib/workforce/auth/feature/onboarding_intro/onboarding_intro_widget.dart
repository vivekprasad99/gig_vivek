import 'package:awign/workforce/auth/feature/onboarding_intro/widget/model/onboarding_slide.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_onboarding_bottom_sheet/widget/select_onboarding_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:story/story_page_view.dart';

class OnboardingIntroWidget extends StatefulWidget {
  const OnboardingIntroWidget({Key? key}) : super(key: key);

  @override
  State<OnboardingIntroWidget> createState() => _OnboardingIntroWidgetState();
}

class _OnboardingIntroWidgetState extends State<OnboardingIntroWidget> {
  bool isCompleted = false;
  String? appLanguage;

  @override
  void initState() {
    super.initState();
    setData();
  }

  Future<void> setData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    appLanguage = spUtil?.getAppLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(context),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI(BuildContext context) {
    return  StoryPageView(
        indicatorHeight: 4,
        indicatorPadding :  const EdgeInsets.symmetric(vertical: Dimens.margin_56, horizontal: Dimens.margin_8),
        indicatorDuration: const Duration(seconds: 2),
        itemBuilder: (context, pageIndex, storyIndex) {
          final story = onboardingSlideList[storyIndex];
          return Container(
            color: story.color,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SvgPicture.asset(
                    story.imageUrl,
                  ),
                ),
                Positioned(
                  bottom: Dimens.margin_12,
                  right: 0,
                  left: 0,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: Dimens.padding_12),
                    child: Column(
                      children: [
                        Text(story.title ?? '',
                            textAlign: TextAlign.center,
                            style: Get.context!.textTheme.bodyText1Bold?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.backgroundWhite,
                                fontSize: Dimens.padding_28)),
                        const SizedBox(
                          height: Dimens.margin_20,
                        ),
                        Text(story.description ?? '',
                            textAlign: TextAlign.center,
                            style: Get.context!.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.backgroundWhite,
                                fontSize: Dimens.radius_16)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
        pageLength: 1,
        storyLength: (int pageIndex) {
          return onboardingSlideList.length;
        },
        onPageLimitReached: () {
          setState(() {
            isCompleted = !isCompleted;
          });
          showOnboardingBottomSheet(context, () {
            if (appLanguage != null && appLanguage!.isNotEmpty) {
              MRouter.pushNamedAndRemoveUntil(MRouter.loginScreenWidget);
            } else {
              MRouter.pushNamedAndRemoveUntil(MRouter.loginScreenWidget);
            }
          }, () {
            MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
          });
        },
    );
  }

}
