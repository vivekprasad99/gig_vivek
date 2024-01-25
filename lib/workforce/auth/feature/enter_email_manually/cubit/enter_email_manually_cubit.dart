import 'package:awign/workforce/auth/data/model/onboarding_completion_stage.dart';
import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
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

part 'enter_email_manually_state.dart';

class EnterEmailManuallyCubit extends Cubit<EnterEmailManuallyState>
    with Validator {
  final AuthRemoteRepository _authRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _email = BehaviorSubject<String?>();

  Stream<String?> get email => _email.stream.transform(validateEmail);

  Function(String?) get changeEmail => _email.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  EnterEmailManuallyCubit(this._authRemoteRepository)
      : super(EnterEmailManuallyInitial()) {
    _email.listen((value) {
      _checkValidation();
    });
  }

  _checkValidation() {
    if (!_email.isClosed &&
        _email.hasValue &&
        Validator.checkEmail(_email.value) == null) {
      changeButtonStatus(ButtonStatus(isEnable: true));
    } else {
      changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  @override
  Future<void> close() {
    _uiStatus.close();
    _email.close();
    buttonStatus.close();
    return super.close();
  }

  void emailUpdate(UserData currentUser) async {
    try {
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));
      ApiResponse apiResponse = await _authRemoteRepository.emailUpdate(
          currentUser.id, _email.value!);
      SPUtil? spUtil = await SPUtil.getInstance();
      currentUser.email = _email.value;
      currentUser.userProfile?.onboardingCompletionStage =
          OnboardingCompletionStage.personalDetails;
      spUtil?.putUserData(currentUser);
      changeButtonStatus(
          ButtonStatus(isSuccess: true, message: apiResponse.message ?? ''));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(event: Event.updated));
    } on ServerException catch (e) {
      changeUIStatus(
          UIStatus(event: Event.failed, failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(
          UIStatus(event: Event.failed, failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
    } catch (e, st) {
      AppLog.e('emailUpdate : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          event: Event.failed,
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
