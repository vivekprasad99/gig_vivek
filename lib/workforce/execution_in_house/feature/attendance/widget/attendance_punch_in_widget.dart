import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_actions.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_events.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/attendance_sucessfull_bottom_sheet/widget/attendance_sucessfull_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/enable_camera_bottom_sheet/widget/enable_camera_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/enable_file_bottom_sheet/widget/enable_file_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/geolocation_bottom_sheet/widget/geolocation_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/location_captured_bottom_sheet/widget/location_captured_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/data/attendance_answer_entity.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/data/screen_question_arguments.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/widget/tile/attendance_tile.dart';
import 'package:awign/workforce/execution_in_house/feature/dashboard/data/model/dashboard_widget_argument.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../data/model/attendance_punches_response.dart';
import '../cubit/attendance_cubit.dart';

class AttendancePunchInWidget extends StatefulWidget {
  final String? memberId;

  const AttendancePunchInWidget({
    Key? key,
    this.memberId,
  }) : super(key: key);

  @override
  State<AttendancePunchInWidget> createState() =>
      _AttendancePunchInWidgetState();
}

class _AttendancePunchInWidgetState extends State<AttendancePunchInWidget> {
  final AttendanceCubit _attendanceCubit = sl<AttendanceCubit>();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    subscribeUIStatus();
  }

  List<PunchInScreens>? tempPunchInScreenList;
  int? index;
  List<AttendanceAnswerEntity>? attendanceAnswerEntityList = [];

  void subscribeUIStatus() {
    _attendanceCubit.uiStatus.listen(
      (uiStatus) async {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage,
              color: AppColors.success300);
        }
        switch (uiStatus.event) {
          case Event.none:
            break;
          case Event.success:
            attendanceSucessfullBottomSheet(context, uiStatus.data as String,
                () {
              getCurrentUser();
              MRouter.pop(null);
              DashboardWidgetArgument dashboardWidgetArgument =
                  DashboardWidgetArgument(
                      executionID: _attendanceCubit.executionIdValue,
                      projectID: _attendanceCubit.projectIdValue,
                      projectRoleUID: _attendanceCubit.projectRoleIdValue);
              MRouter.pushNamed(MRouter.dashboardWidget,
                  arguments: dashboardWidgetArgument);
            });
            LoggingData loggingData = LoggingData(
                event: LoggingEvents.attendanceSuccessfulOpened,
                action: LoggingActions.opened,pageName: LoggingPageNames.attendanceMarkedSuccessful);
            CaptureEventHelper.captureEvent(loggingData: loggingData);
            break;
          case Event.updated:
            getCurrentUser();
            break;
        }
      },
    );
  }

  void getCurrentUser() async {
    _attendanceCubit.getAttendancePunchesSearch(widget.memberId!,
        StringUtils.getFormattedDateTime(StringUtils.dateFormatYMD));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AttendancePunches>?>(
        stream: _attendanceCubit.attendancePunchesResponseStream,
        builder: (context, attendancePunchesResponse) {
          if (attendancePunchesResponse.hasData &&
              attendancePunchesResponse.data!.isNotEmpty) {
            List<AttendancePunches>? attendanceList =
                getAttendanceList(attendancePunchesResponse.data!);
            if (attendanceList.length == 1) {
              return AttendanceTile(attendanceList[0],
                  (bool isPunchIn, String attendanceId) {
                _attendanceCubit
                    .changeExecutionId(attendanceList[0].executionId ?? "");
                _attendanceCubit.changeAttendanceId(attendanceId);
                _attendanceCubit.changeIsPunchIn(isPunchIn);
                _attendanceCubit.changeProjectId(attendanceList[0].projectId);
                _attendanceCubit
                    .changeProjectRoleId(attendanceList[0].projectRoleId);
                attendanceAnswerEntityList?.clear();
                onPunchTap(attendanceList[0]);
                captureEvent(isPunchIn);
              }, true);
            } else if (attendanceList.isEmpty) {
              return const SizedBox();
            } else {
              return CarouselSlider(
                  items: List.generate(attendanceList.length, (index) {
                    return AttendanceTile(attendanceList[index],
                        (bool isPunchIn, String attendanceId) {
                      _attendanceCubit.changeExecutionId(
                          attendanceList[index].executionId ?? "");
                      _attendanceCubit.changeAttendanceId(attendanceId);
                      _attendanceCubit.changeIsPunchIn(isPunchIn);
                      _attendanceCubit
                          .changeProjectId(attendanceList[0].projectId);
                      _attendanceCubit
                          .changeProjectRoleId(attendanceList[0].projectRoleId);
                      attendanceAnswerEntityList?.clear();
                      onPunchTap(attendanceList[index]);
                      captureEvent(isPunchIn);
                    }, true);
                  }),
                  options: CarouselOptions(
                      viewportFraction: 0.9,
                      autoPlay: false,
                      autoPlayInterval: const Duration(seconds: 5)));
            }
          } else {
            return const SizedBox();
          }
        });
  }

  List<AttendancePunches> getAttendanceList(
      List<AttendancePunches>? attendanceList) {
    List<AttendancePunches> attendancesList = [];
    for (AttendancePunches attendancePunches in attendanceList!) {
      if (attendancePunches.nextPunchCta == "punch_in" ||
          attendancePunches.nextPunchCta == Constants.punchOut ||
          attendancePunches.nextPunchCta == Constants.punchInTimePassed ||
          attendancePunches.nextPunchCta == Constants.punchOutTimePassed) {
        attendancesList.add(attendancePunches);
      }
    }
    return attendancesList;
  }

  void onPunchTap(AttendancePunches attendancePunches) {
    List<PunchInScreens>? punchInScreenList = [];
    if (_attendanceCubit.isPunchInValue!) {
      punchInScreenList = attendancePunches.attendanceConfiguration!
          .attendanceInputConfiguration!.punchInScreens!;
    } else {
      punchInScreenList = attendancePunches.attendanceConfiguration!
          .attendanceInputConfiguration!.punchOutScreens!;
    }
    if (!punchInScreenList.isNullOrEmpty) {
      showPunchInScreen(punchInScreenList);
    } else {
      _attendanceCubit.doPunchInPunchOut(
          _attendanceCubit.executionIdValue!,
          _attendanceCubit.attendanceIdValue!,
          StringUtils.getCurrentDateTimeWithIST(),
          _attendanceCubit.isPunchInValue!);
    }
  }

  showPunchInScreen(List<PunchInScreens>? punchInScreenList,
      {String? executionId, String? attendanceId, bool? punchStatus}) async {
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
            getCurrentUser();
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
            getCurrentUser();
            MRouter.pop(null);
          });
        } else {
          await updateCurrentLocation(
            index,
            punchInScreenList,
            tempPunchInScreenList!.length > 1,
          );
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
            getCurrentUser();
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
      _attendanceCubit.doPunchInPunchOut(
          _attendanceCubit.executionIdValue!,
          _attendanceCubit.attendanceIdValue!,
          StringUtils.getCurrentDateTimeWithIST(),
          _attendanceCubit.isPunchInValue!,
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
        MRouter.attendanceCaptureImageWidget,
        arguments: imageDetails);
    if (cameraWidgetResult != null &&
        cameraWidgetResult.event == Event.selected &&
        cameraWidgetResult.data is ImageDetails) {
      ImageDetails imageDetails = cameraWidgetResult.data;
      await _attendanceCubit.upload(
          punchInScreenList![index!].questions![0], imageDetails);
      for (ScreenQuestion question
          in punchInScreenList[index].screenQuestionList!) {
        AttendanceAnswerEntity attendanceAnswerEntity = AttendanceAnswerEntity(
            uid: question.uid,
            answer: _attendanceCubit.imageDetailValue?.url,
            renderType: question.renderType,
            attributeType: question.attributeType,
            columnTitle: question.columnTitle);
        attendanceAnswerEntityList!.add(attendanceAnswerEntity);
      }
      tempPunchInScreenList?.removeAt(index);
      showPunchInScreen(punchInScreenList);
    } else {
      getCurrentUser();
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
        showCaptureLocationBottomSheet(Get.context!, isNotLastScreen,
            (currentPosition) {
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
          getCurrentUser();
          MRouter.pop(null);
        });
      } else {
        // currentPosition = null;
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
            answer:
                screenRowListValue[i].question?.answerUnit?.imageDetails?.url,
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
      getCurrentUser();
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
        dynamic answer =
            screenRowListValue[i].question?.answerUnit?.stringValue ??
                screenRowListValue[i].question?.answerUnit?.listValue ??
                [
                  screenRowListValue[i].question?.answerUnit?.answerRange?.from,
                  screenRowListValue[i].question?.answerUnit?.answerRange?.to
                ];
        AttendanceAnswerEntity attendanceAnswerEntity = AttendanceAnswerEntity(
            uid: punchInScreenList[index].screenQuestionList![i].uid,
            answer: answer,
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
      getCurrentUser();
    }
  }

  void captureEvent(bool isPunchIn) {
    LoggingData loggingData = LoggingData(
        event: isPunchIn
            ? LoggingEvents.punchInMyJobsClicked
            : LoggingEvents.punchOutMyJobsClicked,
        action: LoggingActions.clicked,pageName: LoggingPageNames.myJobs);
    CaptureEventHelper.captureEvent(loggingData: loggingData);
  }
}
