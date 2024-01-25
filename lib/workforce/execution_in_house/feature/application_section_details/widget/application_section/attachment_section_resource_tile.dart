import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/attachment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/utils/browser_helper.dart';

class AttachmentSectionResourceTile extends StatelessWidget {
  final Attachment attachment;
  const AttachmentSectionResourceTile({required this.attachment, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildAttachmentSectionResourceTile(context);
  }

  Widget buildAttachmentSectionResourceTile(BuildContext context) {
    return ListTile(
      onTap: () {
        if(attachment.filePath != null) {
          BrowserHelper.customTab(context, attachment.filePath!);
        }
      },
      leading: Container(
        padding: const EdgeInsets.all(Dimens.padding_8),
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey400,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: SvgPicture.asset(
          getImageByFileType(attachment.fileType),
          height: Dimens.iconSize_40,
          width: Dimens.iconSize_40,
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.fromLTRB(0.0,0.0,0.0,8.0),
        child: Text(attachment.title ?? ''),
      ),
      subtitle:Text(
        renderFileType(attachment.fileType),
        style: const TextStyle(color: AppColors.primaryMain),
      ),
    );
  }

  String renderFileType(FileType? fileType) {
    if (fileType == FileType.pdf) {
      return 'View Pdf';
    } else if (fileType == FileType.video) {
      return 'Play Video';
    } else if (fileType == FileType.audio) {
      return 'Play Audio';
    } else if( fileType == FileType.file) {
      return 'View Image';
    }else{
      return 'View Image';
    }
  }

  String getImageByFileType(FileType? fileType) {
    if (fileType == FileType.pdf) {
      return 'assets/images/pdg.svg';
    } else if (fileType == FileType.video) {
      return 'assets/images/video.svg';
    } else if (fileType == FileType.audio) {
      return 'assets/images/document.svg';
    } else if( fileType == FileType.file) {
      return 'assets/images/image.svg';
    } else {
      return 'assets/images/file.svg';
    }
  }
}
