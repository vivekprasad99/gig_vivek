import 'package:awign/workforce/onboarding/data/model/work_application/attachment.dart';

class AttachmentsResponse {
  List<AttachmentSectionEntity>? attachmentSections;

  AttachmentsResponse({this.attachmentSections});

  factory AttachmentsResponse.fromJson(Map<String, dynamic> json) {
    return AttachmentsResponse(
      attachmentSections: (json['resources'] as List<dynamic>?)
          ?.map((section) => AttachmentSectionEntity.fromJson(section))
          .toList(),
    );
  }
}

class AttachmentSectionEntity {
  String? stepName;
  List<Attachment>? attachments;

  AttachmentSectionEntity({this.stepName, this.attachments});

  factory AttachmentSectionEntity.fromJson(Map<String, dynamic> json) {
    return AttachmentSectionEntity(
      stepName: json['step_name'] as String?,
      attachments: (json['material'] as List<dynamic>?)
          ?.map((attachment) => Attachment.fromJson(attachment))
          .toList(),
    );
  }
}
