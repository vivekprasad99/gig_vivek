import 'package:awign/workforce/auth/feature/onboarding/widget/slide_item.dart';
import 'package:awign/workforce/core/data/local/shared_preference_keys.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/university/data/model/slide.dart';
import 'package:awign/workforce/university/feature/awign_university/widget/university_slide_dots.dart';
import 'package:awign/workforce/university/feature/awign_university/widget/university_slide_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class OnboardingUniversityWidget extends StatefulWidget {
  const OnboardingUniversityWidget({Key? key}) : super(key: key);

  @override
  State<OnboardingUniversityWidget> createState() =>
      _OnboardingUniversityWidgetState();
}

class _OnboardingUniversityWidgetState
    extends State<OnboardingUniversityWidget> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
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
    return WillPopScope(
      onWillPop: () async {
        MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
        return true;
      },
      child: AppScaffold(
        backgroundColor: AppColors.primaryMain,
        body: Column(children: [
          Expanded(
            child: Column(children: [
              Expanded(
                  child: PageView.builder(
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                onPageChanged: _onPageChange,
                itemCount: universitySlideList.length,
                itemBuilder: (BuildContext context, int index) =>
                    UniversitySlideItem(index),
              )),
              Container(
                margin: const EdgeInsets.only(bottom: Dimens.margin_16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < universitySlideList.length; i++)
                      if (i == _currentPage)
                        const UniversitySlideDots(true)
                      else
                        const UniversitySlideDots(false)
                  ],
                ),
              ),
            ]),
          ),
          if(_currentPage == 0)
              buildContinueButton('next'.tr,1,AppColors.backgroundWhite,AppColors.primaryMain)!
          else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildContinueButton('back'.tr,_currentPage-1,AppColors.primaryMain,AppColors.backgroundWhite)!
                    ),
                    const SizedBox(
                      width: Dimens.padding_16,
                    ),
                    Expanded(
                      child: buildContinueButton(_currentPage == 2 ? 'start_learning'.tr : 'next'.tr,_currentPage+1,AppColors.backgroundWhite,AppColors.primaryMain)!
                    ),
                  ],
                )
        ]),
      ),
    );
  }

  Widget? buildContinueButton(String name,int page,Color backgroundColor,Color textColor) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_16,
              Dimens.padding_16, Dimens.padding_20),
          child: RaisedRectButton(
            text: name,
            backgroundColor: backgroundColor,
            textColor:textColor,
            borderColor: textColor,
            onPressed: () async{
              if(name == 'start_learning'.tr)
                {
                  SPUtil? spUtil = await SPUtil.getInstance();
                  spUtil?.putBool(SPKeys.showAwignUniversity, true);
                  MRouter.pushReplacementNamed(MRouter.universityWidget);
                }else{
                _pageController.jumpToPage(page);
              }
            },
          ),
        );
      }
  }
