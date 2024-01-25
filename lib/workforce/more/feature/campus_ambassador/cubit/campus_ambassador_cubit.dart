import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_data.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_entity.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/repository/campus_ambassador/campus_ambassador_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/data/model/api_response.dart';
import '../../../../onboarding/data/model/campus_ambassador/workapplication_request.dart';

part 'campus_ambassador_state.dart';

class CampusAmbassadorCubit extends Cubit<CampusAmbassadorState> {
  final CampusAmbassadorRemoteRepository _campusAmbassadorRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _campusAmbassdorResponse = BehaviorSubject<CampusAmbassadorResponse>();
  Stream<CampusAmbassadorResponse> get campusAmbassdorResponse =>
      _campusAmbassdorResponse.stream;

  Function(CampusAmbassadorResponse) get changeExecution =>
      _campusAmbassdorResponse.sink.add;

  final _applicationCount = BehaviorSubject<num>();
  Stream<num> get applicationCount => _applicationCount.stream;

  final _selectedCount = BehaviorSubject<num>();
  Stream<num> get selectedCount => _selectedCount.stream;

  final _workingCount = BehaviorSubject<num>();
  Stream<num> get workingCount => _workingCount.stream;

  CampusApplicationData campusApplicationData = CampusApplicationData();

  CampusAmbassadorCubit(
       this._campusAmbassadorRemoteRepository)
      : super(CampusAmbassadorInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _campusAmbassdorResponse.close();
    _applicationCount.close();
    _selectedCount.close();
    _workingCount.close();
    return super.close();
  }

  Future<void> createCampusAmbassador(String mobileNumber, int collegeId,
      String referralCode, int userId) async {
    try {
    ApiResponse data = await _campusAmbassadorRemoteRepository.createCampusAmbassador(
          mobileNumber, collegeId, referralCode, userId);
    if(data.status == Constants.created)
      {
        changeUIStatus(UIStatus(event: Event.success));
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('createCampusAmbassador : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void getCampusAmbassador(int userId) async {
    try {
      CampusAmbassadorResponse campusAmbassdorResponse =
          await _campusAmbassadorRemoteRepository.getCampusAmbassador(userId);
      if (!_campusAmbassdorResponse.isClosed) {
        _campusAmbassdorResponse.sink.add(campusAmbassdorResponse);
      } else {
        _campusAmbassdorResponse.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: e.message!, event: Event.updated));
      if (!_campusAmbassdorResponse.isClosed) {
        _campusAmbassdorResponse.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: e.message!, event: Event.updated));
      if (!_campusAmbassdorResponse.isClosed) {
        _campusAmbassdorResponse.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getCampusAmbassador : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_campusAmbassdorResponse.isClosed) {
        _campusAmbassdorResponse.sink
            .addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  Future<List<CampusAmbassadorTasks>?> getCATask(
      int pageIndex, String? searchTerm) async {
    try {
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? _user = spUtil?.getUserData();
      CampusAmbassdorTaskRespons data = await _campusAmbassadorRemoteRepository
          .getCATask(_user!.id!, pageIndex);
      return data.campusAmbassadorTasks;
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getCATask : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void getCampusAmbassadorAnalyze(
      int workListingid, String referralCode) async {
    try {
      Map<String, num> data = await _campusAmbassadorRemoteRepository
          .getCampusAmbassadorAnalyze(workListingid, referralCode);
      _applicationCount.sink.add(data['all'] ?? 0);
      _selectedCount.sink.add(data['selected'] ?? 0);
      _workingCount.sink.add(data['working'] ?? 0);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e(
          'getCampusAmbassadorAnalyze : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  Future<List<WorkApplicationEntity>?> caApplicationSearch(
      int pageIndex, String? searchTerm) async {
    try {
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? _user = spUtil?.getUserData();
      bool isSkipSaasOrgId = true;
      WorkApplicationPageRequest workApplicationPageRequest;
      String? saasOrgIDValue = spUtil?.getSaasOrgID();
      if (saasOrgIDValue!.isNotEmpty) {
        isSkipSaasOrgId = false;
      }
      if (campusApplicationData.isConditionEqual!) {
        workApplicationPageRequest = WorkApplicationPageRequest(
            userId: _user!.id!,
            validStatuses: campusApplicationData.statusList,
            referredBy: campusApplicationData.referralCode,
            workListingId: campusApplicationData.workListingId,
            skipSaasOrgId: isSkipSaasOrgId);
      } else {
        workApplicationPageRequest = WorkApplicationPageRequest(
            userId: _user!.id!,
            invalidStatuses: campusApplicationData.statusList,
            referredBy: campusApplicationData.referralCode,
            workListingId: campusApplicationData.workListingId,
            skipSaasOrgId: isSkipSaasOrgId);
      }
      WorkApplicationResponse workApplicationResponse =
          await _campusAmbassadorRemoteRepository.caApplicationSearch(
              workApplicationPageRequest, pageIndex);
      return workApplicationResponse.workApplicationList;
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('createCampusAmbassador : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
