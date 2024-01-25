import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'email_sign_in_state.dart';

class EmailSignInCubit extends Cubit<EmailSignInState> with Validator {
  final AuthRemoteRepository _authRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _email = BehaviorSubject<String?>();

  Stream<String?> get email => _email.stream.transform(validateEmail);

  Function(String?) get changeEmail => _email.sink.add;

  final _password = BehaviorSubject<String?>();

  Stream<String?> get password => _password.stream.transform(validatePassword);

  Function(String?) get changePassword => _password.sink.add;

  final _loginResponse = BehaviorSubject<LoginResponse>();

  Stream<LoginResponse> get loginResponse => _loginResponse.stream;

  final _validateTokenResponse = BehaviorSubject<ValidateTokenResponse>();

  Stream<ValidateTokenResponse> get validateTokenResponse =>
      _validateTokenResponse.stream;

  Function(ValidateTokenResponse) get changeValidateTokenResponse =>
      _validateTokenResponse.sink.add;

  final _userProfileResponse = BehaviorSubject<UserProfileResponse>();

  Stream<UserProfileResponse> get userProfileResponse =>
      _userProfileResponse.stream;

  final _validTokenWithProfile = BehaviorSubject<ValidateTokenResponse>();

  Stream<ValidateTokenResponse> get validTokenWithProfile =>
      _validTokenWithProfile.stream;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  EmailSignInCubit(this._authRemoteRepository) : super(EmailSignInInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _email.close();
    _password.close();
    _loginResponse.close();
    _validateTokenResponse.close();
    _userProfileResponse.close();
    _validTokenWithProfile.close();
    buttonStatus.close();
    return super.close();
  }

  void signInByEmail() async {
    // try {TODOREMOVE
    //   if (Validator.checkEmail(_email.hasValue ? _email.value : '') != null) {
    //     changeUIStatus(UIStatus(
    //         failedWithoutAlertMessage:
    //             Validator.checkEmail(_email.hasValue ? _email.value : '')!));
    //     return;
    //   } else if (Validator.checkPassword(
    //           _password.hasValue ? _password.value : '') !=
    //       null) {
    //     changeUIStatus(UIStatus(
    //         failedWithoutAlertMessage: Validator.checkPassword(
    //             _password.hasValue ? _password.value : '')!));
    //     return;
    //   }
    //   changeButtonStatus(
    //       ButtonStatus(isLoading: true, message: 'please_wait'.tr));
    //   Tuple2<LoginResponse, String?> tuple2 = await _authRemoteRepository
    //       .signInByEmail(_email.value!, _password.value!);
    //   SPUtil? spUtil = await SPUtil.getInstance();
    //   spUtil?.putUserData(tuple2.item1.user);
    //   spUtil?.putAccessToken(tuple2.item1.headers?.accessToken ?? '');
    //   spUtil?.putClient(tuple2.item1.headers?.client ?? '');
    //   spUtil?.putUID(tuple2.item1.headers?.uid ?? '');
    //   spUtil?.putSaasOrgID(tuple2.item1.headers?.saasOrgID != null
    //       ? tuple2.item1.headers!.saasOrgID!
    //       : 'nil');
    //   Map<String, dynamic> properties =
    //       await UserProperty.getUserProperty(tuple2.item1.user);
    //   ClevertapData clevertapData = ClevertapData(
    //       eventName: ClevertapHelper.emailSignup, properties: properties);
    //   CaptureEventHelper.captureEvent(clevertapData: clevertapData);
    //   validateTokenAndGetUserProfile(tuple2.item1.user.id, tuple2.item2);
    // } on ServerException catch (e) {
    //   changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    //   changeButtonStatus(
    //       ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
    // } on FailureException catch (e) {
    //   changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    //   changeButtonStatus(
    //       ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
    // } catch (e, st) {
    //   AppLog.e('signInByEmail : ${e.toString()} \n${st.toString()}');
    //   changeUIStatus(UIStatus(
    //       isDialogLoading: false,
    //       failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    // }
  }

  void validateTokenAndGetUserProfile(int? userID, String? message) async {
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
      changeButtonStatus(ButtonStatus(isSuccess: true, message: message ?? ''));
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.add(validateTokenResponse);
      }
    });
    validateToken();
    getUserProfile(userID);
  }

  void validateToken() async {
    try {
      Tuple2<ValidateTokenResponse, String?> tuple2 =
          await _authRemoteRepository.validateToken();
      if (!_validateTokenResponse.isClosed) {
        _validateTokenResponse.sink.add(tuple2.item1);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } catch (e, st) {
      AppLog.e('validateToken : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink
            .addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void getUserProfile(int? userID) async {
    try {
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
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink
            .addError('we_regret_the_technical_error'.tr);
      }
    }
  }
}
