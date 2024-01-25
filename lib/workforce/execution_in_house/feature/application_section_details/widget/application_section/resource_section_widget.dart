import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/attachment.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/utils/browser_helper.dart';
import '../../../application_id_details/widget/tile/resources_tile.dart';
import 'attachment_section_resource_tile.dart';

class ResourceSectionWidget extends StatelessWidget {
  final AttachmentSection attachmentSection;
  final WorkApplicationEntity workApplicationEntity;

  const ResourceSectionWidget(
      this.attachmentSection, this.workApplicationEntity,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: attachmentSection.attachments!.isNotEmpty,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          color: AppColors.backgroundWhite,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimens.padding_32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
                  child: Text(
                    attachmentSection.title ?? '',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: attachmentSection.attachments!.length,
                  itemBuilder: (context, index) {
                    return AttachmentSectionResourceTile(
                        attachment: attachmentSection.attachments![index]);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: Dimens.padding_16);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



}
