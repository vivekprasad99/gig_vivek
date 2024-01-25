class AttendanceAnswerEntity {
  String? uid;
  dynamic answer;
  String? renderType;
  String? attributeType;
  String? columnTitle;

  AttendanceAnswerEntity(
      {this.uid, this.answer, this.renderType, this.attributeType,this.columnTitle});

  AttendanceAnswerEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    answer = json['answer'];
    renderType = json['render_type'];
    attributeType = json['attribute_type'];
    columnTitle = json['column_title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['answer'] = answer;
    data['render_type'] = renderType;
    data['attribute_type'] = attributeType;
    data['column_title'] = columnTitle;
    return data;
  }
}
