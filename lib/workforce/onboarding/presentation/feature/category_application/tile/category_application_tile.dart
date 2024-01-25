import 'package:awign/workforce/core/config/permission/awign_permission_constants.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/divider/v_divider.dart';
import 'package:awign/workforce/core/widget/image_loader/network_image_loader.dart';
import 'package:awign/workforce/core/widget/take_a_tour/take_a_tour.dart';
import 'package:awign/workforce/core/widget/take_a_tour/tour_keys.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';

class CategoryApplicationTile extends StatelessWidget {
  final int index;
  final CategoryApplication categoryApplication;
  final UserData currentUser;
  final Function(int index, CategoryApplication categoryApplication)
      onViewJobsTap;

  const CategoryApplicationTile(
      {Key? key,
      required this.index,
      required this.categoryApplication,
      required this.currentUser,
      required this.onViewJobsTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_8),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                const SizedBox(width: Dimens.margin_16),
                buildCategoryIcon(),
                const SizedBox(width: Dimens.margin_16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(categoryApplication.name ?? '',
                          style: context.textTheme.bodyText1Bold),
                      const SizedBox(height: Dimens.margin_8),
                      Row(
                        children: [
                          Text(
                              '${(categoryApplication.myJobsCount ?? 0) + (categoryApplication.pendingJobCount ?? 0)} ${'jobs'.tr}',
                              style: context.textTheme.caption?.copyWith(
                                  color: AppColors.backgroundGrey800)),
                          Container(
                            height: 14,
                            margin: const EdgeInsets.symmetric(
                                horizontal: Dimens.margin_8),
                            child: VDivider(),
                          ),
                          Flexible(
                              child: Text(
                                  '${categoryApplication.categoryType?.replaceAll('_', ' ').toCapitalized()}',
                                  style: context.textTheme.caption?.copyWith(
                                      color: AppColors.backgroundGrey800))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Dimens.margin_16),
              ],
            ),
            buildMyJobsPendingJobsCountWidgets(context),
            buildViewJobsButton()
          ]),
        ),
      ),
    );
  }

  Widget buildMyJobsPendingJobsCountWidgets(BuildContext context) {
    if ((currentUser.permissions?.awign
            ?.contains(AwignPermissionConstants.hidePendingJobs) ??
        false)) {
      return const SizedBox();
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: index == 0 && TourKeys.officeLoginCount == 1
                  ? TakeATourWidget(
                      globalKey: TourKeys.tourKeys5,
                      buildShowContainer: buildShowContainer(),
                      child: buildMyJobs(context))
                  : buildMyJobs(context)),
          Expanded(
              child: index == 0 && TourKeys.officeLoginCount == 1
                  ? TakeATourWidget(
                      globalKey: TourKeys.tourKeys6,
                      buildShowContainer: buildPendingJobsContainer(),
                      child: buildPendingJobs(context))
                  : buildPendingJobs(context))
        ],
      );
    }
  }

  Widget buildShowContainer() {
    return Container(
      padding: const EdgeInsets.all(Dimens.padding_8),
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: Dimens.padding_20),
            child: Text('my_jobs_details'.tr,
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
                  LoggingData loggingData = LoggingData(
                      event: Constants.skipJob,
                      action: LoggingActions.clicked,
                      pageName: Constants.viewJob);
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
                padding: const EdgeInsets.only(right: 30),
                child: RaisedRectButton(
                  height: Dimens.margin_40,
                  width: 80,
                  text: 'next'.tr,
                  onPressed: () async {
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) async => ShowCaseWidget.of(Get.context!).next());
                    LoggingData loggingData = LoggingData(
                        event: Constants.nextJob,
                        action: LoggingActions.clicked,
                        pageName: Constants.viewJob);
                    CaptureEventHelper.captureEvent(loggingData: loggingData);
                  },
                  backgroundColor: AppColors.primaryMain,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildPendingJobsContainer() {
    return Container(
      padding: const EdgeInsets.all(Dimens.padding_8),
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimens.padding_4),
            child: Text('pending_jobs_details'.tr,
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
                padding: const EdgeInsets.only(right: 30),
                child: RaisedRectButton(
                  height: Dimens.margin_40,
                  width: 80,
                  text: 'got_it'.tr,
                  onPressed: () {
                    TourKeys.officeLoginCount = 0;
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) async => ShowCaseWidget.of(Get.context!).next());
                  },
                  backgroundColor: AppColors.primaryMain,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildMyJobs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_12,
          Dimens.padding_16, Dimens.padding_12),
      margin: const EdgeInsets.fromLTRB(
          Dimens.margin_24, Dimens.margin_20, Dimens.margin_8, 0),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.backgroundGrey300),
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('my_jobs'.tr, style: context.textTheme.caption),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, Dimens.padding_8, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.pine),
                  height: Dimens.margin_8,
                  width: Dimens.margin_8,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimens.padding_4, 0, 0, 0),
                  child: Text(
                      '${categoryApplication.myJobsCount ?? 0} ${'job'.tr}',
                      style: context.textTheme.bodyText2Bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildPendingJobs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_12,
          Dimens.padding_16, Dimens.padding_16),
      margin: const EdgeInsets.fromLTRB(
          Dimens.margin_8, Dimens.margin_20, Dimens.margin_24, 0),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.backgroundGrey300),
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('pending_jobs'.tr,
              style: context.textTheme.caption
                  ?.copyWith(color: AppColors.backgroundGrey800)),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, Dimens.padding_8, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.orange),
                  height: Dimens.margin_8,
                  width: Dimens.margin_8,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimens.padding_4, 0, 0, 0),
                  child: Text(
                      '${categoryApplication.pendingJobCount ?? 0} ${'job'.tr}',
                      style: context.textTheme.bodyText2Bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildViewJobsButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_24, Dimens.margin_24,
          Dimens.margin_24, Dimens.margin_24),
      child: RaisedRectButton(
        height: Dimens.btnHeight_40,
        text: 'view_jobs'.tr,
        onPressed: () {
          onViewJobsTap(index, categoryApplication);
        },
      ),
    );
  }

  Widget buildCategoryIcon() {
    return NetworkImageLoader(
      url: categoryApplication.icon ?? '',
      width: Dimens.imageWidth_48,
      height: Dimens.imageHeight_48,
      filterQuality: FilterQuality.high,
      fit: BoxFit.cover,
    );
  }
}
