import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/auth/data/model/onboarding_completion_stage.dart';
import 'package:awign/workforce/auth/data/model/submit_answer_request.dart';
import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/auth/data/repository/bff/bff_remote_repository.dart';
import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/cubit/select_language_cubit.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'personal_details_state.dart';

class PersonalDetailsCubit extends Cubit<PersonalDetailsState> with Validator {
  final AuthRemoteRepository _authRemoteRepository;
  final BFFRemoteRepository _bffRemoteRepository;
  final _selectLanguageCubit = sl<SelectLanguageCubit>();
  final _awQuestionsCubit = sl<AwQuestionsCubit>();

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _questionAnswersResponse = BehaviorSubject<QuestionAnswersResponse>();

  Stream<QuestionAnswersResponse> get questionAnswersResponseStream =>
      _questionAnswersResponse.stream;

  Function(QuestionAnswersResponse) get changeQuestionAnswersResponse =>
      _questionAnswersResponse.sink.add;

  final _isWhatsappSubscribed = BehaviorSubject<bool>.seeded(true);

  Stream<bool> get isWhatsappSubscribed => _isWhatsappSubscribed.stream;

  bool get isWhatsappSubscribedValue => _isWhatsappSubscribed.value;

  Function(bool) get changeIsWhatsappSubscribed =>
      _isWhatsappSubscribed.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  PersonalDetailsCubit(this._authRemoteRepository, this._bffRemoteRepository)
      : super(PersonalDetailsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _questionAnswersResponse.close();
    _isWhatsappSubscribed.close();
    buttonStatus.close();
    return super.close();
  }

  void getQuestionAnswers(UserData currentUser) async {
    try {
      QuestionAnswersResponse questionAnswersResponse =
          await _bffRemoteRepository.getQuestionAnswers(
              currentUser.id,
              DynamicModuleCategory.onboarding,
              currentUser.userProfile?.onboardingCompletionStage?.value);
      if (!_questionAnswersResponse.isClosed) {
        changeQuestionAnswersResponse(questionAnswersResponse);
      }
      _awQuestionsCubit.checkVisibilityAndUpdateQuestionList(
          questionAnswersResponse.getScreenQuestions(
              questionAnswersResponse.questions,
              DynamicModuleCategory.onboarding,
              null));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getQuestionAnswers : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void submitAnswer(UserData currentUser) async {
    try {
      if (_awQuestionsCubit.screenRowListValue != null) {
        changeButtonStatus(
            ButtonStatus(isLoading: true, message: 'please_wait'.tr));
        SubmitAnswerResponse submitAnswerResponse =
        await _bffRemoteRepository.submitAnswer(
            _questionAnswersResponse.value.categoryDetails?.uid?.value ?? '',
            _questionAnswersResponse.value.screenDetails?.uid?.value ?? '',
            currentUser.userProfile?.userId,
            _awQuestionsCubit.screenRowListValue!,
            OnboardingCompletionStage.personalDetails,
            null,
            mobileNumber: currentUser.mobileNumber,
            email: currentUser.email);
        SPUtil? spUtil = await SPUtil.getInstance();
        UserData? curUser = spUtil?.getUserData();
        for (int i = 0;
        i < (submitAnswerResponse.profileAttribute?.length ?? 0);
        i++) {
          if (submitAnswerResponse.profileAttribute![i].attributeUid ==
              UID.name.value) {
            curUser?.name =
                submitAnswerResponse.profileAttribute![i].attributeValue;
            curUser?.userProfile?.name =
                submitAnswerResponse.profileAttribute![i].attributeValue;
            break;
          }
        }
        curUser?.userProfile?.onboardingCompletionStage =
            submitAnswerResponse.onboardingCompletionStage;
        spUtil?.putUserData(curUser);
        changeButtonStatus(
            ButtonStatus(
                isSuccess: true, message: submitAnswerResponse.message));
        await Future.delayed(const Duration(milliseconds: 500));
        changeUIStatus(UIStatus(event: Event.updated));
      }
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

  void subscribeWhatsapp(UserData userData) async {
    try {
      ApiResponse apiResponse =
          await _authRemoteRepository.subscribeWhatsapp(userData.id);
    } catch (e, st) {
      AppLog.e('subscribeWhatsapp : ${e.toString()} \n${st.toString()}');
    }
  }

  void unSubscribeWhatsapp(UserData userData) async {
    try {
      ApiResponse apiResponse =
          await _authRemoteRepository.unSubscribeWhatsapp(userData.id);
    } catch (e, st) {
      AppLog.e('unSubscribeWhatsapp : ${e.toString()} \n${st.toString()}');
    }
  }
}
