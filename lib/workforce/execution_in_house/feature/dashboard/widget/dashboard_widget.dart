import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/config/cubit/flavor_cubit.dart';
import 'package:awign/workforce/core/config/permission/awign_permission_constants.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/attendance_sucessfull_bottom_sheet/widget/attendance_sucessfull_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/enable_camera_bottom_sheet/widget/enable_camera_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/enable_file_bottom_sheet/widget/enable_file_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/geolocation_bottom_sheet/widget/geolocation_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/location_captured_bottom_sheet/widget/location_captured_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/mark_attendance_bottom_sheet/widget/mark_attendance_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/attendance_punches_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_payout_amount.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_payout_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/project.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/data/attendance_answer_entity.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/data/screen_question_arguments.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/widget/attendance_punch_in_widget.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/widget/tile/attendance_tile.dart';
import 'package:awign/workforce/execution_in_house/feature/availablity/widget/bottom_sheet/availability_widget_bottomsheet.dart';
import 'package:awign/workforce/execution_in_house/feature/dashboard/cubit/dashboard_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/dashboard/widget/bottom_sheet/similar_jobs_bottom_sheet.dart';
import 'package:awign/workforce/execution_in_house/feature/dashboard/widget/bottom_sheet/work_assigned_bottom_sheet.dart';
import 'package:awign/workforce/more/feature/rate_us/widget/rate_us_widget.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_section_names.dart';
import '../../../data/model/worklog_widget_data.dart';
import '../data/model/dashboard_widget_argument.dart';

class DashboardWidget extends StatefulWidget {
  final DashboardWidgetArgument dashboardWidgetArgument;

