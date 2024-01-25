class GetQuestionAnswerRequest {
  GetQuestionAnswerRequest(
      {required this.categoryUID, required this.screenUID, this.sectionBreakup = false});

  String categoryUID;
  String screenUID;
  bool sectionBreakup;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['category_uid'] = categoryUID;
    _data['screen_uid'] = screenUID;
    _data['section_breakup'] = sectionBreakup;
    return _data;
  }
}
