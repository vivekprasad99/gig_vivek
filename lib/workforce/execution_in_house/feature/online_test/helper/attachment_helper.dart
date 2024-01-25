
import '../../../../aw_questions/data/model/screen/attachment_response.dart';
import '../../../../onboarding/data/model/work_application/attachment.dart';
import '../../../../onboarding/data/model/work_application/work_application_section.dart';

class AttachmentMapper {
  static List<AttachmentSection> transformAttachmentsResponse(
      List<AttachmentSectionEntity>? attachmentSectionEntities) {
    attachmentSectionEntities ??= [];

    List<AttachmentSection> attachmentSections = [];
    for (AttachmentSectionEntity attachmentSectionEntity
        in attachmentSectionEntities) {
      AttachmentSection attachmentSection =
          transformAttachmentSection(attachmentSectionEntity);
      attachmentSections.add(attachmentSection);
    }

    if (attachmentSections.isEmpty) {
      AttachmentSection attachmentSection =
          AttachmentSection(title: null, description: null, attachments: []);
      attachmentSections.add(attachmentSection);
    }

    return attachmentSections;
  }

  static AttachmentSection transformAttachmentSection(
      AttachmentSectionEntity attachmentSectionEntity) {
    List<Attachment> attachments = [];
    if (attachmentSectionEntity.attachments != null) {
      for (Attachment attachmentEntity
          in attachmentSectionEntity.attachments!) {
        Attachment? attachment = transformAttachment(attachmentEntity);
        if (attachment != null) {
          attachments.add(attachment);
        }
      }
    }
    return AttachmentSection(
        title: attachmentSectionEntity.stepName,
        description: null,
        attachments: attachments);
  }

  static Attachment? transformAttachment(Attachment? attachmentEntity) {
    if (attachmentEntity?.filePath == null) {
      return null;
    }
    return Attachment(
        title: attachmentEntity?.title,
        fileType: attachmentEntity?.fileType,
        filePath: attachmentEntity?.filePath);
  }
}
