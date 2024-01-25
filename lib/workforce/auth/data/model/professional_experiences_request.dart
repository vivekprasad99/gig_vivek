import 'package:awign/workforce/core/data/model/user_data.dart';

class ProfessionalExperienceRequest {
  ProfessionalExperienceRequest({
    required this.professionalExperiences,
  });

  late List<ProfessionalExperiences>? professionalExperiences;

  ProfessionalExperienceRequest.fromJson(Map<String, dynamic> json) {
    professionalExperiences = json['professional_experiences'] != null
        ? List.from(json['professional_experiences'])
        .map((e) => ProfessionalExperiences.fromJson(e))
        .toList()
        : null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['professional_experiences'] =
        professionalExperiences?.map((e) => e.toJson()).toList();
    return _data;
  }
}