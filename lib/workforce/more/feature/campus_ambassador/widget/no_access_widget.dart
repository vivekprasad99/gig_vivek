import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class NoAccessWidget extends StatelessWidget {
  const NoAccessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            const DefaultAppBar(isCollapsable: true, title: ''),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Get.context!.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: Expanded(
        child: Align(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/ic_error_info.svg',
                height: Dimens.iconSize_40,
              ),
              const SizedBox(height: Dimens.margin_12),
              Text(
                "no_access".tr,
                style: Get.context?.textTheme.labelSmall?.copyWith(
                    color: AppColors.black,
                    fontSize: Dimens.font_16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Dimens.margin_12),
              Text(
                "you_dont_have_access_to_this_page".tr,
                style: Get.context?.textTheme.labelSmall?.copyWith(
                    color: AppColors.backgroundGrey800,
                    fontSize: Dimens.font_16,
                    fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
