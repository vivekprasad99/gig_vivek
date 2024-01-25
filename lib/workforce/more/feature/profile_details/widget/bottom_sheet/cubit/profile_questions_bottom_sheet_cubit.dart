import 'package:awign/workforce/auth/data/model/submit_answer_request.dart';
import 'package:awign/workforce/auth/data/repository/bff/bff_remote_repository.dart';
import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_screen.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'profile_questions_bottom_sheet_state.dart';

class ProfileQuestionsBottomSheetCubit
    extends Cubit<ProfileQuestionsBottomSheetState> {
  final BFFRemoteRepository _bffRemoteRepository;
  final _awQuestionsCubit = sl<AwQuestionsCubit>();

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _saveButtonVisibility = BehaviorSubject<bool>.seeded(true);

  Stream<bool> get saveButtonVisibilityStream => _saveButtonVisibility.stream;

  Function(bool) get changeSaveButtonVisibility =>
      _saveButtonVisibility.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  ProfileQuestionsBottomSheetCubit(this._bffRemoteRepository)
      : super(ProfileQuestionsBottomSheetInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    buttonStatus.close();
    _saveButtonVisibility.close();
    return super.close();
  }

  void submitAnswer(UserData currentUser) async {
    try {
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));

      SubmitAnswerResponse submitAnswerResponse =
          await _bffRemoteRepository.submitAnswer(
              DynamicModuleCategory.profileCompletion.value,
              DynamicScreen.profileDetails.value,
              currentUser.userProfile?.userId,
              _awQuestionsCubit.getVisibleScreenRow(
                  dynamicModuleCategory:
                      DynamicModuleCategory.profileCompletion),
              null,
              null);
      changeButtonStatus(
          ButtonStatus(isSuccess: true, message: submitAnswerResponse.message));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(
          UIStatus(event: Event.updated, data: submitAnswerResponse));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    } catch (e, st) {
      AppLog.e('submitAnswer : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    }
  }

  Future<void> showDummySubmittingUI() async {
    changeButtonStatus(ButtonStatus(
        isSuccess: true, message: 'profile_attributed_updated'.tr));
    await Future.delayed(const Duration(milliseconds: 500));
    changeUIStatus(UIStatus(event: Event.updated));
  }
}
