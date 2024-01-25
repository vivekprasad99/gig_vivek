class EligiblityEntityResponse {
  List<ApplicationAnswers>? applicationAnswers;

  EligiblityEntityResponse({this.applicationAnswers});

  EligiblityEntityResponse.fromJson(Map<String, dynamic> json) {
    if (json['application_answers'] != null) {
      applicationAnswers = <ApplicationAnswers>[];
      json['application_answers'].forEach((v) { applicationAnswers!.add(ApplicationAnswers.fromJson(v)); });
    }
  }
}

class ApplicationAnswers {
  int? applicationQuestionId;
  dynamic answer;
  Map<String,dynamic>? ineligibleWorklistings;

  ApplicationAnswers({this.applicationQuestionId, this.answer, this.ineligibleWorklistings,});

  ApplicationAnswers.fromJson(Map<String, dynamic> json) {

    applicationQuestionId = json['application_question_id'];
    answer = json['answer'];
    ineligibleWorklistings = json['ineligible_worklistings'];
  }
}

class EligiblityMessage {
  String? message;

  EligiblityMessage({this.message});

  EligiblityMessage.fromJson(Map<String, dynamic> json) {
    message = json['message'];
  }
}

class EligiblityData
{
  List<ApplicationAnswers>? applicationAnswers;
  int? categoryId;
  EligiblityData({this.applicationAnswers,this.categoryId});
}

class InEligibleQuestionIdAnswers {
  int? applicationQuestionId;
  dynamic answer;
  InEligibleQuestionIdAnswers({this.applicationQuestionId, this.answer,});
}