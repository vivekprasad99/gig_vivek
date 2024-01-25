import 'dart:io';

import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:awign/workforce/file_storage_remote/data/model/aws_upload_result.dart';
import 'package:awign/workforce/file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'signature_state.dart';

class SignatureCubit extends Cubit<SignatureState> {

  final _signatureStatus = BehaviorSubject<String?>();

  Stream<String?> get signatureStatusStream => _signatureStatus.stream;

  Function(String?) get changeSignatureStatus =>
      _signatureStatus.sink.add;

  int totalFileSize = 0;
  SignatureCubit() : super(SignatureInitial());

  Future upload(Question question,File file,Function(Question question) onAnswerUpdate) async {
    FileUtils.getFileSizeInBytes(file.path, 2).then((fileSize) {
      totalFileSize = fileSize;
    });
    String? updatedFileName, s3FolderPath;
    updatedFileName = file.name?.cleanForUrl();
    s3FolderPath = question.parentReference?.getUploadPath(file.name!);
    if (updatedFileName != null && s3FolderPath != null) {
      AWSUploadResult? awsUploadResult = await sl<RemoteStorageRepository>()
          .uploadFile(file, updatedFileName, s3FolderPath);
      question.answerUnit?.stringValue = awsUploadResult?.url;
      onAnswerUpdate(question);
      changeSignatureStatus(awsUploadResult?.url!);
      // changeImageSyncStatus(ImageSyncStatus(
      //     imageSyncState: ImageSyncState.uploaded, data: imageDetails));
    }
  }
}
