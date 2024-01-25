import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/data/model/option.dart';

class SelectConfiguration extends Configuration {
  SelectConfiguration({
    this.type = ConfigurationType.singleSelect,
    this.options,
    this.correctOptions,
    this.optionEntities,
  }) : super(configurationType: type);

  late ConfigurationType type;
  late List<String>? options;
  late List<String>? correctOptions;
  late List<Option>? optionEntities;
}
