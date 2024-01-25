import 'package:awign/workforce/core/data/model/user_data.dart';

class EducationDetailResponse {
  EducationDetailResponse({
    this.education,
    this.limit,
    this.page,
    this.offset,
    this.total,
  });
  late List<Education>? education;
  late int? limit;
  late int? page;
  late int? offset;
  late int? total;

  EducationDetailResponse.fromJson(Map<String, dynamic> json){
    education = json['education'] != null ? List.from(json['education']).map((e)=>Education.fromJson(e)).toList() : null;
    limit = json['limit'];
    page = json['page'];
    offset = json['offset'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['education'] = education?.map((e)=>e.toJson()).toList();
    _data['limit'] = limit;
    _data['page'] = page;
    _data['offset'] = offset;
    _data['total'] = total;
    return _data;
  }
}