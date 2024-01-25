import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_response.dart';
import 'package:awign/workforce/onboarding/data/repository/campus_ambassador/campus_ambassador_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../auth/data/model/device_info.dart';
import '../../../../core/utils/device_info_utils.dart';

part 'more_state.dart';

class MoreCubit extends Cubit<MoreState> {
  final CampusAmbassadorRemoteRepository _campusAmbassadorRemoteRepository;
  final AuthRemoteRepository _authRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _isDarkMode = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isDarkMode => _isDarkMode.stream;

  Function(bool) get changeIsDarkMode => _isDarkMode.sink.add;

  final campusAmbassadorResponse = BehaviorSubject<CampusAmbassadorResponse>();

  Stream<CampusAmbassadorResponse> get campusAmbassadorResponseStream =>
      campusAmbassadorResponse.stream;

  Function(CampusAmbassadorResponse) get changeExecution =>
      campusAmbassadorResponse.sink.add;

  final _currentUser = BehaviorSubject<UserData>();

  Stream<UserData> get currentUser => _currentUser.stream;

  Function(UserData) get changeCurrentUser => _currentUser.sink.add;

  final _versionRelease = BehaviorSubject<String>();

  Stream<String> get versionReleaseStream => _versionRelease.stream;

  Function(String) get changeVersionRelease => _versionRelease.sink.add;

  MoreCubit(this._campusAmbassadorRemoteRepository, this._authRemoteRepository)
      : super(MoreInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _isDarkMode.close();
    campusAmbassadorResponse.close();
    _versionRelease.close();
    return super.close();
  }

  void checkAndSetThemeMode() {
    if (Get.isDarkMode) {
      changeIsDarkMode(true);
    } else {
      changeIsDarkMode(false);
    }
  }

  void changeTheme(v) async {
    SPUtil? spUtil = await SPUtil.getInstance();
    if (Get.isDarkMode) {
      Get.changeThemeMode(ThemeMode.light);
    } else {
      Get.changeThemeMode(ThemeMode.dark);
    }
    changeIsDarkMode(v);
    spUtil?.putIsDarkModeEnabled(v);
  }

  void getCampusAmbassador(int userId) async {
    try {
      CampusAmbassadorResponse campusAmbassdorResponse =
          await _campusAmbassadorRemoteRepository.getCampusAmbassador(userId);
      if (!campusAmbassadorResponse.isClosed) {
        campusAmbassadorResponse.sink.add(campusAmbassdorResponse);
      } else {
        campusAmbassadorResponse.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(event: Event.updated));
      if (!campusAmbassadorResponse.isClosed) {
        campusAmbassadorResponse.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(event: Event.updated));
      if (!campusAmbassadorResponse.isClosed) {
        campusAmbassadorResponse.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getCampusAmbassador : ${e.toString()} \n${st.toString()}');
      if (!campusAmbassadorResponse.isClosed) {
        campusAmbassadorResponse.sink
            .addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void deleteUserAccount(int userID) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      ApiResponse apiResponse =
          await _authRemoteRepository.deleteUserAccount(userID);
      changeUIStatus(UIStatus(isDialogLoading: false, event: Event.deleted));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('deleteUserAccount : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void getUserProfile(UserData currentUser) async {
    try {
      UserProfileResponse userProfileResponse =
          await _authRemoteRepository.getUserProfile(currentUser.id ?? -1);
      if (!_currentUser.isClosed) {
        currentUser.userProfile = userProfileResponse.userProfile;
        SPUtil? spUtil = await SPUtil.getInstance();
        spUtil?.putUserData(currentUser);
        changeCurrentUser(currentUser);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_currentUser.isClosed) {
        _currentUser.sink.addError(e.message ?? '');
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_currentUser.isClosed) {
        _currentUser.sink.addError(e.message ?? '');
      }
    } catch (e, st) {
      AppLog.e('getUserProfile : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_currentUser.isClosed) {
        _currentUser.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  Future<void> getDeviceInfo() async {
    DeviceInfo? deviceInfo = await DeviceInfoUtils.getDeviceInfoData();
    if (deviceInfo?.primaryAppVersion != null) {
      changeVersionRelease(deviceInfo!.primaryAppVersion!);
    }
  }
}
