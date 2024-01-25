import 'package:awign/workforce/aw_questions/data/model/parent_reference/parent_reference.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';

class LeadReference extends ParentReference {
  late String? leadID;
  late String? projectID;
  late String? screenUID;

  LeadReference(this.projectID);

  @override
  String getUploadPath(String fileName) {
    String cleanedFileName = fileName.cleanForUrl();
    if (projectID != null) {
      // return 'project/$projectID/lead/$leadID/$cleanedFileName';
      return 'project/$projectID/lead/$leadID';
    } else {
      // return 'lead/$leadID/$cleanedFileName';
      return 'lead/$leadID';
    }
  }
}
