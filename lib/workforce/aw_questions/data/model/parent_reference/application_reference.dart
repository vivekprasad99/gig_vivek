import 'package:awign/workforce/aw_questions/data/model/parent_reference/parent_reference.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';

class ApplicationReference extends ParentReference {
  late int? applicationID;
  late String? questionID;
  late int? listingID;

  ApplicationReference(this.applicationID, this.questionID, this.listingID);

  @override
  String getUploadPath(String fileName) {
    String cleanedFileName = fileName.cleanForUrl();
    if(applicationID != null) {
      return 'listing/$listingID/application/$applicationID/pitch_demo/$cleanedFileName';
    } else {
      return 'listing/$listingID/question/$questionID/$cleanedFileName';
    }
  }
}
