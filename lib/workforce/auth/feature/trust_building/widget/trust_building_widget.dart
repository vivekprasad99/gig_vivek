import 'package:awign/workforce/auth/helper/auth_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/mobile_on_desktop_widget.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class TrustBuildingWidget extends StatefulWidget {
  const TrustBuildingWidget({Key? key}) : super(key: key);

  @override
  State<TrustBuildingWidget> createState() => _TrustBuildingWidgetState();
}

class _TrustBuildingWidgetState extends State<TrustBuildingWidget> {
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (_currentUser != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mobileWidget = buildMobileUI();
    return ScreenTypeLayout(
      mobile: mobileWidget,
      desktop: MobileOnDesktopWidget(mobileWidget),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      topPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            const DefaultAppBar(
              isCollapsable: true,
              isPopUpMenuVisible: true,
            ),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
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
            padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_32, Dimens.padding_16, Dimens.padding_32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // const SizedBox(width: 100, height: 100),
                Align(
                    alignment: Alignment.topLeft,
                    child: SvgPicture.asset(
                        'assets/images/ic_trust_building.svg')),
                const SizedBox(height: Dimens.padding_32),
                buildWelcomeMessageWidget(),
                const SizedBox(height: Dimens.padding_32),
                buildCardListViewWidgets(),
                const Spacer(),
                buildBottomWidgets(),
              ],
            )),
      ),
    );
  }

  Widget buildWelcomeMessageWidget() {
    String name = '';
    if ((_currentUser?.userProfile?.name ?? '').isNotEmpty) {
      name = (_currentUser?.userProfile?.name ?? ''.toTitleCase());
    }
    return RichText(
      text: TextSpan(
        style:
            context.textTheme.headline5?.copyWith(color: AppColors.primary600),
        children: <TextSpan>[
          TextSpan(
            text: 'glad_to_have_you_with_us'.tr,
          ),
          TextSpan(
            text: ' $name',
            style:
                context.textTheme.headline5?.copyWith(color: AppColors.link300),
          ),
          const TextSpan(
            text: '!',
          ),
        ],
      ),
    );
  }

  Widget buildCardListViewWidgets() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          buildCard1Widget(),
          const SizedBox(width: Dimens.padding_16),
          buildCard2Widget(),
        ],
      ),
    );
  }

  Widget buildCard1Widget() {
    return SizedBox(
      height: 200,
      width: 200,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_8)),
        ),
        color: AppColors.warning100,
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Emoji.briefcase,
                style:
                    Get.textTheme.bodyText1?.copyWith(fontSize: Dimens.font_24),
              ),
              const SizedBox(height: Dimens.padding_8),
              RichText(
                text: TextSpan(
                  style: context.textTheme.bodyText2
                      ?.copyWith(color: AppColors.backgroundGrey900),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'in_the_last_year_alone_we_have_helped'.tr,
                    ),
                    TextSpan(
                      text: ' 14,985 ',
                      style: context.textTheme.bodyText2Bold
                          ?.copyWith(color: AppColors.backgroundBlack),
                    ),
                    TextSpan(
                      text: 'people_switch_from_regular'.tr,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard2Widget() {
    return SizedBox(
      height: 200,
      width: 200,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_8)),
        ),
        color: AppColors.secondary2100,
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Emoji.dollarNote,
                style:
                    Get.textTheme.bodyText1?.copyWith(fontSize: Dimens.font_24),
              ),
              const SizedBox(height: Dimens.padding_8),
              RichText(
                text: TextSpan(
                  style: context.textTheme.bodyText2
                      ?.copyWith(color: AppColors.backgroundGrey900),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'with_an_average_pay_of'.tr,
                    ),
                    TextSpan(
                      text: ' ${Constants.rs}30,000 ',
                      style: context.textTheme.bodyText2Bold
                          ?.copyWith(color: AppColors.backgroundBlack),
                    ),
                    TextSpan(
                      text: 'per_month_people_have_improved'.tr,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBottomWidgets() {
    return Column(
      children: [
        buildHintText(),
        buildContinueButton(),
      ],
    );
  }

  Widget buildHintText() {
    return Text('tell_us_a_little_bit_about_your_preferences'.tr,
        textAlign: TextAlign.center,
        style: Get.textTheme.bodyText2
            ?.copyWith(color: AppColors.backgroundGrey900));
  }

  Widget buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.margin_20, 0, 0),
      child: RaisedRectButton(
        text: 'fill_my_work_preferences'.tr,
        onPressed: () async {
          SPUtil? spUtil = await SPUtil.getInstance();
          spUtil?.putIsTrustBuildingWidgetShown(true);
          UserData? currentUser = spUtil?.getUserData();
          if (currentUser != null) {
            AuthHelper.checkOnboardingStages(currentUser,
                isTrustBuildingWidgetShown: true);
          }
        },
      ),
    );
  }
}
