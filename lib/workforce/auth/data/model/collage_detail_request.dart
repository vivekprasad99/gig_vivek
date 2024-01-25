import 'package:awign/workforce/core/data/model/user_data.dart';

class EducationDetailRequest {
  EducationDetailRequest({required this.education});

  late final Education? education;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['education'] = education?.toJson();
    return _data;
  }
}
