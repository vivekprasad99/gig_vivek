import 'dart:io';

extension FileExtention on FileSystemEntity {
  String? get name {
    return this.path.split("/").last;
  }
}

extension IsNullOrEmpty on List? {
  bool get isNullOrEmpty {
    return this == null || this!.isEmpty;
  }
}