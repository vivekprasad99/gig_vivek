import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/data/model/media_file.dart';
import 'package:awign/workforce/core/data/model/enum.dart';

import '../../../../onboarding/data/model/work_application/attachment.dart';

class Configuration {
  Configuration({
    this.action,
    this.configurationType = ConfigurationType.text,
    this.questionIndex = 1,
    this.attributeName,
    this.questionText = '',
    this.hintText,
    this.columnTitle,
    this.uid,
    this.isEditable = true,
    this.isRequired = false,
    this.hintStringRes = 0,
    this.drawableLeft = 0,
    this.timeToAnswer = 0,
    this.uploadLater = false,
    this.mediaFiles,
    this.isLocationTrackable = false,
    this.isTimeTrackable = false,
    this.uploadFrom = UploadFromOption.camera,
    // this.id = Random(DateTime.now().millisecond).nextInt(9999),
    this.id = 0,
    this.isAsync = false,
    this.showErrMsg = false,
    this.isProfileQuestion = false,
    this.imageMetaData,
    this.characterFormat,
    this.characterLimit,
    // this.isCaptureMultipleImage = false,
    this.errMsg
  });

  late String? action;
  late ConfigurationType? configurationType;
  late int? questionIndex;
  late String? attributeName;
  late String? questionText;
  late String? questionNameText;
  late String? hintText;
  late String? columnTitle;
  late String? uid;
  late bool isEditable;
  late bool isRequired;
  late int? hintStringRes;
  late int? drawableLeft;
  late int? timeToAnswer;
  late bool showTimer;
  late bool uploadLater;
  late List<MediaFile>? mediaFiles;
  late bool isLocationTrackable;
  late bool isTimeTrackable;
  late UploadFromOption? uploadFrom;
  late int id;
  late bool isAsync;
  late bool showErrMsg;
  late String? errMsg;
  late bool isProfileQuestion;
  late String? imageMetaData;
  // late bool isCaptureMultipleImage;
  List<Attachment>? questionResources;
  late String? characterFormat;
  late int? characterLimit;

  Configuration.from(Configuration? configuration) {
    action = configuration?.action;
    configurationType = configuration?.configurationType;
    questionIndex = configuration?.questionIndex;
    attributeName = configuration?.attributeName;
    questionText = configuration?.questionText;
    questionNameText = configuration?.questionNameText;
    hintText = configuration?.hintText;
    columnTitle = configuration?.columnTitle;
    uid = configuration?.uid;
    isEditable = configuration?.isEditable ?? true;
    isRequired = configuration?.isRequired ?? true;
    hintStringRes = configuration?.hintStringRes;
    drawableLeft = configuration?.drawableLeft;
    timeToAnswer = configuration?.timeToAnswer;
    uploadLater = configuration?.uploadLater ?? false;
    mediaFiles = configuration?.mediaFiles;
    isLocationTrackable = configuration?.isLocationTrackable ?? false;
    isTimeTrackable = configuration?.isTimeTrackable ?? false;
    uploadFrom = configuration?.uploadFrom;
    id = configuration?.id ?? 0;
    isAsync = configuration?.isAsync ?? false;
    showErrMsg = configuration?.showErrMsg ?? false;
    // isCaptureMultipleImage = configuration?.isCaptureMultipleImage ?? false;
    imageMetaData = configuration?.imageMetaData;
    questionResources = configuration?.questionResources;
    characterFormat = configuration?.characterFormat;
  }
}

class UploadFromOption<String> extends Enum1<String> {
  const UploadFromOption(String val) : super(val);

  static const UploadFromOption camera = UploadFromOption('camera');
  static const UploadFromOption gallery = UploadFromOption('gallery');
  static const UploadFromOption cameraAndGallery =
      UploadFromOption('cameraAndGallery');
}
