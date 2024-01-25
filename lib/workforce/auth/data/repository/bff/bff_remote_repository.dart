import 'package:awign/workforce/auth/data/model/dream_application_completion_stage.dart';
import 'package:awign/workforce/auth/data/model/get_question_answers_request.dart';
import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/auth/data/model/onboarding_completion_stage.dart';
import 'package:awign/workforce/auth/data/model/submit_answer_request.dart';
import 'package:awign/workforce/auth/data/network/data_source/bff/bff_remote_data_source.dart';
import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';

abstract class BFFRemoteRepository {
  Future<QuestionAnswersResponse> getQuestionAnswers(
      int? userID, DynamicModuleCategory categoryUID, String screenUID,
      {bool sectionBreakup = false});

  Future<SubmitAnswerResponse> submitAnswer(
      String categoryUID,
      String screenUID,
      int? userID,
      List<ScreenRow> questionList,
      OnboardingCompletionStage? onboardingCompletionStage,
      DreamApplicationCompletionStage? dreamApplicationCompletionStage,
      {String? mobileNumber,
      String? email});
}

class BFFRemoteRepositoryImpl implements BFFRemoteRepository {
  final BFFRemoteDataSource _dataSource;

  BFFRemoteRepositoryImpl(this._dataSource);

  @override
  Future<QuestionAnswersResponse> getQuestionAnswers(
      int? userID, DynamicModuleCategory categoryUID, String screenUID,
      {bool sectionBreakup = false}) async {
    try {
      GetQuestionAnswerRequest getQuestionAnswerRequest =
          GetQuestionAnswerRequest(
              categoryUID: categoryUID.value,
              screenUID: screenUID,
              sectionBreakup: sectionBreakup);
      final apiResponse = await _dataSource.getQuestionAnswers(
          userID, getQuestionAnswerRequest);
      return apiResponse;
    } catch (e, stacktrace) {
      AppLog.e(
          'getQuestionAnswers : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<SubmitAnswerResponse> submitAnswer(
      String categoryUID,
      String screenUID,
      int? userID,
      List<ScreenRow> screenRowList,
      OnboardingCompletionStage? onboardingCompletionStage,
      DreamApplicationCompletionStage? dreamApplicationCompletionStage,
      {String? mobileNumber,
      String? email}) async {
    try {
      List<ProfileAttributeData> answerEntities = [];
      for (ScreenRow screenRow in screenRowList) {
        dynamic answerValue = AnswerUnitMapper.transformAnswerUnitNew(
            screenRow.question?.answerUnit,
            uid: screenRow.question?.uid);
        if (answerValue != null) {
          answerEntities.add(ProfileAttributeData(
            attributeName: screenRow.question?.attributeName ?? '',
            attributeUid: screenRow.question?.attributeUid ?? '',
            attributeType: screenRow.question?.questionSubCategory ?? '',
            attributeValue: answerValue,
          ));
        }
      }
      if (onboardingCompletionStage ==
          OnboardingCompletionStage.personalDetails) {
        ProfileAttributeData mobileNumberAttributeData = ProfileAttributeData(
          attributeName: 'Mobile Number',
          attributeUid: UID.mobileNumber.value,
          attributeType: Constants.profileData,
          attributeValue: mobileNumber,
        );
        answerEntities.add(mobileNumberAttributeData);
        ProfileAttributeData emailAttributeData = ProfileAttributeData(
          attributeName: 'Email',
          attributeUid: UID.email.value,
          attributeType: Constants.profileData,
          attributeValue: email,
        );
        answerEntities.add(emailAttributeData);
      }
      SubmitAnswerRequest submitAnswerRequest = SubmitAnswerRequest(
          profileAttributes: answerEntities,
          onboardingCompletionStage: onboardingCompletionStage,
          dreamApplicationCompletionStage: dreamApplicationCompletionStage);
      final apiResponse = await _dataSource.submitAnswer(
          categoryUID, screenUID, userID, submitAnswerRequest);
      if (apiResponse.status == ApiResponse.success) {
        return SubmitAnswerResponse.fromJson(
            apiResponse.data, apiResponse.message);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, stacktrace) {
      AppLog.e('submitAnswer : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }
}
