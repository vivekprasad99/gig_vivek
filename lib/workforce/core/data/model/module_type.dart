import 'package:awign/workforce/core/data/model/enum.dart';

class ModuleType<String> extends Enum1<String> {
  const ModuleType(String val) : super(val);

  static const ModuleType category = ModuleType('category');
  static const ModuleType application = ModuleType('application');
  static const ModuleType execution = ModuleType('execution');
  static const ModuleType profileCompletion = ModuleType('profileCompletion');
  static const ModuleType eligiblityCriteria = ModuleType('eligiblityCriteria');
  static const ModuleType attendance = ModuleType('attendance');
}
