import 'package:awign/workforce/core/data/model/enum.dart';

class MediaFile {
  MediaFile({
    this.id,
    this.title,
    this.fileType,
    this.filePath,
  });
  late int? id;
  late String? title;
  late MediaFileRenderType? fileType;
  late String? filePath;

  MediaFile.fromJson(Map<String, dynamic> json){
    id = json['id'];
    title = json['title'];
    // fileType = json['file_type'];
    filePath = json['file_path'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['title'] = title;
    _data['file_type'] = fileType;
    _data['file_path'] = filePath;
    return _data;
  }
}

class MediaFileRenderType<String> extends Enum1<String> {
  const MediaFileRenderType(String val) : super(val);

  static const MediaFileRenderType image = MediaFileRenderType('image');
  static const MediaFileRenderType audio = MediaFileRenderType('audio');
  static const MediaFileRenderType video = MediaFileRenderType('video');
  static const MediaFileRenderType file = MediaFileRenderType('file');
}