import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/model/language.dart';

class UpdateLanguagesRequest {
  UpdateLanguagesRequest({
    required this.languages
  });

  late final List<Languages>? languages;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['languages'] = languages?.map((e) => e.toJson()).toList();
    return _data;
  }
}