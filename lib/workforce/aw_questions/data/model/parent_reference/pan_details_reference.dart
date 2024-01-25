import 'package:awign/workforce/aw_questions/data/model/parent_reference/parent_reference.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';

class PANDetailsReference extends ParentReference {
  late int? userID;

  PANDetailsReference(this.userID);

  @override
  String getUploadPath(String fileName) {
    String cleanedFileName = fileName.cleanForUrl();
    return 'user/$userID/$cleanedFileName';
  }
}
