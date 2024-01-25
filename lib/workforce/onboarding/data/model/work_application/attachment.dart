import 'package:awign/workforce/core/data/model/enum.dart';

class Attachment {
  int? id;
  String? title;
  FileType? fileType;
  String? filePath;

  Attachment({this.id, this.title, this.fileType, this.filePath});

  Attachment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    fileType = FileType.get(json['file_type']);
    filePath = json['file_path'];
  }
}

class FileType<String> extends Enum1<String> {
  const FileType(String val) : super(val);

  static const FileType pdf = FileType('pdf');
  static const FileType image = FileType('image');
  static const FileType video = FileType('video');
  static const FileType audio = FileType('audio');
  static const FileType youtube = FileType('youtube');
  static const FileType googleDrive = FileType('google_drive');
  static const FileType file = FileType('file');
  static const FileType png = FileType('png');
  static const FileType jpeg = FileType('jpeg');
  static const FileType jpg = FileType('jpg');
  static const FileType svg = FileType('svg');
  static const FileType mp3 = FileType('mp3');
  static const FileType mp4 = FileType('mp4');
  static const FileType ogg = FileType('ogg');
  static const FileType webm = FileType('webm');

  static FileType? get(dynamic status) {
    switch (status) {
      case 'pdf':
        return FileType.pdf;
      case 'image':
        return FileType.image;
      case 'video':
        return FileType.video;
      case 'audio':
        return FileType.audio;
      case 'youtube':
        return FileType.youtube;
      case 'google_drive':
        return FileType.googleDrive;
      case 'file':
        return FileType.file;
      case 'png':
        return FileType.png;
      case 'jpeg':
        return FileType.jpeg;
      case 'jpg':
        return FileType.jpg;
      case 'svg':
        return FileType.svg;
      case 'mp3':
        return FileType.mp3;
      case 'mp4':
        return FileType.mp4;
      case 'ogg':
        return FileType.ogg;
      case 'webm':
        return FileType.webm;
    }
    return null;
  }
}
