import 'dart:io';

import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/circle_avatar/custom_circle_avatar.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DefaultAppBar extends StatelessWidget {
  static const appBarExpandedHeight = 116.0;
  final bool isCollapsable;
  final bool isActionVisible;
  final bool isShareVisible;
  final bool isAvatarVisible;
  final bool isNudgeVisibleAroundCircularAvatar;
  final bool isNudgeVisible;
  final bool? isUserLoggedIn;
  final bool isPopUpMenuVisible;
  final int? nudgeValue;
  final String? title;
  final String? leadingURL;
  final String? profileURL;
  final String? name;
  final Widget? headerWidget;
  final Function()? onDownloadTap;
  final Function()? onShareTap;

  const DefaultAppBar(
      {this.isCollapsable = false,
      this.isActionVisible = false,
      this.isShareVisible = false,
      this.isAvatarVisible = false,
      this.isNudgeVisibleAroundCircularAvatar = false,
      this.isNudgeVisible = false,
      this.isUserLoggedIn,
      this.isPopUpMenuVisible = false,
      this.nudgeValue,
      this.title,
      this.leadingURL,
      this.profileURL,
      this.name,
      this.headerWidget,
      this.onDownloadTap,
      this.onShareTap});

  @override
  Widget build(BuildContext context) {
    if (isCollapsable) {
      return buildCollapsableAppBar();
    } else {
      return buildStaticAppBar();
    }
  }

  Widget buildStaticAppBar() {
    return Container();
  }

  Widget buildCollapsableAppBar() {
    Widget circleAvatar = const SizedBox();
    if (isAvatarVisible) {
      double topPadding = Dimens.padding_56;
      if (MediaQuery.of(Get.context!).devicePixelRatio < 3) {
        topPadding = Dimens.padding_28;
      }
      if (isNudgeVisibleAroundCircularAvatar) {
        circleAvatar = Padding(
          padding: EdgeInsets.only(
              left: Dimens.padding_16,
              top: topPadding,
              bottom: Dimens.padding_16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularPercentIndicator(
                radius: Dimens.radius_40,
                lineWidth: 5.0,
                percent: (nudgeValue ?? 20) / 100,
                progressColor: AppColors.success300,
                backgroundColor: AppColors.primary50,
              ),
              CustomCircleAvatar(
                  url: profileURL ??
                      "https://awign-production.s3.ap-south-1.amazonaws.com/awign/defaults/icons/${name?.substring(0, 1).toLowerCase() ?? 'z'}.png",
                  name: name),
            ],
          ),
        );
      } else {
        circleAvatar = Padding(
          padding: EdgeInsets.only(
              left: Dimens.padding_16,
              top: topPadding,
              bottom: Dimens.padding_16),
          child: CustomCircleAvatar(
              url: profileURL ??
                  "https://awign-production.s3.ap-south-1.amazonaws.com/awign/defaults/icons/${name?.substring(0, 1).toLowerCase() ?? 'z'}.png",
              name: name),
        );
      }
    }
    return SliverAppBar(
      expandedHeight: appBarExpandedHeight,
      floating: false,
      pinned: true,
      elevation: 0.0,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double percent = ((constraints.maxHeight - kToolbarHeight) *
              100 /
              (appBarExpandedHeight));
          double dx = 0;

          var dy = constraints.maxHeight - kToolbarHeight - 12;
          if (MediaQuery.of(context).devicePixelRatio < 3) {
            dx = 80 - percent;
            if (dy <= 20) {
              dy = 20;
            }
            if (dx >= 42) {
              dx = 42;
            }
          } else if (Platform.isAndroid) {
            dx = 100 - percent;
            if (dy <= 28) {
              dy = 28;
            }
            if (dx >= 42) {
              dx = 42;
            }
          } else {
            dx = 100 - percent;
            if (dy <= 42) {
              dy = 42;
            }
            if (dx >= 42) {
              dx = 42;
            }
          }
          double opacity = constraints.biggest.height <
                  MediaQuery.of(context).padding.top + appBarExpandedHeight
              ? 0.0
              : 1.0;
          return Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: kToolbarHeight / 3.5, left: Dimens.padding_8),
                child: Transform.translate(
                  offset: Offset(dx, dy + 4),
                  child: Row(
                    children: [
                      buildLeadingIcon(),
                      buildTitle(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: kToolbarHeight / 3.5, left: Dimens.padding_8),
                child: buildHeaderTranslateWidget(dx, dy, opacity),
              ),
              /*buildDownloadOIcon(opacity),*/
              circleAvatar,
              if (isNudgeVisible)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 48.0, bottom: 12.0),
                    child: CircularPercentIndicator(
                      radius: Dimens.radius_20,
                      lineWidth: 4.0,
                      percent: (nudgeValue ?? 20) / 100,
                      center: Text(
                        "$nudgeValue%",
                        style: Get.context?.textTheme.captionMedium
                            ?.copyWith(color: AppColors.backgroundWhite),
                      ),
                      progressColor: AppColors.success300,
                      backgroundColor: AppColors.primary50,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      actions: buildActions(),
    );
  }

  Widget buildTitle() {
    if (title != null) {
      return Flexible(
        child: Padding(
          padding: EdgeInsets.only(
              left: foundation.defaultTargetPlatform == TargetPlatform.iOS
                  ? Dimens.padding_16
                  : 0),
          child: Text(
            title ?? '',
            overflow: TextOverflow.ellipsis,
            style: Get.context?.textTheme.headline6SemiBold
                ?.copyWith(color: AppColors.backgroundWhite),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildNotification() {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.only(
            right: foundation.defaultTargetPlatform == TargetPlatform.iOS
                ? Dimens.padding_16
                : 0),
        child: Text(
          title ?? '',
          overflow: TextOverflow.ellipsis,
          style: Get.context?.textTheme.headline6SemiBold
              ?.copyWith(color: AppColors.backgroundWhite),
        ),
      ),
    );
  }

  Widget buildLeadingIcon() {
    if (leadingURL != null) {
      return Padding(
        padding: const EdgeInsets.only(right: Dimens.padding_16),
        child: CustomCircleAvatar(url: leadingURL, radius: Dimens.radius_16),
      );
    } else {
      return const SizedBox();
    }
  }

  List<Widget> buildActions() {
    if (isActionVisible) {
      return [
        MyInkWell(
          onTap: () {
            (isUserLoggedIn ?? false)
                ? MRouter.pushNamed(MRouter.notificationWidget)
                : MRouter.pushNamed(MRouter.phoneVerificationWidget);
          },
          child: Padding(
            padding: const EdgeInsets.only(
                top: Dimens.padding_24, right: Dimens.padding_24),
            child: isUserLoggedIn == null
                ? const SizedBox()
                : isUserLoggedIn!
                    ? SvgPicture.asset('assets/images/ic_notification.svg',
                        color: AppColors.backgroundWhite)
                    : Container(
                        width: 54,
                        padding: const EdgeInsets.all(Dimens.padding_4),
                        margin: const EdgeInsets.all(Dimens.padding_4),
                        decoration: const BoxDecoration(
                            color: AppColors.backgroundBlack,
                            borderRadius: BorderRadius.all(
                                Radius.circular(Dimens.radius_16))),
                        child: Center(
                            child: Text('login'.tr,
                                style: Get.textTheme.bodySmall?.copyWith(
                                    color: AppColors.backgroundWhite))),
                      ),
          ),
        )
      ];
    } else if (isShareVisible && onShareTap != null) {
      return [
        MyInkWell(
          onTap: () {
            onShareTap!();
          },
          child: Padding(
            padding: const EdgeInsets.only(
                top: Dimens.padding_24, right: Dimens.padding_24),
            child: SvgPicture.asset('assets/images/ic_share.svg',
                color: AppColors.backgroundWhite),
          ),
        )
      ];
    } else if (isPopUpMenuVisible) {
      return [
        PopupMenuButton<int>(
          color: Get.theme.backgroundColor,
          icon: SvgPicture.asset('assets/images/ic_more.svg',
              color: AppColors.backgroundWhite),
          itemBuilder: (context) => [
            // PopupMenuItem<int>( Temporary hide this
            //     value: 0,
            //     child: Text('help'.tr, style: Get.textTheme.headline5),
            // ),
            // const PopupMenuDivider(),
            PopupMenuItem<int>(
              value: 1,
              child: Text('logout'.tr, style: Get.textTheme.bodyText1SemiBold),
            ),
          ],
          onSelected: (item) => selectedItem(item),
        )
      ];
    } else {
      return [const SizedBox()];
    }
  }

  void selectedItem(item) {
    switch (item) {
      case 0:
        break;
      case 1:
        Helper.doLogout();
        break;
    }
  }

  Widget buildHeaderTranslateWidget(double dx, double dy, double opacity) {
    if (headerWidget != null) {
      return Transform.translate(
        child: headerWidget,
        offset: Offset(dx, dy),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildDownloadOIcon(double opacity) {
    if (onDownloadTap != null) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
              Dimens.padding_16, Dimens.padding_8, Dimens.padding_16),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: opacity,
            child: MyInkWell(
              onTap: () {
                onDownloadTap!();
              },
              child: const Padding(
                padding: EdgeInsets.all(Dimens.padding_8),
                child: Icon(Icons.download, color: AppColors.backgroundWhite),
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
