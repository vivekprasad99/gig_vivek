import 'dart:io';

import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:awign/workforce/execution_in_house/data/model/attendance_punches_update_response.dart';
import 'package:awign/workforce/execution_in_house/data/repository/attendance/attendance_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/data/attendance_answer_entity.dart';
import 'package:awign/workforce/file_storage_remote/data/model/aws_upload_result.dart';
import 'package:awign/workforce/file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/model/attendance_punches_response.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRemoteRepository _attendanceRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _attendancePunchesResponse = BehaviorSubject<List<AttendancePunches>?>();
  Stream<List<AttendancePunches>?> get attendancePunchesResponseStream => _attendancePunchesResponse.stream;
  Function(List<AttendancePunches>?) get changeAttendancePunchesResponse => _attendancePunchesResponse.sink.add;

  final _executionId = BehaviorSubject<String?>();
  Function(String?) get changeExecutionId => _executionId.sink.add;
  String? get executionIdValue => _executionId.value;

  final _attendanceId = BehaviorSubject<String?>();
  Function(String?) get changeAttendanceId => _attendanceId.sink.add;
  String? get attendanceIdValue => _attendanceId.value;

  final _isPunchIn = BehaviorSubject<bool?>();
  Function(bool?) get changeIsPunchIn => _isPunchIn.sink.add;
  bool? get isPunchInValue => _isPunchIn.value;

  final _projectId = BehaviorSubject<String?>();
  Function(String?) get changeProjectId => _projectId.sink.add;
  String? get projectIdValue => _projectId.value;

  final _projectRoleId = BehaviorSubject<String?>();
  Function(String?) get changeProjectRoleId => _projectRoleId.sink.add;
  String? get projectRoleIdValue => _projectRoleId.value;

  final _imageDetail = BehaviorSubject<ImageDetails?>();
  Function(ImageDetails?) get changeImageDetail => _imageDetail.sink.add;
  ImageDetails? get imageDetailValue => _imageDetail.value;

  AttendanceCubit(this._attendanceRemoteRepository) : super(AttendanceInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    return super.close();
  }

  void getAttendancePunchesSearch(String memberId,String currentDate) async {
    try {
      AttendancePunchesResponse? attendancePunchesResponse = await _attendanceRemoteRepository.getAttendancePunchesSearch(currentDate,memberId: memberId);
      _attendancePunchesResponse.sink.add(attendancePunchesResponse?.attendancePunches);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getAttendancePunchesSearch : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void doPunchInPunchOut(String executionId,String attendanceId,String punchInTime,bool punchStatus,{List<AttendanceAnswerEntity>? attendanceAnswerEntityList}) async {
    try {
      AttendancePunchesUpdateResponse attendancePunchesUpdateResponse = await _attendanceRemoteRepository.getAttendancePunchesUpdate(executionId, attendanceId, punchInTime,punchStatus,attendanceAnswerEntityList: attendanceAnswerEntityList);
      if(punchStatus)
        {
          changeUIStatus(UIStatus(event: Event.success,data: attendancePunchesUpdateResponse.data?.attendancePunch?.punchInTime));
        }else{
        changeUIStatus(
            UIStatus(successWithoutAlertMessage: 'Punched Out Successfully',event: Event.updated));
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('doPunchInPunchOut : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  Future upload(Question question, ImageDetails imageDetails) async {
    File file = imageDetails.getFile()!;
    String? updatedFileName, s3FolderPath;
    updatedFileName = file.name?.cleanForUrl();
    s3FolderPath = question.parentReference?.getUploadPath(file.name!);
    if (updatedFileName != null && s3FolderPath != null) {
      AWSUploadResult? awsUploadResult = await sl<RemoteStorageRepository>()
          .uploadFile(file, updatedFileName, s3FolderPath);
      question.answerUnit?.stringValue = awsUploadResult?.url;
      imageDetails.url = awsUploadResult?.url;
      question.answerUnit?.imageDetails = imageDetails;
      _imageDetail.sink.add(imageDetails);
    }
  }

}
