import 'package:awign/workforce/onboarding/data/model/work_application/attachment.dart';
import 'package:flutter/material.dart';

import '../../../core/widget/theme/theme_manager.dart';
import '../../../execution_in_house/feature/application_section_details/widget/application_section/attachment_section_resource_tile.dart';
import '../../data/model/question.dart';

class QuestionResourceWidget extends StatelessWidget {
  final Question question;
  const QuestionResourceWidget({required this.question, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(question.configuration?.questionResources != null
        && question.configuration!.questionResources!.isNotEmpty) {
      return Column(
        children: [
          buildQuestionResourceTile(),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildQuestionResourceTile() {
    List<Attachment> questionResources = question.configuration!.questionResources!;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 0, bottom: Dimens.padding_16),
      itemCount: questionResources.length,
      itemBuilder: (context, index) {
        return AttachmentSectionResourceTile(
            attachment: questionResources[index]);
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: Dimens.padding_8);
      },
    );
  }
}
