import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_actions.dart';
import 'package:awign/workforce/core/data/model/navigation_item.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/bottom_navigation/cubit/bottom_navigation_cubit.dart';
import 'package:awign/workforce/core/widget/take_a_tour/cubit/take_a_tour_cubit.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../data/local/repository/logging_event/helper/logging_events.dart';
import '../take_a_tour/take_a_tour.dart';
import '../take_a_tour/tour_keys.dart';

class WithBottomNavigation extends StatelessWidget {
  final Widget? child;
  final Widget? Function(BuildContext)? builder;

  WithBottomNavigation({Key? key, this.child, this.builder})
      : assert((child != null) ^ (builder != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    sl<BottomNavigationCubit>().loadNavigationItem();
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 46),
          child: child ?? builder!(context),
        ),
        Hero(
          tag: 'BottomNavigation',
          child: BlocProvider.value(
            value: sl<BottomNavigationCubit>(),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: defaultTargetPlatform == TargetPlatform.iOS
                        ? Dimens.bottomNavBarHeight + Dimens.padding_16
                        : Dimens.bottomNavBarHeight,
                    decoration: BoxDecoration(
                      color: context.theme.navBarColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: SizedBox(width: context.width),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  width: context.width,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: defaultTargetPlatform == TargetPlatform.iOS
                            ? Dimens.padding_16
                            : 0),
                    child: StreamBuilder<List<NavigationItem>>(
                        stream:
                            sl<BottomNavigationCubit>().navigationItemsStream,
                        builder: (context, navigationItemsStream) {
                          if (navigationItemsStream.hasData &&
                              navigationItemsStream.data != null) {
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0;
                                    i < navigationItemsStream.data!.length;
                                    i++) ...[
                                  TourKeys.navigationNameList.contains(
                                              navigationItemsStream
                                                  .data![i].text) &&
                                          TourKeys.loginCount == 1 &&
                                          navigationItemsStream.data![i].text !=
                                              'university'.tr
                                      ? TakeATourWidget(
                                          globalKey: TourKeys.tourKeysList[i],
                                          buildShowContainer:
                                              TourKeys.navigationWidgetList[i],
                                          child: _NavigationWidget(
                                              navigationItemsStream.data![i]),
                                        )
                                      : _NavigationWidget(
                                          navigationItemsStream.data![i]),
                                ]
                              ],
                            );
                          } else {
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0;
                                    i <
                                        sl<BottomNavigationCubit>()
                                            .navigationItems
                                            .length;
                                    i++) ...[
                                  TourKeys.navigationNameList.contains(
                                              sl<BottomNavigationCubit>()
                                                  .navigationItems[i]
                                                  .text) &&
                                          TourKeys.loginCount == 1 &&
                                          sl<BottomNavigationCubit>()
                                                  .navigationItems[i]
                                                  .text !=
                                              'university'.tr
                                      ? TakeATourWidget(
                                          globalKey: TourKeys.tourKeysList[i],
                                          buildShowContainer:
                                              TourKeys.navigationWidgetList[i],
                                          child: _NavigationWidget(
                                              sl<BottomNavigationCubit>()
                                                  .navigationItems[i]),
                                        )
                                      : _NavigationWidget(
                                          sl<BottomNavigationCubit>()
                                              .navigationItems[i]),
                                ]
                              ],
                            );
                          }
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NavigationWidget extends StatelessWidget {
  final NavigationItem item;

  const _NavigationWidget(this.item);

  @override
  Widget build(BuildContext context) {
    final TakeATourCubit tourCubit = sl<TakeATourCubit>();
    return StreamBuilder<bool>(
        stream: tourCubit.isSelected,
        builder: (context, bottomNavigation) {
          if (bottomNavigation.hasData) {
            return buildItemWithGifUrl(bottomNavigation.data!);
          } else {
            return buildItemWithGifUrl(false);
          }
        });
  }

  Widget buildItemWithGifUrl(bool isSelected) {
    print("asdf " + item.gifUrl.toString());
    if (item.gifUrl == null) {
      return buildBottomNavigation(isSelected);
    } else {
      return Stack(alignment: Alignment.topCenter, children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: buildBottomNavigation(isSelected),
        ),
        SizedBox(
          height: Dimens.iconSize_40,
          width: Dimens.iconSize_40,
          child: Image.asset(
            item.gifUrl!,
          ),
        ),
      ]);
    }
  }

  Widget buildBottomNavigation(bool isSelected) {
    return BlocBuilder<BottomNavigationCubit, String>(
      builder: (context, state) {
        print('state ==> ' + state.toString());
        final selected = state == item.navigateTo;
        //final color = selected ? AppColors.secondary : AppColors.coolGray3;
        final color = selected || isSelected!
            ? AppColors.secondary
            : Get.isDarkMode
                ? AppColors.backgroundGrey200
                : AppColors.backgroundGrey600;
        Widget icon;
        if (item.iconUrl != null && item.iconUrl!.isNotEmpty) {
          icon = SvgPicture.asset(
            item.iconUrl!,
            width: 24,
            height: 24,
            color: color,
          );
        } else {
          icon = const SizedBox();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Material(
            //elevation: 10,
            color: AppColors.transparent,
            child: InkWell(
              onTap: selected
                  ? null
                  : () {
                      String event = '';
                      String action = '';
                      switch (item.navigateTo) {
                        case MRouter.categoryListingWidget:
                          event = LoggingEvents.exploreTabClicked;
                          break;
                        case MRouter.officeWidget:
                          event = LoggingEvents.officeTabClicked;
                          event = LoggingEvents.myJobsOpened;
                          action = LoggingActions.opened;
                          break;
                        case MRouter.universityWidget:
                          event = LoggingEvents.universityTabClicked;
                          break;
                        case MRouter.earningsWidget:
                          event = LoggingEvents.earningsTabClicked;
                          break;
                        case MRouter.moreWidget:
                          event = LoggingEvents.profileTabClicked;
                          break;
                      }
                      LoggingData loggingData =
                          LoggingData(event: event, action: action);
                      CaptureEventHelper.captureEvent(loggingData: loggingData);
                      MRouter.pushReplacementNamed(item.navigateTo!,
                          arguments: sl<MRouter>().currentRoute);
                    },
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                width: 56.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20.0,
                      height: 20.0,
                      padding: EdgeInsets.all(item.padding!),
                      child: icon,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      item.text!,
                      style: context.textTheme.caption2Medium
                          .copyWith(color: color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
