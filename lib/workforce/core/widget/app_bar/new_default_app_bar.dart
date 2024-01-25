import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class NewDefaultAppBar extends StatelessWidget {
  static const appBarExpandedHeight = 200.0;
  static const appBarStaticHeight = 56.0;
  var top = 0.0;
  final bool isBackButton;
  final bool isActionButton;
  final bool isCollapsable;
  final String? title;
  final String? description;
  final String? image;

  NewDefaultAppBar(
      {Key? key,
      this.isBackButton = false,
      this.isActionButton = false,
      this.isCollapsable = false,
      this.title,
      this.description,
      this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isCollapsable) {
      return buildCollapsableAppBar();
    } else {
      return buildStaticAppBar();
    }
  }

  Widget buildStaticAppBar() {
    return Container(
      margin: const EdgeInsets.only(top: Dimens.margin_24),
      // height: appBarStaticHeight,
      child: Container(
        color: AppColors.backgroundWhite,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              0, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isBackButton)
                IconButton(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimens.padding_16),
                  icon: SvgPicture.asset('assets/images/arrow_left.svg'),
                  onPressed: () {
                    MRouter.pop(null);
                  },
                ),
              Text(
                  title ?? "",
                  style: Get.textTheme.headline6?.copyWith(color: AppColors.backgroundBlack)),
              const Spacer(),
              if (isActionButton) buildActions(),
              if (!isBackButton && !isActionButton)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimens.margin_24),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCollapsableAppBar() {
    return SliverAppBar(
      expandedHeight: appBarExpandedHeight,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0.0,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double percent = ((constraints.maxHeight - kToolbarHeight) *
              100 /
              (appBarExpandedHeight));
          double dx = 0;

          dx = 90 - percent;
          if(MediaQuery.of(context).devicePixelRatio < 3) {
            dx = 72 - percent;
          }

          top = constraints.biggest.height;

          // var dy = (constraints.maxHeight - 200 - kToolbarHeight < -100.0)
          //     ? -100.0
          //     : constraints.maxHeight - 200 - kToolbarHeight;
          // if (((constraints.maxHeight - 200 - kToolbarHeight < -100.0)
          //         ? -100.0
          //         : constraints.maxHeight - 200 - kToolbarHeight) <=
          //     -82) {
          //   dy = -85;
          //   dx = 20;
          var dy = (constraints.maxHeight - 200 - kToolbarHeight < -100.0)
              ? -100.0
              : constraints.maxHeight - 200 - kToolbarHeight;
          if (((constraints.maxHeight - 200 - kToolbarHeight < -100.0)
              ? -100.0
              : constraints.maxHeight - 200 - kToolbarHeight) <=
              -82) {
            dy = -82;
            dx = 28;
            if(MediaQuery.of(context).devicePixelRatio < 3) {
              dx = 20;
            }
          }
          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Container(
              color: AppColors.backgroundWhite,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: Dimens.padding_32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isBackButton)
                          IconButton(
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimens.margin_12),
                            icon: SvgPicture.asset(
                                'assets/images/arrow_left.svg'),
                            onPressed: () {
                              MRouter.pop(null);
                            },
                          ),
                        const Spacer(),
                        if (isActionButton) buildActions(),
                        if (!isBackButton && !isActionButton)
                          const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: Dimens.margin_24))
                      ],
                    ),
                    const SizedBox(height: Dimens.padding_48),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Transform.translate(
                                //   offset: Offset(
                                //       (dx + 10 < 40.0) ? dx + 10 : 40.0, dy),
                                //   child: Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: Dimens.padding_16),
                                //     child: Text(
                                //       title ?? "",
                                //       style: context.textTheme.headline4),
                                //   ),
                                // ),
                                Transform.translate(
                                  offset: Offset(
                                      (dx + 10 < 40.0) ? dx + 10 : 40.0, dy),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title ?? "",
                                              style: context.textTheme.headline4),
                                            AnimatedOpacity(
                                              duration: const Duration(milliseconds: 300),
                                              opacity: top <
                                                  MediaQuery.of(context).padding.top +
                                                      appBarExpandedHeight
                                                  ? 0.0
                                                  : 1.0,
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    0,
                                                    Dimens.padding_8,
                                                    Dimens.padding_16,
                                                    0),
                                                child: Text(
                                                  description ?? "",
                                                  style: context.textTheme.bodyText2?.copyWith(color: AppColors.backgroundGrey800),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (image != null)
                                        AnimatedOpacity(
                                          duration: const Duration(milliseconds: 300),
                                          opacity: top <
                                              MediaQuery.of(context).padding.top +
                                                  appBarExpandedHeight
                                              ? 0.0
                                              : 1.0,
                                          child: SvgPicture.asset(image!),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // if (image != null)
                          //   AnimatedOpacity(
                          //     duration: const Duration(milliseconds: 300),
                          //     opacity: top <
                          //             MediaQuery.of(context).padding.top +
                          //                 appBarExpandedHeight
                          //         ? 0.0
                          //         : 1.0,
                          //     child: SvgPicture.asset(image!),
                          //   ),
                          // const SizedBox(width: Dimens.padding_16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildActions() {
    if (isActionButton) {
      return Column(
        children: [
          PopupMenuButton<int>(
            icon: SvgPicture.asset('assets/images/ic_more.svg'),
            color: AppColors.backgroundWhite,
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    SvgPicture.asset("assets/images/help.svg"),
                    const SizedBox(
                      width: Dimens.margin_12,
                    ),
                    Text('help'.tr, style: Get.textTheme.headline5),
                    const SizedBox(
                      width: Dimens.margin_40,
                    ),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    SvgPicture.asset("assets/images/logout.svg"),
                    const SizedBox(
                      width: Dimens.margin_12,
                    ),
                    Text('logout'.tr, style: Get.textTheme.headline5),
                    const SizedBox(
                      width: Dimens.margin_40,
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (item) => selectedItem(item),
          ),
        ],
      );
    } else {
      return const SizedBox();
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
}
