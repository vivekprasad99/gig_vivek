import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/auth/data/repository/bff/bff_remote_repository.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_screen.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'profile_details_state.dart';

class ProfileDetailsCubit extends Cubit<ProfileDetailsState> {
  final BFFRemoteRepository _bffRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _questionAnswersResponse = BehaviorSubject<QuestionAnswersResponse>();
  Stream<QuestionAnswersResponse> get questionAnswersResponseStream =>
      _questionAnswersResponse.stream;
  Function(QuestionAnswersResponse) get changeQuestionAnswersResponse =>
      _questionAnswersResponse.sink.add;

  final _sectionDetailsList = BehaviorSubject<List<SectionDetails>>();
  Stream<List<SectionDetails>> get sectionDetailsListStream =>
      _sectionDetailsList.stream;
  Function(List<SectionDetails>) get changeSectionDetailsList =>
      _sectionDetailsList.sink.add;

  ProfileDetailsCubit(this._bffRemoteRepository)
      : super(ProfileDetailsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _questionAnswersResponse.close();
    _sectionDetailsList.close();
    return super.close();
  }

  void getQuestionAnswers(UserData currentUser) async {
    try {
      QuestionAnswersResponse questionAnswersResponse =
          await _bffRemoteRepository.getQuestionAnswers(
              currentUser.id,
              DynamicModuleCategory.profileCompletion,
              DynamicScreen.profileDetails.value,
              sectionBreakup: true);
      if (!_questionAnswersResponse.isClosed) {
        if (questionAnswersResponse.sectionDetailsList != null) {
          questionAnswersResponse.sectionDetailsList![0].isSelected = true;
          changeSectionDetailsList(questionAnswersResponse.sectionDetailsList!);
        }
        changeQuestionAnswersResponse(questionAnswersResponse);
      }
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

  void updateSectionDetailsList(index, SectionDetails sectionDetails) {
    if (!_sectionDetailsList.isClosed && _sectionDetailsList.hasValue) {
      List<SectionDetails> sectionDetailsList = _sectionDetailsList.value;
      List<SectionDetails> tempList = [];
      tempList.addAll(sectionDetailsList);
      for (int i = 0; i < sectionDetailsList.length; i++) {
        if (tempList[i].uid == sectionDetails.uid) {
          tempList[i].isSelected = true;
        } else {
          tempList[i].isSelected = false;
        }
      }
      tempList[index] = sectionDetails;
      changeSectionDetailsList(tempList);
    }
  }

  onUpdateRequiredAnswer(SectionDetailsQuestions sectionDetailsQuestions) {
    if (!_sectionDetailsList.isClosed && _sectionDetailsList.hasValue) {
      List<SectionDetails> sectionDetailsList = _sectionDetailsList.value;
      List<SectionDetails> tempList = [];
      tempList.addAll(sectionDetailsList);
      for (int i = 0; i < sectionDetailsList.length; i++) {
        if (tempList[i].title == sectionDetailsQuestions.title) {
          tempList[i].isRequired =
              sectionDetailsQuestions.isRequiredQuestionAvailable();
          break;
        }
      }
      changeSectionDetailsList(tempList);
    }
  }
}
