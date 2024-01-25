import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/campus_ambassador/cubit/campus_ambassador_cubit.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../onboarding/data/model/work_application/application_status.dart';

class CaDashboardWidget extends StatefulWidget {
  final CampusAmbassadorData campusAmbassadorTasks;
  const CaDashboardWidget({Key? key, required this.campusAmbassadorTasks})
      : super(key: key);

  @override
  State<CaDashboardWidget> createState() => _CaDashboardWidgetState();
}

class _CaDashboardWidgetState extends State<CaDashboardWidget> {
  final _campusAmbassadorCubit = sl<CampusAmbassadorCubit>();
  UserData? _user;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _user = spUtil?.getUserData();
    _campusAmbassadorCubit.getCampusAmbassadorAnalyze(
        widget.campusAmbassadorTasks.campusAmbassadorTasks.worklistingId!,
        widget.campusAmbassadorTasks.referralCode!);
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
      backgroundColor: AppColors.primaryMain,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
                isCollapsable: true,
                title: widget.campusAmbassadorTasks.campusAmbassadorTasks
                    .worklistingName),
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
      child: StreamBuilder<UIStatus>(
          stream: _campusAmbassadorCubit.uiStatus,
          builder: (context, uiStatus) {
            if (uiStatus.hasData && uiStatus.data!.isOnScreenLoading) {
              return AppCircularProgressIndicator();
            } else {
              return InternetSensitive(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Dimens.padding_16,
                        Dimens.padding_36,
                        Dimens.padding_16,
                        Dimens.padding_16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'referral'.tr,
                          style: Get.context?.textTheme.labelSmall?.copyWith(
                              color: AppColors.backgroundGrey700,
                              fontSize: Dimens.font_16,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: Dimens.margin_24),
                        StreamBuilder<num>(
                            stream: _campusAmbassadorCubit.applicationCount,
                            builder: (context, applicationCount) {
                              return MyInkWell(
                                onTap: () {
                                  List<String> statusList = [];
                                  statusList.add(
                                      ApplicationStatus.disqualified.value);
                                  statusList
                                      .add(ApplicationStatus.rejected.value);
                                  statusList
                                      .add(ApplicationStatus.backedOut.value);
                                  statusList.add(
                                      ApplicationStatus.sampleleadtest.value);
                                  statusList
                                      .add(ApplicationStatus.selected.value);
                                  statusList.add(
                                      ApplicationStatus.executionStarted.value);
                                  statusList.add(ApplicationStatus
                                      .executionCompleted.value);
                                  statusList.add(
                                      ApplicationStatus.approvedToWork.value);
                                  CampusApplicationData campusApplicationData =
                                      CampusApplicationData(
                                    referralCode: widget
                                        .campusAmbassadorTasks.referralCode!,
                                    statusList: statusList,
                                    workListingId: widget.campusAmbassadorTasks
                                        .campusAmbassadorTasks.worklistingId!,
                                    isConditionEqual: false,
                                  );
                                  MRouter.pushNamed(MRouter.caApllicationWidget,
                                      arguments: campusApplicationData);
                                },
                                child: buildApplicationCard(
                                    'assets/images/ic_orange.svg',
                                    'application_in_progress'.tr,
                                    applicationCount.data.toString()),
                              );
                            }),
                        const SizedBox(height: Dimens.margin_12),
                        StreamBuilder<num>(
                            stream: _campusAmbassadorCubit.selectedCount,
                            builder: (context, selectedCount) {
                              return MyInkWell(
                                onTap: () {
                                  List<String> statusList = [];
                                  statusList.add(
                                      ApplicationStatus.approvedToWork.value);
                                  CampusApplicationData campusApplicationData =
                                      CampusApplicationData(
                                    referralCode: widget
                                        .campusAmbassadorTasks.referralCode!,
                                    statusList: statusList,
                                    workListingId: widget.campusAmbassadorTasks
                                        .campusAmbassadorTasks.worklistingId!,
                                    isConditionEqual: true,
                                  );
                                  MRouter.pushNamed(MRouter.caApllicationWidget,
                                      arguments: campusApplicationData);
                                },
                                child: buildApplicationCard(
                                    'assets/images/group_1.svg',
                                    'selected_applicants'.tr,
                                    selectedCount.data.toString()),
                              );
                            }),
                        const SizedBox(height: Dimens.margin_12),
                        StreamBuilder<num>(
                            stream: _campusAmbassadorCubit.workingCount,
                            builder: (context, workingCount) {
                              return MyInkWell(
                                onTap: () {
                                  List<String> statusList = [];
                                  statusList
                                      .add(ApplicationStatus.selected.value);
                                  statusList.add(
                                      ApplicationStatus.executionStarted.value);
                                  statusList.add(ApplicationStatus
                                      .executionCompleted.value);
                                  CampusApplicationData campusApplicationData =
                                      CampusApplicationData(
                                    referralCode: widget
                                        .campusAmbassadorTasks.referralCode!,
                                    statusList: statusList,
                                    workListingId: widget.campusAmbassadorTasks
                                        .campusAmbassadorTasks.worklistingId!,
                                    isConditionEqual: true,
                                  );
                                  MRouter.pushNamed(MRouter.caApllicationWidget,
                                      arguments: campusApplicationData);
                                },
                                child: buildApplicationCard(
                                    'assets/images/person.svg',
                                    'working_applicants'.tr,
                                    workingCount.data.toString()),
                              );
                            }),
                      ],
                    ),
                  ),
                ),
              );
            }
          }),
    );
  }

  Widget buildApplicationCard(String url, String name, String value) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
            Dimens.padding_16, Dimens.padding_16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SvgPicture.asset(
                      url,
                      height: Dimens.iconSize_40,
                    ),
                    const SizedBox(width: Dimens.margin_12),
                    Text(
                      value ?? "0",
                      style: Get.context?.textTheme.bodyText1Bold?.copyWith(
                          color: AppColors.black, fontSize: Dimens.font_28),
                    ),
                    const SizedBox(width: Dimens.margin_12),
                    Text(
                      name,
                      style: Get.context?.textTheme.bodyText1?.copyWith(
                          color: AppColors.backgroundGrey700,
                          fontSize: Dimens.font_14),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: Dimens.iconSize_12,
                  color: AppColors.primaryMain,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
