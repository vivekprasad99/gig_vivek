import 'package:awign/workforce/core/extension/string_extension.dart';

class ParentReference {
  String getUploadPath(String fileName) {
    String cleanedFileName = fileName.cleanForUrl();
    return 'default/$cleanedFileName';
  }
}
