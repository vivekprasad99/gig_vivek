import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'welcome_state.dart';

class WelcomeCubit extends Cubit<WelcomeState> {
  final AuthRemoteRepository _authRemoteRepository;
  late GoogleSignInAccount _googleSignInAccount;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

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

  WelcomeCubit(this._authRemoteRepository) : super(WelcomeInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _validateTokenResponse.close();
    _userProfileResponse.close();
    _validTokenWithProfile.close();
    return super.close();
  }

  void googleSignIn() async {
    try {
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) return;
      _googleSignInAccount = googleAccount;
      signInByGoogle(googleAccount);
    } catch (e) {
      AppLog.e('googleSignIn : ${e.toString()}');
    }
  }

  void signInByGoogle(GoogleSignInAccount googleAccount) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      Tuple2<LoginResponse, String?> tuple2 = await _authRemoteRepository
          .signInByGoogle(
              googleAccount.id,
              googleAccount.displayName ?? '',
              googleAccount.email,
              googleAccount.photoUrl ?? '',
              Constants.googleProvider,
              [Constants.intern]);
      SPUtil? spUtil = await SPUtil.getInstance();
      spUtil?.putUserData(tuple2.item1.user);
      spUtil?.putAccessToken(tuple2.item1.headers?.accessToken ?? '');
      spUtil?.putClient(tuple2.item1.headers?.client ?? '');
      spUtil?.putUID(tuple2.item1.headers?.uid ?? '');
      spUtil?.putSaasOrgID(tuple2.item1.headers?.saasOrgID != null
          ? tuple2.item1.headers!.saasOrgID!
          : 'nil');
      validateTokenAndGetUserProfile(tuple2.item1.user.id, tuple2.item2);
      Map<String, dynamic> properties =
          await UserProperty.getUserProperty(tuple2.item1.user);
      ClevertapData clevertapData = ClevertapData(
          eventName: ClevertapHelper.googleSignup, properties: properties);
      CaptureEventHelper.captureEvent(clevertapData: clevertapData);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('signInByGoogle : ${e.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
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
      changeUIStatus(UIStatus(
          isDialogLoading: false, successWithoutAlertMessage: message ?? ''));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.add(validateTokenResponse);
      }
    });
    validateToken();
    getUserProfile(userID);
  }

  void validateToken() async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
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
    } catch (e) {
      AppLog.e('validateToken : ${e.toString()}');
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
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
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
    } catch (e) {
      AppLog.e('getUserProfile : ${e.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink
            .addError('we_regret_the_technical_error'.tr);
      }
    }
  }
}
