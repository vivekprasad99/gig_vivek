import 'package:awign/workforce/aw_questions/data/model/parent_reference/parent_reference.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';

class CategoryReference extends ParentReference {
  late String categoryID;
  late int? userID;

  CategoryReference(this.categoryID, this.userID);

  @override
  String getUploadPath(String fileName) {
    String cleanedFileName = fileName.cleanForUrl();
    // category/categoryID/User/UserID/fileName
    return 'category/$categoryID/User/$userID/$cleanedFileName';
  }
}
