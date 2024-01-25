import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/app_config_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/moengage/moengage_helper.dart';
import 'package:awign/workforce/core/data/repository/core_remote_repository.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/widget/take_a_tour/tour_keys.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:moengage_flutter/properties.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/network/factory/headers_utils.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final AuthRemoteRepository _authRemoteRepository;
  final CoreRemoteRepository _coreRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _validateTokenResponse = BehaviorSubject<ValidateTokenResponse>();
  Stream<ValidateTokenResponse> get validateTokenResponse =>
      _validateTokenResponse.stream;

  final _userProfileResponse = BehaviorSubject<UserProfileResponse>();
  Stream<UserProfileResponse> get userProfileResponse =>
      _userProfileResponse.stream;

  final _validTokenWithProfile = BehaviorSubject<ValidateTokenResponse>();
  Stream<ValidateTokenResponse> get validTokenWithProfile =>
      _validTokenWithProfile.stream;

  final _appConfigResponse = BehaviorSubject<AppConfigResponse>();
  Stream<AppConfigResponse> get appConfigResponse => _appConfigResponse.stream;

  SplashCubit(this._authRemoteRepository, this._coreRemoteRepository)
      : super(SplashInitial()){
    Rx.combineLatest2(
      _validateTokenResponse.stream,
      _userProfileResponse.stream,
          (ValidateTokenResponse validateTokenResponse,
          UserProfileResponse userProfileResponse) {
        validateTokenResponse.user?.userProfile =
            userProfileResponse.userProfile;
        return validateTokenResponse;
      },
    ).listen((validateTokenResponse) async {
      SPUtil? spUtil = await SPUtil.getInstance();
      spUtil?.putUserData(validateTokenResponse.user);
      spUtil?.putAccessToken(validateTokenResponse.headers!.accessToken);
      spUtil?.putClient(validateTokenResponse.headers!.client);
      spUtil?.putUID(validateTokenResponse.headers!.uid);
      spUtil?.putSaasOrgID(validateTokenResponse.headers!.saasOrgID != null
          ? validateTokenResponse.headers!.saasOrgID!
          : '');
      changeUIStatus(UIStatus(isDialogLoading: false));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.add(validateTokenResponse);
      }
    });
  }

  @override
  Future<void> close() {
    _uiStatus.close();
    _validateTokenResponse.close();
    _userProfileResponse.close();
    _validTokenWithProfile.close();
    return super.close();
  }

  void validateTokenAndGetUserProfile(int? userID) async {
    validateToken();
    getUserProfile(userID);
  }

  void validateToken() async {
    try {
      changeUIStatus(UIStatus(isDialogLoading: true));
      Tuple2<ValidateTokenResponse, String?> tuple2 =
          await _authRemoteRepository.validateToken();
      if (!_validateTokenResponse.isClosed) {
        _validateTokenResponse.sink.add(tuple2.item1);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } catch (e, st) {
      AppLog.e('validateToken : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink
            .addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void getUserProfile(int? userID) async {
    try {
      changeUIStatus(UIStatus(isDialogLoading: true));
      UserProfileResponse userProfileResponse =
          await _authRemoteRepository.getUserProfile(userID);
      if (!_userProfileResponse.isClosed) {
        _userProfileResponse.sink.add(userProfileResponse);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } catch (e, st) {
      AppLog.e('getUserProfile : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink
            .addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void getLaunchConfig() async {
    try {
      changeUIStatus(UIStatus(isDialogLoading: true));
      AppConfigResponse appConfigResponse =
          await _coreRemoteRepository.getLaunchConfig();
      if (!_appConfigResponse.isClosed) {
        _appConfigResponse.sink.add(appConfigResponse);
      }
      SPUtil? spUtil = await SPUtil.getInstance();
      spUtil?.putLaunchConfigData(appConfigResponse);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_appConfigResponse.isClosed) {
        _appConfigResponse.sink.addError(e.message ?? '');
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_appConfigResponse.isClosed) {
        _appConfigResponse.sink.addError(e.message ?? '');
      }
    } catch (e, st) {
      AppLog.e('getLaunchConfig : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_appConfigResponse.isClosed) {
        _appConfigResponse.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void signInWhatsappLogin(String token) async {
    try {
      Tuple2<LoginResponse, String?> tuple2 =
      await _authRemoteRepository.signInWhatsappLogin(token);
      SPUtil? spUtil = await SPUtil.getInstance();
      spUtil?.putUserData(tuple2.item1.user);
      spUtil?.putAccessToken(tuple2.item1.headers?.accessToken ?? '');
      spUtil?.putClient(tuple2.item1.headers?.client ?? '');
      spUtil?.putUID(tuple2.item1.headers?.uid ?? '');
      spUtil?.putSaasOrgID(tuple2.item1.headers?.saasOrgID != null
          ? tuple2.item1.headers!.saasOrgID!
          : 'nil');
      if (tuple2.item1.user.email == null) {
        validateTokenAndGetUserProfile(tuple2.item1.user.id);
        changeUIStatus(UIStatus(event: Event.failed));
      } else {
        validateTokenAndGetUserProfile(tuple2.item1.user.id);
        // TourKeys.loginCount++;
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('signInWhatsappLogin : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  Future<void> funAppLaunch(UserData? userData) async {
    if(userData != null) {
      MoEngage.setUniqueId(userData.id.toString());
      MoEngage.trackEvent(MoEngage.openApp, null);
    }
  }
}
