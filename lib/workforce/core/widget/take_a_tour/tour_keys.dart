import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/take_a_tour/cubit/take_a_tour_cubit.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../data/local/repository/logging_event/helper/logging_actions.dart';

class TourKeys {
  static final tourKeys1 = GlobalKey();
  static final tourKeys2 = GlobalKey();
  static final tourKeys3 = GlobalKey();
  static final tourKeys4 = GlobalKey();
  static final tourKeys5 = GlobalKey();
  static final tourKeys6 = GlobalKey();

  static List tourKeysList = [tourKeys1, tourKeys2, '', tourKeys3];
  static List<String> navigationNameList = [
    'explore'.tr,
    'office'.tr,
    '',
    'earnings'.tr
  ];

  static int loginCount = 0;
  static int officeLoginCount = 0;

  static List<Widget> navigationWidgetList = [
    Container(
      padding: const EdgeInsets.all(Dimens.padding_8),
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Text('explore_jobs_categories'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.2)),
          ),
          const SizedBox(
            height: Dimens.margin_12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyInkWell(
                onTap: () async {
                  WidgetsBinding.instance.addPostFrameCallback(
                      (_) async => ShowCaseWidget.of(Get.context!).dismiss());
                  TourKeys.loginCount = 0;
                  LoggingData loggingData = LoggingData(
                      event: Constants.skipIntro,
                      action: LoggingActions.clicked,
                      pageName: Constants.introduction);
                  CaptureEventHelper.captureEvent(loggingData: loggingData);
                },
                child: Text('skip'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.2)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: Dimens.padding_32),
                child: RaisedRectButton(
                  height: Dimens.margin_40,
                  width: 80,
                  text: 'next'.tr,
                  onPressed: () async {
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) async => ShowCaseWidget.of(Get.context!).next());
                    final TakeATourCubit tourCubit = sl<TakeATourCubit>();
                    tourCubit.changeisSelected(true);
                    LoggingData loggingData = LoggingData(
                        event: Constants.nextIntro,
                        action: LoggingActions.clicked,
                        pageName: Constants.introduction);
                    CaptureEventHelper.captureEvent(loggingData: loggingData);
                  },
                  backgroundColor: AppColors.primaryMain,
                ),
              ),
            ],
          )
        ],
      ),
    ),
    Container(
      padding: const EdgeInsets.all(8.0),
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: Dimens.padding_8),
            child: Text('office_text'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.2)),
          ),
          const SizedBox(
            height: Dimens.margin_12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyInkWell(
                onTap: () async {
                  TourKeys.loginCount = 0;
                  WidgetsBinding.instance.addPostFrameCallback(
                      (_) async => ShowCaseWidget.of(Get.context!).dismiss());
                  LoggingData loggingData = LoggingData(
                      event: Constants.skipOffice,
                      action: LoggingActions.clicked,
                      pageName: Constants.office);
                  CaptureEventHelper.captureEvent(loggingData: loggingData);
                },
                child: Text('skip'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.2)),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: Dimens.padding_32),
                    child: RaisedRectButton(
                      borderColor: AppColors.backgroundWhite,
                      height: Dimens.margin_40,
                      width: 80,
                      text: 'back'.tr,
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback(
                            (_) async =>
                                ShowCaseWidget.of(Get.context!).previous());
                      },
                      backgroundColor: AppColors.transparent,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: Dimens.padding_32),
                    child: RaisedRectButton(
                      height: Dimens.margin_40,
                      width: 80,
                      text: 'next'.tr,
                      onPressed: () async {
                        WidgetsBinding.instance.addPostFrameCallback(
                            (_) async =>
                                ShowCaseWidget.of(Get.context!).next());
                        final TakeATourCubit tourCubit = sl<TakeATourCubit>();
                        tourCubit.changeisSelected(true);
                        LoggingData loggingData = LoggingData(
                            event: Constants.nextOffice,
                            action: LoggingActions.clicked,
                            pageName: Constants.office);
                        CaptureEventHelper.captureEvent(
                            loggingData: loggingData);
                      },
                      backgroundColor: AppColors.primaryMain,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    ),
    Container(),
    Container(
      padding: const EdgeInsets.all(Dimens.padding_8),
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('earning_text'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.2)),
          ),
          const SizedBox(
            height: Dimens.margin_20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: Dimens.padding_32),
                child: RaisedRectButton(
                  borderColor: AppColors.backgroundWhite,
                  height: Dimens.margin_40,
                  width: 80,
                  text: 'back'.tr,
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) async =>
                        ShowCaseWidget.of(Get.context!).previous());
                  },
                  backgroundColor: AppColors.transparent,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: Dimens.margin_48),
                child: RaisedRectButton(
                  height: Dimens.margin_40,
                  width: 80,
                  text: 'got_it'.tr,
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) async => ShowCaseWidget.of(Get.context!).next());
                    final TakeATourCubit tourCubit = sl<TakeATourCubit>();
                    tourCubit.changeisSelected(false);
                  },
                  backgroundColor: AppColors.primaryMain,
                ),
              ),
            ],
          )
        ],
      ),
    ),
  ];
}
