import '../../../onboarding/data/model/application_question/application_question_response.dart';

class InEligibleQuestionAnswerEntity {
  List<ApplicationQuestionEntity>? applicationQuestions;
  int? page;
  int? limit;
  int? offset;
  int? total;

  InEligibleQuestionAnswerEntity(
      {this.applicationQuestions,
        this.page,
        this.limit,
        this.offset,
        this.total});

  InEligibleQuestionAnswerEntity.fromJson(Map<String, dynamic> json) {
    if (json['application_questions'] != null) {
      applicationQuestions = <ApplicationQuestionEntity>[];
      json['application_questions'].forEach((v) {
        applicationQuestions!.add(ApplicationQuestionEntity.fromJson(v));
      });
    }
    page = json['page'];
    limit = json['limit'];
    offset = json['offset'];
    total = json['total'];
  }
}