  const DashboardWidget(this.dashboardWidgetArgument, {Key? key}) : super(key: key);

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final DashboardCubit _dashboardCubit = sl<DashboardCubit>();
  UserData? _currentUser;
  bool isSkipSaasOrgID = false;
  String projectRoleId = "";
  bool isWorkLogConfig = false;
  bool isFromWorklogActivity = false;
  bool availabilityInProject = false;
  bool isSlotsAvailable = false;
  bool showWorkAssignedBottomSheet = false;
  bool isProceedToWorkCtaRequired = true;
  static const pending = 'Pending';
  static const work = 'work';
  int workAllocationDelay = 0;
  String tabRowRequestedRegretMessage = '';
  String tabRowRequestedThanksMessage = '';
  Map<String, dynamic> eventProperty = {};
  Execution? _execution;
  List<PunchInScreens>? tempPunchInScreenList;
  int? index;
  List<AttendanceAnswerEntity>? attendanceAnswerEntityList = [];

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    _dashboardCubit.changeCurrentUser(_currentUser!);
    if (spUtil!.getSaasOrgID().isNullOrEmpty) {
      isSkipSaasOrgID = true;
    }
    setState(() {
      _execution = widget.dashboardWidgetArgument.execution;
    });
    if (_execution != null) {
      _dashboardCubit.changeExecution(_execution!);
    } else {
      _dashboardCubit.getExecution(
          widget.dashboardWidgetArgument.executionID ?? '',
          widget.dashboardWidgetArgument.projectID ?? '');
    }
  }

  updateExecutionAndGetProjectAndLeadPayoutAmount() {
    _dashboardCubit.getProjectAndLeadPayoutAmount(_execution!);
    if (!_currentUser!.permissions!.awign!
        .contains(AwignPermissionConstants.hideLeadListView)) {
      _dashboardCubit.getTabs(_execution!);
    } else {
      _dashboardCubit.tabsMap.sink.addError('');
    }
    if ((_execution!.supplyCategories?.isNotEmpty ?? false) &&
        _execution!.selectedProjectRole != null) {
      String? categoryID = _execution?.supplyCategories?[_execution?.selectedProjectRole]
          ?.toLowerCase()?.replaceAll(" ", "_");
      if (categoryID != null) {
        _dashboardCubit.getCategoryApplicationDetails(
            _currentUser!.id.toString(), categoryID);
      }
    }
  }

  Future<void> subscribeUIStatus() async {
    _dashboardCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.success:
            isSlotsAvailable = true;
            break;
          case Event.created:
            _dashboardCubit.feedbackEvent();
            break;
          case Event.rateus:
            showrateUsBottomSheet(context, MRouter.dashboardWidget);
            break;
          case Event.failed:
            isSlotsAvailable = false;
            showProvideAvailabilityBottomSheet(
                context, getEventForAvailability());
            break;
          case Event.updated:
            attendanceSucessfullBottomSheet(context, uiStatus.data as String,
                () {
              MRouter.pop(null);
              _dashboardCubit.getAttendancePunchesSearch(
                  projectRoleId,
                  StringUtils.getFormattedDateTime(StringUtils.dateFormatYMD),
                  _dashboardCubit.attendancePunchesValue?.executionId);
            });
            break;
          case Event.scheduled:
            attendanceSucessfullBottomSheet(context, uiStatus.data as String,
                () {
              MRouter.pop(null);
              onTabViewClicked();
              _dashboardCubit.getAttendancePunchesSearch(
                  projectRoleId,
                  StringUtils.getFormattedDateTime(StringUtils.dateFormatYMD),
                  _dashboardCubit.attendancePunchesValue?.executionId);
            });
            break;
          case Event.none:
            break;
        }
      },
    );
    _dashboardCubit.execution.listen((execution) {
      if(widget.dashboardWidgetArgument.execution == null) {
        setState(() {
          _execution = execution;
          _execution?.selectedProjectRole = widget.dashboardWidgetArgument.projectRoleUID;
        });
      }
      updateExecutionAndGetProjectAndLeadPayoutAmount();
    });
    _dashboardCubit.project.listen((project) {
      for (ProjectRoles projectRole in project.projectRoles!) {
        if (projectRole.uid ==
            _execution?.selectedProjectRole?.toLowerCase()
                .replaceAll(" ", "_")) {
          projectRoleId = projectRole.id!;
          availabilityInProject = projectRole.availability!;
          _dashboardCubit.getAttendancePunchesSearch(
              projectRoleId,
              StringUtils.getFormattedDateTime(StringUtils.dateFormatYMD),
              _execution?.id);
          break;
        }
      }
      if (project.showWorklogConfig != null && project.showWorklogConfig!.containsKey(_execution!.selectedProjectRole?.toLowerCase()
              .replaceAll(" ", "_")) &&
          project.showWorklogConfig?[_execution?.selectedProjectRole?.toLowerCase()
                  .replaceAll(" ", "_")] ==
              true) {
        isWorkLogConfig = true;
      }

      if (availabilityInProject) {
        String memberId = _currentUser!.ihOmsId!;
        _dashboardCubit.getUpcomingSlots(memberId,
            DateFormat(StringUtils.dateFormatYMD).format(DateTime.now()));
      }
    });
    _dashboardCubit.tabsMapStream.listen((tabsMap) {
      eventProperty = {};
      eventProperty[CleverTapConstant.projectName] =
          _execution!.projectName;
      eventProperty[CleverTapConstant.projectId] = _execution!.projectId;
      eventProperty[CleverTapConstant.roleName] =
          _execution!.selectedProjectRole?.replaceAll('_', ' ');
      int count = 0;
      tabsMap.forEach((key, value) {
        if (_execution!.leadAllotmentType ==
            ExecutionLeadAllotmentType.provided) {
          if (key.toLowerCase() == pending.toLowerCase() && value > 0) {
            showWorkAssignedBottomSheet = false;
            showWorkAssignedBottomBottomSheet(context);
          }
          FlavorCubit flavorCubit = context.read<FlavorCubit>();
          if (_execution!.leadAssignedStatus ==
                  ExecutionLeadAssignedStatus.firstLeadAssigned &&
              _execution!.workRequested != true &&
              key.toLowerCase() == pending.toLowerCase() &&
              value > 0) {
            _dashboardCubit.changeIsRequestForWorkVisible(true);
          } else if (_execution!
              .isRequestWorkVisibleCalc(flavorCubit, workAllocationDelay)) {
            _dashboardCubit.changeIsRequestForWorkVisible(true);
          }
          if (_execution!.leadAssignedStatus ==
                  ExecutionLeadAssignedStatus.firstLeadAssigned &&
              _execution!.workRequested == true &&
              key.toLowerCase() == pending.toLowerCase() &&
              value == 0) {
            _dashboardCubit.changeIsTabRowRequested(true);
            if (_execution!
                .isRegretMsgShown(flavorCubit, workAllocationDelay)) {
              //regret
              tabRowRequestedRegretMessage =
                  'our_team_is_working_hard_to_find_work_for_you_you_will_be_notified_when_work_is_available'
                      .tr;
            } else {
              //thanks
              tabRowRequestedThanksMessage =
                  'thanks_for_submitting_the_request_for_more_work_your_manager_has_been_informed'
                      .tr;
            }
          }
        }
        if (_execution!.leadAssignedStatus ==
                ExecutionLeadAssignedStatus.firstLeadAssigned &&
            key.toLowerCase() == pending.toLowerCase() &&
            value > 0) {
          isProceedToWorkCtaRequired = false;
          _dashboardCubit.changeIsProceedToWorkVisible(false);
          _dashboardCubit.changeIsStartWorkingVisible(true);
        }
        switch (count) {
          case 0:
            eventProperty[CleverTapConstant.numLeadsWork] = value;
            break;
          case 1:
            eventProperty[CleverTapConstant.numLeadsSubmitted] = value;
            break;
          case 2:
            eventProperty[CleverTapConstant.numLeadsDone] = value;
            break;
        }
        count++;
      });
      if (isFromWorklogActivity &&
          !_currentUser!.permissions!.awign!
              .contains(AwignPermissionConstants.hideLeadListView)) {
        onTabViewClicked();
        isFromWorklogActivity = false;
      }
      ClevertapData clevertapData = ClevertapData(
          eventName: ClevertapHelper.leadListViewApened,
          properties: eventProperty);
      CaptureEventHelper.captureEvent(clevertapData: clevertapData);
    });
    _dashboardCubit.executionResponse.listen((executionResponse) {
      if (executionResponse.execution?.workRequested == true) {
        _dashboardCubit.changeIsRequestForWorkVisible(false);
        tabRowRequestedThanksMessage =
            'thanks_for_submitting_the_request_for_more_work_your_manager_has_been_informed'
                .tr;
        _dashboardCubit.changeIsTabRowRequested(true);
        Helper.showInfoToast('request_submitted'.tr);
      }
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
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      topPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
                isCollapsable: true,
                isActionVisible: false,
                title: 'dashboard'.tr,
                leadingURL: _execution?.projectIcon),
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
        child: StreamBuilder<UIStatus>(
            stream: _dashboardCubit.uiStatus,
            builder: (context, uiStatus) {
              if (uiStatus.hasData &&
                  (uiStatus.data?.isOnScreenLoading ?? false)) {
                return AppCircularProgressIndicator();
              } else {
                return StreamBuilder<UserData>(
                    stream: _dashboardCubit.currentUser,
                    builder: (context, currentUser) {
                      if (currentUser.hasData && currentUser.data != null) {
                        return Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0,
                                      Dimens.padding_16, 0, Dimens.padding_16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      buildTitleText(),
                                      buildAttendanceWidget(),
                                      if (_execution!.archivedStatus ==
                                          true) ...[
                                        buildCloseProjectBanner()
                                      ] else ...[
                                        buildActiveUsersAndPotentialsEarnings(
                                            currentUser.data!),
                                        buildCertificateCards(
                                            currentUser.data!),
                                        buildDateCardWidget(),
                                        buildAvailabilityCard(),
                                        buildSharedInformationData(),
                                        buildTabs(currentUser.data!),
                                      ],
                                      buildEarningsCard(currentUser.data!),
                                      buildApplicationDetailsCard(
                                          currentUser.data!),
                                      buildOfferLetterCard(currentUser.data!),
                                      buildProjectFaqCard(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            buildStartWorkingButton(),
                            buildRequestWorkButton(),
                            buildProceedToWorkButton(),
                          ],
                        );
                      } else {
                        return AppCircularProgressIndicator();
                      }
                    });
              }
            }),
      ),
    );
  }

  Widget buildTitleText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text(_execution!.projectName ?? '',
          style: Get.context?.textTheme.headline7Bold
              .copyWith(color: AppColors.backgroundBlack)),
    );
  }

  Widget buildCloseProjectBanner() {
    return Card(
        margin: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_32, Dimens.padding_16, 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimens.padding_28),
          child: Column(
            children: [
              SvgPicture.asset('assets/images/ic_project_close_banner.svg'),
              const SizedBox(
                height: Dimens.margin_24,
              ),
              Text('this_project_has_been_closed'.tr,
                  style: Get.context?.textTheme.labelLarge?.copyWith(
                      color: AppColors.backgroundGrey900,
                      fontSize: Dimens.font_14,
                      fontWeight: FontWeight.w700)),
              buildExploreButton('explore_job_categories'.tr, () {
                _openCategoryListing();
              })
            ],
          ),
        ));
  }

  Widget buildActiveUsersAndPotentialsEarnings(UserData currentUser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildActiveUserWidget(currentUser),
        buildPotentialEarningWidget(currentUser),
      ],
    );
  }

  Widget buildActiveUserWidget(UserData currentUser) {
    if (!(currentUser.permissions?.awign
            ?.contains(AwignPermissionConstants.hideActiveUsers) ??
        false)) {
      return StreamBuilder<Project>(
          stream: _dashboardCubit.project,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              ProjectRoles? projectRole = snapshot.data!.getProjectRole(_execution!.selectedProjectRole!
                  .toLowerCase()
                  .replaceAll(" ", "_"));
              if (projectRole?.workAllocationDelay != null) {
                workAllocationDelay = projectRole!.workAllocationDelay!;
              }
              if (projectRole != null && projectRole.activeUsersVisible) {
                projectRoleId = projectRole.id!;
                num activeWorkforceCount =
                    projectRole.activeWorkforceCount ?? 0;
                String strCont = '';
                if (0 <= activeWorkforceCount && activeWorkforceCount >= 50) {
                  strCont = '~50';
                } else if (51 <= activeWorkforceCount &&
                    activeWorkforceCount >= 100) {
                  strCont = '50+';
                } else if (101 <= activeWorkforceCount &&
                    activeWorkforceCount >= 1000) {
                  strCont = '100';
                } else if (activeWorkforceCount > 1001) {
                  strCont = '1000+';
                } else {
                  strCont = '0';
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Dimens.padding_16, Dimens.padding_16, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('active_users'.tr,
                          style: Get.context?.textTheme.caption
                              ?.copyWith(color: AppColors.backgroundGrey800)),
                      const SizedBox(height: Dimens.margin_8),
                      Text(strCont,
                          style: Get.context?.textTheme.bodyText2
                              ?.copyWith(color: AppColors.backgroundBlack)),
                    ],
                  ),
                );
              } else {
                return const SizedBox();
              }
            } else {
              return const SizedBox();
            }
          });
    } else {
      return const SizedBox();
    }
  }

  Widget buildPotentialEarningWidget(UserData currentUser) {
    if (!(currentUser.permissions?.awign
            ?.contains(AwignPermissionConstants.hidePotentialEarning) ??
        false)) {
      return StreamBuilder<Project>(
          stream: _dashboardCubit.project,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              ProjectRoles? projectRole = snapshot.data!.getProjectRole(_execution!.selectedProjectRole!
                  .toLowerCase()
                  .replaceAll(" ", "_"));
              if (projectRole != null && projectRole.potentialEarning != null) {
                String strEarning = '';
                if (!projectRole.potentialEarning!.from.isNullOrEmpty &&
                    !projectRole.potentialEarning!.to.isNullOrEmpty) {
                  strEarning =
                      '${Constants.rs}${projectRole.potentialEarning!.from} - ${Constants.rs}${projectRole.potentialEarning!.to}';
                } else if (!projectRole.potentialEarning!.from.isNullOrEmpty) {
                  strEarning =
                      '${Constants.rs}${projectRole.potentialEarning!.from}';
                } else if (!projectRole.potentialEarning!.to.isNullOrEmpty) {
                  strEarning =
                      '${Constants.rs}${projectRole.potentialEarning!.to}';
                } else {
                  strEarning = '';
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0, Dimens.padding_16, Dimens.padding_16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('potential_earning'.tr,
                          style: Get.context?.textTheme.caption
                              ?.copyWith(color: AppColors.backgroundGrey800)),
                      const SizedBox(height: Dimens.margin_8),
                      Text(
                          '${projectRole.potentialEarning!.earningType?.replaceAll('_', '').toCapitalized()} $strEarning ${projectRole.potentialEarning!.earningDuration?.replaceAll('_', '').toCapitalized()}',
                          style: Get.context?.textTheme.bodyText2
                              ?.copyWith(color: AppColors.backgroundBlack)),
                    ],
                  ),
                );
              } else {
                return const SizedBox();
              }
            } else {
              return const SizedBox();
            }
          });
    } else {
      return const SizedBox();
    }
  }

  Widget buildCertificateCards(UserData currentUser) {
    return StreamBuilder<Execution>(
      stream: _dashboardCubit.execution,
      builder: (context, execution) {
        if (execution.hasData &&
            !(currentUser.permissions?.awign
                    ?.contains(AwignPermissionConstants.hideCertificate) ??
                false) &&
            (_execution!.certificate?.containsKey(Keys.certificateURL) ??
                false)) {
          switch (execution.data!.status) {
            case ExecutionStatus.completed:
              return buildCertificateCard('request_certificate'.tr, true);
            case ExecutionStatus.certificateIssued:
              return buildCertificateCard('download_certificate'.tr, true);
            case ExecutionStatus.certificateRequested:
              return buildCertificateCard('requested_certificate'.tr, false);
            default:
              return const SizedBox();
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildCertificateCard(String text, bool arrowVisible) {
    return Card(
      margin: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
      ),
      child: MyInkWell(
        onTap: () async {
          switch (_execution!.status) {
            case ExecutionStatus.completed:
              _dashboardCubit.certificateStatusUpdate(_execution!,
                  ExecutionStatus.certificateRequested.value);
              break;
            case ExecutionStatus.certificateIssued:
              if (_execution!.certificate!
                  .containsKey("certificate_url")) {
                downloadFile(
                    _execution!.certificate!["certificate_url"] ?? "");
              }
              break;
            case ExecutionStatus.certificateRequested:
            default:
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_16),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    SvgPicture.asset(
                        'assets/images/ic_application_details.svg'),
                    const SizedBox(width: Dimens.padding_11),
                    Text(
                      text,
                      style: context.textTheme.bodyText1Medium
                          ?.copyWith(color: AppColors.backgroundBlack),
                    ),
                  ],
                ),
              ),
              arrowVisible
                  ? const Icon(Icons.chevron_right,
                      color: AppColors.backgroundGrey800)
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDateCardWidget() {
    bool isCardVisible = false;
    if (_execution!.leadAllotmentType ==
            ExecutionLeadAllotmentType.provided &&
        _execution!.leadAssignedStatus == null) {
      isCardVisible = true;
    }
    if (_execution!.projectRoles != null &&
        _execution!.projectRoles!.isNotEmpty &&
        _execution!.startDate?[_execution!.projectRoles?[0]] ==
            null) {
      isCardVisible = false;
    }
    if (isCardVisible) {
      RequestWorkCardDetails requestWorkCardDetails = _execution!
          .getRequestWorkCardDetails(_execution!.projectRoles?[0]);
      return Card(
        margin: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_16),
          child: Column(
            children: [
              SvgPicture.asset(requestWorkCardDetails.dateCardIcon ??
                  'assets/images/ic_clock_yellow.svg'),
              const SizedBox(height: Dimens.padding_16),
              Text(
                requestWorkCardDetails.infoText ?? '',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyText2
                    ?.copyWith(color: AppColors.backgroundGrey800),
              ),
              buildExploreTextBuilder(
                  requestWorkCardDetails.isExploreTextVisible,
                  requestWorkCardDetails.isExploreButtonVisible),
              buildWorkStartDate(requestWorkCardDetails),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildWorkStartDate(RequestWorkCardDetails requestWorkCardDetails) {
    if (_execution!.leadAllotmentType ==
            ExecutionLeadAllotmentType.provided &&
        _execution!.leadAssignedStatus == null) {
      if (requestWorkCardDetails.dateTitle != null &&
          requestWorkCardDetails.date != null) {
        return Container(
          margin: const EdgeInsets.fromLTRB(
              Dimens.margin_8, Dimens.margin_8, Dimens.margin_8, 0),
          padding: const EdgeInsets.all(Dimens.padding_8),
          decoration: const BoxDecoration(
            color: AppColors.warning100,
            borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_4)),
          ),
          child: Row(
            children: [
              Text(
                requestWorkCardDetails.dateTitle!,
                style: Get.textTheme.bodyText2Medium
                    ?.copyWith(color: AppColors.backgroundBlack),
              ),
              Text(
                requestWorkCardDetails.date!,
                style: Get.textTheme.bodyText2SemiBold
                    ?.copyWith(color: AppColors.warning300),
              ),
            ],
          ),
        );
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }

  Widget buildExploreTextBuilder(
      bool isExploreTextVisible, bool isExploreButtonVisible) {
    return StreamBuilder<WorkApplicationResponse>(
        stream: _dashboardCubit.workApplicationResponse,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data!.workApplicationList.isNullOrEmpty) {
            if (isExploreTextVisible) {
              return buildExploreText('explore_job_categories'.tr, () {
                _openCategoryListing();
              });
            } else if (isExploreButtonVisible) {
              return buildExploreButton('explore_job_categories'.tr, () {
                _openCategoryListing();
              });
            } else {
              return const SizedBox();
            }
          } else {
            if (isExploreTextVisible) {
              return buildExploreText('explore_similar_jobs'.tr, () {
                _showSimilarJobs();
              });
            } else if (isExploreButtonVisible) {
              return buildExploreButton('explore_similar_jobs'.tr, () {
                _showSimilarJobs();
              });
            } else {
              return const SizedBox();
            }
          }
        });
  }

  Widget buildExploreText(String text, Function onTap) {
    return MyInkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: Text(text,
            style: Get.textTheme.bodyText2SemiBold
                ?.copyWith(color: AppColors.primaryMain)),
      ),
    );
  }

  Widget buildExploreButton(String text, Function onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_32,
          Dimens.padding_16, Dimens.padding_16),
      child: RaisedRectButton(
        text: text,
        elevation: 0,
        onPressed: () {
          onTap();
        },
      ),
    );
  }

  _showSimilarJobs() {
    if (_dashboardCubit.getSimilarJobs() != null) {
      showSimilarJobsBottomSheet(
        context,
        _dashboardCubit.getSimilarJobs()!,
        (workApplicationEntity) {},
      );
    }
  }

  _openCategoryListing() {
    MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
  }

  Widget buildSharedInformationData() {
    if (_execution!.sharedInformationData != null &&
        _execution!.sharedInformationData!.isNotEmpty) {
      return Card(
        margin: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
        ),
        child: ListView.builder(
          itemCount: _execution!.sharedInformationData!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
              Dimens.padding_8, Dimens.padding_16, Dimens.padding_16),
          itemBuilder: (_, i) {
            String key =
                _execution!.sharedInformationData!.keys.elementAt(i);
            SharedInformationData? shareInformationData =
                _execution!.sharedInformationData![key];
            if (shareInformationData != null) {
              return buildShareInformationTile(
                  shareInformationData.title ?? '', shareInformationData.value);
            } else {
              return const SizedBox();
            }
          },
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildShareInformationTile(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimens.padding_8),
      child: Row(
        children: [
          Text('$title : ', style: Get.textTheme.captionMedium),
          Text('$value', style: Get.textTheme.caption),
        ],
      ),
    );
  }

  Widget buildTabs(UserData currentUser) {
    if (currentUser.permissions?.awign
            ?.contains(AwignPermissionConstants.listView) ??
        false) {
      return StreamBuilder<Map<String, dynamic>>(
        stream: _dashboardCubit.tabsMapStream,
        builder: (context, tabsMapStream) {
          if (tabsMapStream.hasData) {
            _execution!.tabsMap = tabsMapStream.data;
            return Card(
              margin: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTasksText(),
                  ListView.builder(
                    itemCount: tabsMapStream.data?.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                        top: 0, bottom: Dimens.padding_16),
                    itemBuilder: (_, i) {
                      String key = tabsMapStream.data!.keys.elementAt(i);
                      String value = tabsMapStream.data![key].toString();
                      return buildTabsTile(key, value);
                    },
                  ),
                  buildTabsMessage(),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildTabsTile(String key, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: MyInkWell(
        onTap: () {
          _execution!.selectedTab = key;
          if (_dashboardCubit.attendancePunchesValue != null &&
              _dashboardCubit.attendancePunchesValue!.nextPunchCta ==
                  'punch_in' &&
              _dashboardCubit.attendanceCount == 0) {
            _dashboardCubit.changeAttendanceCount(1);
            LoggingData loggingData =
            LoggingData(event:LoggingEvents.markAttendanceOpened,action: LoggingActions.clicked,pageName: LoggingPageNames.myAttendance);
            CaptureEventHelper.captureEvent(loggingData: loggingData);
            markAttendanceBottomSheet(context, () {
              MRouter.pop(null);
              attendanceAnswerEntityList?.clear();
              _dashboardCubit.changeIsPunchIn(true);
              _dashboardCubit.changeIsComingFromBottomSheet(true);
              onPunchTap(_dashboardCubit.attendancePunchesValue!);
              LoggingData loggingData = LoggingData(
                  event: LoggingEvents.punchInProjectClicked,
                  action: LoggingActions.clicked,pageName: LoggingPageNames.myAttendance);
              CaptureEventHelper.captureEvent(loggingData: loggingData);
            }, () {
              LoggingData(event:LoggingEvents.doItLaterClicked,action: LoggingActions.clicked,pageName: LoggingPageNames.myAttendance);
              CaptureEventHelper.captureEvent(loggingData: loggingData);
              MRouter.pop(null);
              onTabViewClicked();
            });
          } else {
            onTabViewClicked();
          }
          Map<String, dynamic> tabEvents = {};
          tabEvents.addAll(eventProperty);
          tabEvents[CleverTapConstant.tabName] = key;
          ClevertapHelper.instance()
              .addCleverTapEvent(ClevertapHelper.tabOpened, tabEvents);
        },
        child: Container(
          padding: const EdgeInsets.all(Dimens.padding_8),
          decoration: BoxDecoration(
            color: context.theme.textFieldBackgroundColor,
            borderRadius: BorderRadius.circular(Dimens.radius_8),
            border: Border.all(
                width: Dimens.border_1_5, color: AppColors.backgroundGrey400),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Text(key, style: context.textTheme.bodyText2SemiBold)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(value,
                      style: context.textTheme.bodyText2
                          ?.copyWith(color: AppColors.backgroundBlack)),
                  const SizedBox(width: Dimens.padding_8),
                  const Icon(Icons.chevron_right,
                      color: AppColors.backgroundGrey800),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabsMessage() {
    return StreamBuilder<bool>(
        stream: _dashboardCubit.isTabRowRequestedStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            String message = '';
            if (tabRowRequestedRegretMessage.isNotEmpty) {
              message = tabRowRequestedRegretMessage;
            } else if (tabRowRequestedThanksMessage.isNotEmpty) {
              message = tabRowRequestedThanksMessage;
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset('assets/images/ic_clock_yellow.svg',
                      color: tabRowRequestedRegretMessage.isNotEmpty
                          ? AppColors.error400
                          : AppColors.warning300),
                  const SizedBox(width: Dimens.padding_8),
                  Flexible(
                    child: Text(message,
                        style: context.textTheme.bodyText2
                            ?.copyWith(color: AppColors.backgroundGrey800)),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildTasksText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Text('tasks'.tr,
          style: Get.context?.textTheme.bodyText1SemiBold
              ?.copyWith(color: AppColors.backgroundBlack)),
    );
  }

  Widget buildEarningsCard(UserData currentUser) {
    if ((currentUser.permissions?.awign
                ?.contains(AwignPermissionConstants.hideTotalEarnings) ??
            false) ||
        _execution!.earningsBreakupVisible![
                _execution!.selectedProjectRole] ==
            false) {
      return const SizedBox();
    } else {
      return StreamBuilder<LeadPayoutAmount>(
          stream: _dashboardCubit.leadPayoutAmount,
          builder: (context, leadPayoutAmount) {
            if (leadPayoutAmount.hasData) {
              return Card(
                margin: const EdgeInsets.fromLTRB(
                    Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(Dimens.radius_16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.padding_16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.success300,
                                border: Border.all(color: AppColors.success300),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(Dimens.radius_8))),
                            child: Padding(
                              padding: const EdgeInsets.all(Dimens.padding_8),
                              child: SvgPicture.asset(
                                  'assets/images/ic_wallet.svg'),
                            ),
                          ),
                          const SizedBox(width: Dimens.padding_16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('total_earnings'.tr,
                                  style: Get.context?.textTheme.caption),
                              const SizedBox(height: Dimens.padding_4),
                              Text(
                                  '${Constants.rs} ${leadPayoutAmount.data!.totalAmount}'
                                      .tr,
                                  style: Get.context?.textTheme.headline4),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimens.padding_4),
                      HDivider(),
                      MyInkWell(
                        onTap: () {
                          MRouter.pushNamed(MRouter.leadPayoutScreenWidget,
                              arguments: EarningBreakupParams(
                                  execution: _execution!,
                                  amount: leadPayoutAmount.data!.totalAmount));
                        },
                        child: Row(
                          children: [
                            Expanded(
                                child: Text('view_breakup'.tr,
                                    style: Get
                                        .context?.textTheme.bodyText1SemiBold
                                        ?.copyWith(
                                            color: AppColors.primaryMain))),
                            const Icon(Icons.chevron_right,
                                color: AppColors.backgroundGrey800),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          });
    }
  }

  Widget buildApplicationDetailsCard(UserData currentUser) {
    if ((currentUser.permissions?.awign
                ?.contains(AwignPermissionConstants.hideApplicationDetails) ??
            false) ||
        _execution!
                .applicationIds![_execution!.selectedProjectRole] ==
            null) {
      return const SizedBox();
    } else {
      return Card(
        margin: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
        ),
        child: MyInkWell(
          onTap: () async {
            LoggingData loggingData = LoggingData(
                action: LoggingActions.applicationDetailsClicked,
                pageName: LoggingPageNames.myJobs,
                sectionName: LoggingSectionNames.office,
                otherProperty: getLoggingEvents());
            CaptureEventHelper.captureEvent(loggingData: loggingData);

            MRouter.pushNamed(MRouter.applicationIdDetailsWidget,
                arguments: _execution!);
          },
          child: Padding(
            padding: const EdgeInsets.all(Dimens.padding_16),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SvgPicture.asset(
                          'assets/images/ic_application_details.svg'),
                      const SizedBox(width: Dimens.padding_11),
                      Text(
                        'application_details'.tr,
                        style: context.textTheme.bodyText1Medium
                            ?.copyWith(color: AppColors.backgroundBlack),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.backgroundGrey800),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget buildOfferLetterCard(UserData currentUser) {
    if ((currentUser.permissions?.awign
                ?.contains(AwignPermissionConstants.hideOfferLetter) ??
            false) ||
        (_execution!.offerLetterVisible![
                    _execution!.selectedProjectRole] !=
                null &&
            _execution!.offerLetterVisible![
                    _execution!.selectedProjectRole] ==
                false)) {
      return const SizedBox();
    } else {
      return Card(
        margin: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
        ),
        child: MyInkWell(
          onTap: () {
            MRouter.pushNamed(MRouter.offerLetterWidget,
                arguments: _execution!);
          },
          child: Padding(
            padding: const EdgeInsets.all(Dimens.padding_16),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/images/ic_offer_letter.svg'),
                      const SizedBox(width: Dimens.padding_8),
                      Text(
                        'offer_letter'.tr,
                        style: context.textTheme.bodyText1Medium
                            ?.copyWith(color: AppColors.backgroundBlack),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.backgroundGrey800),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget buildProjectFaqCard() {
    return StreamBuilder<Project>(
        stream: _dashboardCubit.project,
        builder: (context, project) {
          if (project.hasData &&
              _execution!.selectedProjectRole != null &&
              project.data!.showFaqs != null &&
              project.data!.showFaqs![_execution!.selectedProjectRole!
                      .toLowerCase()
                      .replaceAll(' ', '_')] ==
                  true) {
            return Card(
              margin: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_16)),
              ),
              child: MyInkWell(
                onTap: () async {},
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.padding_16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SvgPicture.asset('assets/images/ic_faq.svg'),
                            const SizedBox(width: Dimens.padding_8),
                            Text(
                              'project_faqs'.tr,
                              style: context.textTheme.bodyText1Medium
                                  ?.copyWith(color: AppColors.backgroundBlack),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.backgroundGrey800),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  void onTabViewClicked() async {
    int yesterdayCalendar =
        DateTime.now().subtract(const Duration(days: 1)).day;
    if (_execution != null) {
      int? dayOfTheYear = _execution!
          .lastWorklogAt
          ?.getDateTimeObjectFromStrDateTime(StringUtils.dateFormatYMD)
          ?.day;
      _execution!.strAvailability = getFirstSlotOfTheDay();
      if (projectRoleId.isNotEmpty &&
          isWorkLogConfig &&
          !isFromWorklogActivity &&
          (_execution!.lastWorklogAt == null ||
              dayOfTheYear! <= yesterdayCalendar)) {
        WorkLogWidgetData workLogWidgetData = WorkLogWidgetData(
          projectRoleUid: _execution!.selectedProjectRole!
              .toLowerCase()
              .replaceAll(" ", "_"),
          projectRoleId: projectRoleId,
          execution: _execution!,
        );
        Result result = await MRouter.pushNamed(MRouter.worklogActivityWidget,
            arguments: workLogWidgetData);
        if (result.success) {
          isFromWorklogActivity = true;
          MRouter.pushNamed(MRouter.leadListWidget, arguments: _execution);
        }
      } else {
        MRouter.pushNamed(MRouter.leadListWidget, arguments: _execution);
      }
    }
  }

  Widget buildAvailabilityCard() {
    if (isSlotsAvailable == false) {
      return const SizedBox();
    } else {
      if (isProceedToWorkCtaRequired) {
        _dashboardCubit.changeIsProceedToWorkVisible(true);
      }
      return Card(
        margin: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_16),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.only(left: 0),
                leading: SvgPicture.asset(
                  'assets/images/ic_calendar.svg',
                ),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: Dimens.padding_8),
                  child: Text(
                    'today_schedule'.tr,
                    style: context.textTheme.bodyText1Medium
                        ?.copyWith(color: AppColors.backgroundBlack),
                  ),
                ),
                subtitle: Text(
                  getFirstSlotOfTheDay(),
                  style: Get.context?.textTheme.labelLarge?.copyWith(
                      color: AppColors.backgroundGrey800,
                      fontWeight: FontWeight.w400),
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(bottom: Dimens.padding_16),
                  child: MyInkWell(
                    onTap: () {
                      ClevertapHelper.instance().addCleverTapEvent(
                          ClevertapHelper.changeSchedule, eventProperty);
                      MRouter.pushNamed(MRouter.provideAvailabilityWidget,
                          arguments: getEventForAvailability());
                    },
                    child: Text(
                      'change'.tr,
                      style: context.textTheme.bodyText1Medium
                          ?.copyWith(color: AppColors.primaryMain),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  String getFirstSlotOfTheDay() {
    if (_dashboardCubit.memberTimeSlotResponseValue?.memberTimeSlot == null ||
        _dashboardCubit
            .memberTimeSlotResponseValue?.memberTimeSlot?.slots.isEmpty == true) {
      return "not_available".tr;
    }
    if (_dashboardCubit.memberTimeSlotResponseValue?.memberTimeSlot?.slots[0].startTime != null
        && _dashboardCubit.memberTimeSlotResponseValue?.memberTimeSlot?.slots[0].endTime != null) {
      return "${StringUtils.getTimeInLocalFromUtc(_dashboardCubit.memberTimeSlotResponseValue!.memberTimeSlot!.slots[0].startTime!)} "
          "- ${StringUtils.getTimeInLocalFromUtc(_dashboardCubit.memberTimeSlotResponseValue!.memberTimeSlot!.slots[0].endTime!)}";
    } else {
      return "";
    }
  }

  Future<void> downloadFile(String url) async {
    bool value = await FileUtils.download(
        context, _execution!.certificate!["certificate_url"] ?? "");
    if (value) {
      _dashboardCubit.internalFeedbackEventSearch(_currentUser!.id!);
    }
  }

  Widget buildStartWorkingButton() {
    return StreamBuilder<bool>(
        stream: _dashboardCubit.isStartWorkingVisibleStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
              child: RaisedRectButton(
                text: 'start_working'.tr,
                onPressed: () {
                  // start_working cta is visible
                  if (!isProceedToWorkCtaRequired) {
                    //capture availability configured
                    if (isSlotsAvailable) {
                      if (_dashboardCubit.isSlotAvailableCurrently()) {
                        if (_execution!.tabsMap != null &&
                            _execution!.tabsMap!.isNotEmpty) {
                          _execution!.selectedTab = work;
                          onTabViewClicked();
                        }
                      } else {
                        showProvideAvailabilityBottomSheet(
                            context, getEventForAvailability());
                      }
                    } else {
                      _execution!.selectedTab = pending;
                      onTabViewClicked();
                    }
                  } else {
                    _execution!.selectedTab = pending;
                    onTabViewClicked();
                  }
                },
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildRequestWorkButton() {
    return StreamBuilder<bool>(
        stream: _dashboardCubit.isRequestForWorkVisibleStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_16, Dimens.padding_16, Dimens.padding_32),
              child: RaisedRectButton(
                text: 'request_work'.tr,
                buttonStatus: _dashboardCubit.buttonStatus,
                onPressed: () {
                  _dashboardCubit.requestWork(_execution!.id ?? '');
                  LoggingData loggingData = LoggingData(
                      event: LoggingEvents.workRequested,
                      pageName: LoggingPageNames.dashboard,
                      otherProperty: _dashboardCubit.getLoggingEvents(
                          _execution!, availabilityInProject));
                  CaptureEventHelper.captureEvent(loggingData: loggingData);
                },
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildProceedToWorkButton() {
    return StreamBuilder<bool>(
        stream: _dashboardCubit.isProceedToWorkVisibleStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
              child: RaisedRectButton(
                text: 'proceed_to_work'.tr,
                onPressed: () {
                  if (_dashboardCubit.isSlotAvailableCurrently() &&
                      _execution!.tabsMap != null &&
                      _execution!.tabsMap!.isNotEmpty) {
                    _execution!.selectedTab = work;
                    onTabViewClicked();
                  } else {
                    showProvideAvailabilityBottomSheet(
                        context, getEventForAvailability());
                  }
                  ClevertapHelper.instance().addCleverTapEvent(
                      ClevertapHelper.proceedToWork, eventProperty);
                },
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildAttendanceWidget() {
    return StreamBuilder<AttendancePunches?>(
        stream: _dashboardCubit.attendancePunchesResponseStream,
        builder: (context, attendancePunchesResponse) {
          if (attendancePunchesResponse.hasData &&
              attendancePunchesResponse.data != null) {
            return AttendanceTile(attendancePunchesResponse.data,
                (bool isPunchIn, String attendanceId) {
              _dashboardCubit.changeIsPunchIn(isPunchIn);
              _dashboardCubit.changeIsComingFromBottomSheet(false);
              onPunchTap(attendancePunchesResponse.data!);
              attendanceAnswerEntityList?.clear();
              LoggingData loggingData = LoggingData(
                  event: LoggingEvents.punchInProjectClicked,
                  action: LoggingActions.clicked,pageName: LoggingPageNames.myAttendance);
              CaptureEventHelper.captureEvent(loggingData: loggingData);
            }, false);
          } else {
            return const SizedBox();
          }
        });
  }

  Map<String, dynamic> getEventForAvailability() {
    Map<String, dynamic> properties = {};
    properties[CleverTapConstant.projectName] = _execution!.projectName;
    properties[CleverTapConstant.projectId] = _execution!.projectId;
    properties[CleverTapConstant.roleName] =
        _execution!.selectedProjectRole?.replaceAll('_', ' ');
    return properties;
  }

  Map<String, String> getLoggingEvents() {
    Map<String, String> properties = {};
    properties[CleverTapConstant.available] =
        availabilityInProject.toString() ?? '';
    properties[CleverTapConstant.projectId] =
        _execution!.projectId?.toString() ?? '';
    properties[CleverTapConstant.roleName] = _execution!.selectedProjectRole
            ?.replaceAll('_', ' ')
            .toString() ??
        '';
    return properties;
  }

  void onPunchTap(AttendancePunches attendancePunches) {
    List<PunchInScreens>? punchInScreenList = [];
    if (_dashboardCubit.isPunchInValue!) {
      punchInScreenList = attendancePunches.attendanceConfiguration!
          .attendanceInputConfiguration!.punchInScreens!;
    } else {
      punchInScreenList = attendancePunches.attendanceConfiguration!
          .attendanceInputConfiguration!.punchOutScreens!;
    }
    if (!punchInScreenList.isNullOrEmpty) {
      showPunchInScreen(
        punchInScreenList,
      );
    } else {
      _dashboardCubit.doPunchInPunchOut(
          _dashboardCubit.attendancePunchesValue!.executionId ?? "",
          _dashboardCubit.attendancePunchesValue!.sId ?? "",
          StringUtils.getCurrentDateTimeWithIST(),
          _dashboardCubit.isPunchInValue!,
          _dashboardCubit.isComingFromBottomSheet!);
    }
  }

  showPunchInScreen(
    List<PunchInScreens>? punchInScreenList, {
    bool? isComingFromBottomsSheet,
  }) async {
    tempPunchInScreenList = punchInScreenList;
    index = punchInScreenList!.length - tempPunchInScreenList!.length;
    if (!tempPunchInScreenList!.isNullOrEmpty) {
      if (punchInScreenList[index!].screenTitleEntity!.value ==
          ScreenTitle.takeSelfie.value) {
        PermissionStatus status = await Permission.camera.status;
        if (status.isDenied) {
          LoggingData loggingData = LoggingData(
              event: LoggingEvents.enableCameraAccessOpened,
              action: LoggingActions.opened,pageName: LoggingPageNames.enableCamera);
          CaptureEventHelper.captureEvent(loggingData: loggingData);
          showEnableCameraBottomSheet(Get.context!, () {
            MRouter.pop(null);
            captureImage(index, punchInScreenList);
          }, () {
            _dashboardCubit.getAttendancePunchesSearch(
                projectRoleId,
                StringUtils.getFormattedDateTime(StringUtils.dateFormatYMD),
                _execution?.id);
            MRouter.pop(null);
          });
        } else {
          captureImage(index, punchInScreenList);
        }
      } else if (punchInScreenList[index!].screenTitleEntity!.value ==
          ScreenTitle.yourLocation.value) {
        PermissionStatus status = await Permission.location.status;
        if (status.isDenied) {
          LoggingData loggingData = LoggingData(
              event: LoggingEvents.enableGeoLocationOpened,
              action: LoggingActions.opened,pageName: LoggingPageNames.enableGeoLocation);
          CaptureEventHelper.captureEvent(loggingData: loggingData);
          showGeolocationBottomSheet(Get.context!, () async {
            MRouter.pop(null);
            await updateCurrentLocation(
              index,
              punchInScreenList,
              tempPunchInScreenList!.length > 1,
            );
          }, () {
            _dashboardCubit.getAttendancePunchesSearch(
                projectRoleId,
                StringUtils.getFormattedDateTime(StringUtils.dateFormatYMD),
                _execution?.id);
            MRouter.pop(null);
          });
        } else {
          await updateCurrentLocation(
              index, punchInScreenList, tempPunchInScreenList!.length > 1);
        }
      } else if (punchInScreenList[index!].screenTitleEntity!.value ==
          ScreenTitle.uploadImage.value) {
        PermissionStatus status = await Permission.camera.status;
        if (status.isDenied) {
          LoggingData loggingData = LoggingData(
              event: LoggingEvents.enableAccessFilesOpened,
              action: LoggingActions.opened,pageName: LoggingPageNames.enableFileAccess);
          CaptureEventHelper.captureEvent(loggingData: loggingData);
          showEnableFileBottomSheet(Get.context!, () async {
            MRouter.pop(null);
            showUploadImage(
                index, punchInScreenList, tempPunchInScreenList!.length > 1);
          }, () {
            _dashboardCubit.getAttendancePunchesSearch(
                projectRoleId,
                StringUtils.getFormattedDateTime(StringUtils.dateFormatYMD),
                _execution?.id);
            MRouter.pop(null);
          });
        } else {
          showUploadImage(
              index, punchInScreenList, tempPunchInScreenList!.length > 1);
        }
      } else if (punchInScreenList[index!].screenTitleEntity!.value ==
          ScreenTitle.inputFields.value) {
        showInputField(
            index, punchInScreenList, tempPunchInScreenList!.length > 1);
      }
    } else {
      _dashboardCubit.doPunchInPunchOut(
          _dashboardCubit.attendancePunchesValue!.executionId ?? "",
          _dashboardCubit.attendancePunchesValue!.sId ?? "",
          StringUtils.getCurrentDateTimeWithIST(),
          _dashboardCubit.isPunchInValue!,
          _dashboardCubit.isComingFromBottomSheet!,
          attendanceAnswerEntityList: attendanceAnswerEntityList);
    }
  }

  void captureImage(int? index, List<PunchInScreens>? punchInScreenList) async {
    LoggingData loggingData = LoggingData(
        event: LoggingEvents.takingSelfieOpened,
        action: LoggingActions.opened,pageName: LoggingPageNames.takingSelfie);
    CaptureEventHelper.captureEvent(loggingData: loggingData);
    ImageDetails imageDetails =
        ImageDetails(uploadLater: false, isFrontCamera: true);
    WidgetResult? cameraWidgetResult = await MRouter.pushNamed(
        MRouter.inAppCameraWidget,
        arguments: imageDetails);
    if (cameraWidgetResult != null &&
        cameraWidgetResult.event == Event.selected &&
        cameraWidgetResult.data is ImageDetails) {
      ImageDetails imageDetails = cameraWidgetResult.data;
      for (ScreenQuestion question
          in punchInScreenList![index!].screenQuestionList!) {
        AttendanceAnswerEntity attendanceAnswerEntity = AttendanceAnswerEntity(
            uid: question.uid,
            answer: imageDetails.originalFileName,
            renderType: question.renderType,
            attributeType: question.attributeType,
            columnTitle: question.columnTitle);
        attendanceAnswerEntityList!.add(attendanceAnswerEntity);
      }
      tempPunchInScreenList?.removeAt(index);
      showPunchInScreen(punchInScreenList);
    } else {
      _dashboardCubit.getAttendancePunchesSearch(
          projectRoleId,
          StringUtils.getFormattedDateTime(StringUtils.dateFormatYMD),
          _execution?.id);
    }
  }

  Future<void> updateCurrentLocation(int? index,
      List<PunchInScreens>? punchInScreenList, bool? isNotLastScreen) async {
    try {
      await Permission.location.request();
      if (await Permission.location.request().isGranted) {
        LoggingData loggingData = LoggingData(
            event: LoggingEvents.locationCapturedOpened,
            action: LoggingActions.opened,pageName: LoggingPageNames.locationCaptured);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        showCaptureLocationBottomSheet(
            Get.context!, isNotLastScreen, (currentPosition) {
          MRouter.pop(null);
          for (ScreenQuestion question
              in punchInScreenList![index!].screenQuestionList!) {
            AttendanceAnswerEntity attendanceAnswerEntity =
                AttendanceAnswerEntity(
                    uid: question.uid,
                    answer: [
                      currentPosition!.latitude,
                      currentPosition.longitude
                    ],
                    renderType: question.renderType,
                    attributeType: question.attributeType,
                    columnTitle: question.columnTitle);
            attendanceAnswerEntityList!.add(attendanceAnswerEntity);
          }
          tempPunchInScreenList?.removeAt(index);
          showPunchInScreen(punchInScreenList);
        }, () {
          _dashboardCubit.getAttendancePunchesSearch(
              projectRoleId,
              StringUtils.getFormattedDateTime(StringUtils.dateFormatYMD),
              _execution?.id);
          MRouter.pop(null);
        });
      } else {
      }
    } catch (e) {
      print(e);
    }
  }

  void showUploadImage(int? index, List<PunchInScreens>? punchInScreenList,
      bool? isNotLastScreen) async {
    LoggingData loggingData = LoggingData(
        event: LoggingEvents.uploadImageOpened,
        action: LoggingActions.opened,pageName: LoggingPageNames.uploadImage);
    CaptureEventHelper.captureEvent(loggingData: loggingData);
    ScreenQuestionArguments screenQuestionArguments = ScreenQuestionArguments(
        questionList: punchInScreenList![index!].questions!,
        screenQuestionList: punchInScreenList[index!].screenQuestionList!,
        isNotLastScreen: isNotLastScreen);
    List<ScreenRow>? screenRowListValue = await MRouter.pushNamed(
        MRouter.attendanceUploadImageWidget,
        arguments: screenQuestionArguments);
    if (screenRowListValue != null) {
      for (int i = 0;
          i < punchInScreenList[index].screenQuestionList!.length;
          i++) {
        AttendanceAnswerEntity attendanceAnswerEntity = AttendanceAnswerEntity(
            uid: punchInScreenList[index].screenQuestionList![i].uid,
            answer: screenRowListValue[i]
                .question
                ?.answerUnit
                ?.imageDetails
                ?.originalFileName,
            renderType:
                punchInScreenList[index].screenQuestionList![i].renderType,
            attributeType:
                punchInScreenList[index].screenQuestionList![i].attributeType,
            columnTitle:
                punchInScreenList[index].screenQuestionList![i].columnTitle);
        attendanceAnswerEntityList!.add(attendanceAnswerEntity);
      }
      tempPunchInScreenList?.removeAt(index);
      showPunchInScreen(punchInScreenList);
    } else {
      _dashboardCubit.getAttendancePunchesSearch(
          projectRoleId,
          StringUtils.getFormattedDateTime(StringUtils.dateFormatYMD),
          _execution?.id);
    }
  }

  void showInputField(int? index, List<PunchInScreens>? punchInScreenList,
      bool? isNotLastScreen) async {
    ScreenQuestionArguments screenQuestionArguments = ScreenQuestionArguments(
        questionList: punchInScreenList![index!].questions!,
        screenQuestionList: punchInScreenList[index].screenQuestionList!,
        isNotLastScreen: isNotLastScreen);
    List<ScreenRow>? screenRowListValue = await MRouter.pushNamed(
        MRouter.attendanceInputFields,
        arguments: screenQuestionArguments);
    if (screenRowListValue != null) {
      for (int i = 0;
          i < punchInScreenList[index].screenQuestionList!.length;
          i++) {
        AttendanceAnswerEntity attendanceAnswerEntity = AttendanceAnswerEntity(
            uid: punchInScreenList[index].screenQuestionList![i].uid,
            answer: screenRowListValue[i]
                .question
                ?.answerUnit
                ?.imageDetails
                ?.originalFileName,
            renderType:
                punchInScreenList[index].screenQuestionList![i].renderType,
            attributeType:
                punchInScreenList[index].screenQuestionList![i].attributeType,
            columnTitle:
                punchInScreenList[index].screenQuestionList![i].columnTitle);
        attendanceAnswerEntityList!.add(attendanceAnswerEntity);
      }
      tempPunchInScreenList?.removeAt(index);
      showPunchInScreen(
        punchInScreenList,
      );
    } else {
      _dashboardCubit.getAttendancePunchesSearch(
          projectRoleId,
          StringUtils.getFormattedDateTime(StringUtils.dateFormatYMD),
          _execution?.id);
    }
  }
}
