import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/attachment.dart';

class ApplicationQuestionResponse {
  ApplicationQuestionResponse({
    required this.applicationQuestionLibraries,
    this.page,
    required this.limit,
    required this.total,
  });

  late List<ApplicationQuestionEntity>? applicationQuestionLibraries;
  late int? page;
  late int? limit;
  late int? total;

  ApplicationQuestionResponse.fromJson(Map<String, dynamic> json) {
    applicationQuestionLibraries =
        List.from(json['application_question_libraries'])
            .map((e) => ApplicationQuestionEntity.fromJson(e))
            .toList();
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['application_question_libraries'] =
        applicationQuestionLibraries?.map((e) => e.toJson()).toList();
    _data['page'] = page;
    _data['limit'] = limit;
    _data['total'] = total;
    return _data;
  }
}

class BaseQuestion {}

class ApplicationQuestionEntity extends BaseQuestion {
  ApplicationQuestionEntity({
    required this.id,
    required this.questionText,
    this.correctAnswer,
    this.attributeName,
  });

  late int? id;
  late dynamic correctAnswer;
  late int? workListingId;
  late String? attributeName;
  late String? questionText;
  late String? dataType;
  late InputTypeEntity? inputType;
  late List<String>? inputOptions;
  double? maxPitchDemoLength;
  late bool editable;
  late bool required;
  late dynamic answer;
  late bool isCorrect;
  late bool showTimer;
  late int? timeToAnswer;
  late String? imageMetadataType;
  late List<String>? overWriteMetadata;
  late List<String>? superImposeMetadata;
  late UploadFromOptionEntity? uploadFromOptionEntity;
  late bool blockAccess;
  late bool uploadLater;
  List<Attachment>? pitchTestMediaFiles;
  List<Attachment>? inAppInterviewSupportMedia;
  List<Attachment>? inAppTrainingSupportMedia;
  late String? questionType;
  late String? status;

  ApplicationQuestionEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    correctAnswer = json['correct_option'];
    workListingId = json['worklisting_id'];
    attributeName = json['attribute_name'];
    questionText = json['question_text'];
    dataType = json['input_structure'];
    inputType = InputTypeEntity.get(json['input_type']);
    try {
      inputOptions = json['input_options'] != null
          ? List.castFrom<dynamic, String>(json['input_options'])
          : null;
    } catch (e, st) {
      AppLog.e(
          'ApplicationQuestionEntity.fromJson : ${e.toString()} \n${st.toString()}');
    }
    maxPitchDemoLength = json['max_pitch_demo_length'];
    editable = json['editable'] ?? true;
    required = json['required'] ?? false;
    answer = json['answer'];
    isCorrect = json['is_correct'] ?? false;
    showTimer = json['show_timer'] ?? false;
    timeToAnswer = json['time_to_answer'];
    imageMetadataType = json['image_metadata_type'];
    overWriteMetadata = json['overwrite_metadata'] != null
        ? List.castFrom<dynamic, String>(json['overwrite_metadata'])
        : null;
    superImposeMetadata = json['superimpose_metadata'] != null
        ? List.castFrom<dynamic, String>(json['superimpose_metadata'])
        : null;
    switch (json['upload_from']) {
      case 'camera':
        uploadFromOptionEntity = UploadFromOptionEntity.camera;
        break;
      case 'gallery':
        uploadFromOptionEntity = UploadFromOptionEntity.gallery;
        break;
      case 'both':
        uploadFromOptionEntity = UploadFromOptionEntity.both;
        break;
      default:
        uploadFromOptionEntity = null;
    }
    blockAccess = json['block_access'] ?? false;
    uploadLater = json['upload_later'] ?? false;
    if (json['automated_pitch_demo_support_media'] != null) {
      pitchTestMediaFiles = <Attachment>[];
      json['automated_pitch_demo_support_media'].forEach((v) {
        pitchTestMediaFiles!.add(Attachment.fromJson(v));
      });
    }
    questionType = json['question_type'];
    status = json['status'];
    if (json['in_app_interview_support_media'] != null) {
      inAppInterviewSupportMedia = <Attachment>[];
      json['in_app_interview_support_media'].forEach((v) {
        inAppInterviewSupportMedia!
            .add(Attachment.fromJson(v));
      });
    }
    if (json['in_app_training_support_media'] != null) {
      inAppTrainingSupportMedia = <Attachment>[];
      json['in_app_training_support_media'].forEach((v) {
        inAppTrainingSupportMedia!
            .add(Attachment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['correct_option'] = correctAnswer;
    _data['worklisting_id'] = workListingId;
    _data['attribute_name'] = attributeName;
    _data['question_text'] = questionText;
    _data['input_structure'] = dataType;
    // _data['input_type'] = InputTypeEntity.getStringValue(inputType);
    _data['input_options'] = inputOptions;
    _data['max_pitch_demo_length'] = maxPitchDemoLength;
    _data['required'] = required;
    _data['editable'] = editable;
    _data['answer'] = answer;
    _data['is_correct'] = isCorrect;
    _data['show_timer'] = showTimer;
    _data['time_to_answer'] = timeToAnswer;
    _data['image_metadata_type'] = imageMetadataType;
    _data['overwrite_metadata'] = overWriteMetadata;
    _data['superimpose_metadata'] = superImposeMetadata;
    switch (uploadFromOptionEntity) {
      case UploadFromOptionEntity.camera:
        _data['upload_from'] = 'camera';
        break;
      case UploadFromOptionEntity.gallery:
        _data['upload_from'] = 'gallery';
        break;
      case UploadFromOptionEntity.both:
        _data['upload_from'] = 'both';
        break;
      default:
        _data['upload_from'] = null;
    }
    _data['block_access'] = blockAccess;
    _data['upload_later'] = uploadLater;
    _data['question_type'] = questionType;
    _data['status'] = status;
    return _data;
  }
}

class ApplicationAnswerEntity {
  ApplicationAnswerEntity(this.applicationQuestionId, this.answer);

  late String? applicationQuestionId;
  late dynamic answer;

  ApplicationAnswerEntity.fromJson(Map<String, dynamic> json) {
    applicationQuestionId = json['application_question_id'];
    answer = json['answer'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['application_question_id'] = applicationQuestionId;
    _data['answer'] = answer;
    return _data;
  }
}

class InputTypeEntity<String> extends Enum1<String> {
  const InputTypeEntity(String val) : super(val);

  static const InputTypeEntity shortText = InputTypeEntity('short_text');
  static const InputTypeEntity longText = InputTypeEntity('long_text');
  static const InputTypeEntity integer = InputTypeEntity('integer');
  static const InputTypeEntity email = InputTypeEntity('email');
  static const InputTypeEntity float = InputTypeEntity('float');
  static const InputTypeEntity url = InputTypeEntity('url');
  static const InputTypeEntity radioButton =
      InputTypeEntity('single_select_radio');
  static const InputTypeEntity singleSelectDropdown =
      InputTypeEntity('single_select_dropdown');
  static const InputTypeEntity singleSelectDecisionButton =
      InputTypeEntity('single_select_decision_button');
  static const InputTypeEntity singleSelect = InputTypeEntity('single-select');
  static const InputTypeEntity multipleSelect = InputTypeEntity('multi-select');
  static const InputTypeEntity multiSelectCheckbox =
      InputTypeEntity('multi_select_checkbox');
  static const InputTypeEntity multiSelectDropdown =
      InputTypeEntity('multi_select_dropdown');
  static const InputTypeEntity date = InputTypeEntity('date');
  static const InputTypeEntity time = InputTypeEntity('time');
  static const InputTypeEntity signature = InputTypeEntity('signature');
  static const InputTypeEntity dateTime = InputTypeEntity('date_time');
  static const InputTypeEntity timeRange = InputTypeEntity('time_range');
  static const InputTypeEntity dateRange = InputTypeEntity('date_range');
  static const InputTypeEntity datetimeRange =
      InputTypeEntity('datetime_range');
  static const InputTypeEntity audioRecording =
      InputTypeEntity('audio_recording');
  static const InputTypeEntity singleSelectImage =
      InputTypeEntity('single_select_image');
  static const InputTypeEntity multiSelectImage =
      InputTypeEntity('multi_select_image');
  static const InputTypeEntity image = InputTypeEntity('image');
  static const InputTypeEntity audio = InputTypeEntity('audio');
  static const InputTypeEntity video = InputTypeEntity('video');
  static const InputTypeEntity pdf = InputTypeEntity('pdf');
  static const InputTypeEntity file = InputTypeEntity('file');
  static const InputTypeEntity nested = InputTypeEntity('nested');
  static const InputTypeEntity geoAddress = InputTypeEntity('geo_address');
  static const InputTypeEntity currentLocation =
      InputTypeEntity('current_location');
  static const InputTypeEntity phone = InputTypeEntity('phone');
  static const InputTypeEntity pinCode = InputTypeEntity('pincode');
  static const InputTypeEntity codeScanner = InputTypeEntity('code_scanner');

  static InputTypeEntity? get(dynamic inputType) {
    switch (inputType) {
      case 'code_scanner':
        return InputTypeEntity.codeScanner;
      case 'short_text':
        return InputTypeEntity.shortText;
      case 'long_text':
        return InputTypeEntity.longText;
      case 'integer':
        return InputTypeEntity.integer;
      case 'email':
        return InputTypeEntity.email;
      case 'float':
        return InputTypeEntity.float;
      case 'url':
        return InputTypeEntity.url;
      case 'single_select_radio':
        return InputTypeEntity.radioButton;
      case 'single_select_dropdown':
        return InputTypeEntity.singleSelectDropdown;
      case 'single_select_decision_button':
        return InputTypeEntity.singleSelectDecisionButton;
      case 'single-select':
        return InputTypeEntity.singleSelect;
      case 'multi-select':
        return InputTypeEntity.multipleSelect;
      case 'multi_select_checkbox':
        return InputTypeEntity.multiSelectCheckbox;
      case 'multi_select_dropdown':
        return InputTypeEntity.multiSelectDropdown;
      case 'date':
        return InputTypeEntity.date;
      case 'time':
        return InputTypeEntity.time;
      case 'signature':
        return InputTypeEntity.signature;
      case 'date_time':
        return InputTypeEntity.dateTime;
      case 'time_range':
        return InputTypeEntity.timeRange;
      case 'date_range':
        return InputTypeEntity.dateRange;
      case 'datetime_range':
        return InputTypeEntity.datetimeRange;
      case 'audio_recording':
        return InputTypeEntity.audioRecording;
      case 'single_select_image':
        return InputTypeEntity.singleSelectImage;
      case 'multi_select_image':
        return InputTypeEntity.multiSelectImage;
      case 'image':
        return InputTypeEntity.image;
      case 'audio':
        return InputTypeEntity.audio;
      case 'video':
        return InputTypeEntity.video;
      case 'pdf':
        return InputTypeEntity.pdf;
      case 'file':
        return InputTypeEntity.file;
      case 'nested':
        return InputTypeEntity.nested;
      case 'geo_address':
        return InputTypeEntity.geoAddress;
      case 'current_location':
        return InputTypeEntity.currentLocation;
      case 'phone':
        return InputTypeEntity.phone;
      case 'pincode':
        return InputTypeEntity.pinCode;
      default:
        return null;
    }
  }
}

class UploadFromOptionEntity<String> extends Enum1<String> {
  const UploadFromOptionEntity(String val) : super(val);

  static const UploadFromOptionEntity camera = UploadFromOptionEntity('camera');
  static const UploadFromOptionEntity gallery =
      UploadFromOptionEntity('gallery');
  static const UploadFromOptionEntity both = UploadFromOptionEntity('both');

  static UploadFromOptionEntity? get(dynamic value) {
    switch (value) {
      case 'camera':
        return UploadFromOptionEntity.camera;
      case 'gallery':
        return UploadFromOptionEntity.gallery;
      case 'both':
        return UploadFromOptionEntity.both;
      default:
        null;
    }
    return null;
  }
}
