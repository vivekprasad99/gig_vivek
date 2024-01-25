import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerHelper {
  static pickMedia(SubType? subType, DataType? dataType,
      Function(FilePickerResult) onMediaPicked, {bool isSelectMultiple = false}) async {
    switch (subType) {
      case SubType.image:
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: isSelectMultiple
        );

        if (result != null) {
          onMediaPicked(result);
        }
        break;
      case SubType.audio:
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: [
            'wav',
            'aiff',
            'alac',
            'flac',
            'mp3',
            'aac',
            'wma',
            'ogg'
          ],
        );

        if (result != null) {
          onMediaPicked(result);
        }
        break;
      case SubType.video:
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.video,
        );

        if (result != null) {
          onMediaPicked(result);
        }
        break;
      case SubType.pdf:
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

        if (result != null) {
          onMediaPicked(result);
        }
        break;
      case SubType.file:
        FilePickerResult? result = await FilePicker.platform.pickFiles();

        if (result != null) {
          onMediaPicked(result);
        }
        break;
    }
  }

  static Future<List<XFile>> pickMultipleImage() async {
    final List<XFile> xFileList = await ImagePicker().pickMultiImage();
    return xFileList;
  }
}
