import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';

class TextConfiguration extends Configuration {
  TextConfiguration(
      {this.subType = SubType.short,
      this.minCharacters = 0,
      this.maxCharacters})
      : super(configurationType: ConfigurationType.text);

  late SubType? subType;
  late int? minCharacters;
  late int? maxCharacters;
}
