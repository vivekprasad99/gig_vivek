import 'dart:async';

import 'package:awign/workforce/auth/feature/onboarding/widget/model/slide.dart';
import 'package:awign/workforce/auth/feature/onboarding/widget/slide_dots.dart';
import 'package:awign/workforce/auth/feature/onboarding/widget/slide_item.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/browser_helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class OnBoardingWidget extends StatefulWidget {
  const OnBoardingWidget({Key? key}) : super(key: key);

  @override
  State<OnBoardingWidget> createState() => _OnBoardingWidgetState();
}

class _OnBoardingWidgetState extends State<OnBoardingWidget> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  String? appLanguage;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    setData();
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < slideList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(_currentPage,
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    });
  }

  Future<void> setData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    appLanguage = spUtil?.getAppLanguage();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    timer?.cancel();
  }

  _onPageChange(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _pageController,
                      onPageChanged: _onPageChange,
                      itemCount: slideList.length,
                      itemBuilder: (context, index) => SlideItem(index)),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: Dimens.margin_36),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < slideList.length; i++)
                        if (i == _currentPage)
                          const SlideDots(true)
                        else
                          const SlideDots(false)
                    ],
                  ),
                )
              ],
            ),
          ),
          Column(
            children: [
              buildContinueButton(),
              buildBottomTextContainer(),
              const SizedBox(height: Dimens.padding_16),
            ],
          )
        ],
      ),
    );
  }

  Widget buildContinueButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
        child: RaisedRectButton(
          text: 'get_started'.tr,
          onPressed: () {
            if (appLanguage != null && appLanguage!.isNotEmpty) {
              MRouter.pushNamedAndRemoveUntil(MRouter.phoneVerificationWidget);
            } else {
              // MRouter.pushNamedAndRemoveUntil(
              //     MRouter.appLanguageSelectionWidget);
              MRouter.pushNamedAndRemoveUntil(MRouter.phoneVerificationWidget);
            }
          },
        ),
      ),
    );
  }

  Widget buildBottomTextContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'by_continuing'.tr,
              style: context.textTheme.captionMedium?.copyWith(color: AppColors.primary700),
            ),
            const SizedBox(height: Dimens.margin_4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPrivacyPolicyText(),
                const SizedBox(width: Dimens.margin_4),
                Text(
                  'and'.tr,
                  style: context.textTheme.captionMedium?.copyWith(color: AppColors.primary700),
                ),
                const SizedBox(width: Dimens.margin_4),
                buildTermsAndConditionsText(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPrivacyPolicyText() {
    return MyInkWell(
      onTap: () {
        BrowserHelper.customTab(
            context, "https://www.awign.com/privacy_policy");
      },
      child: Text(
        'privacy_policy'.tr,
        style: context.textTheme.captionMediumUnderLine?.copyWith(color: AppColors.primaryMain)
      ),
    );
  }

  Widget buildTermsAndConditionsText() {
    return MyInkWell(
      onTap: () {
        BrowserHelper.customTab(
            context, "https://www.awign.com/terms_and_conditions");
      },
      child: Text(
        'terms_and_conditions'.tr,
        style: context.textTheme.captionMediumUnderLine?.copyWith(color: AppColors.primaryMain)
      ),
    );
  }
}
