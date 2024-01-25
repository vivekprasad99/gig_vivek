import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/question_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/application_section_details/widget/provider/application_details_section_widget_provider.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/base_section.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SectionTile extends StatelessWidget {
  final int index;
  final BaseSection baseSection;
  final WorkApplicationEntity workApplicationEntity;
  final Function(WorkApplicationEntity workApplicationEntity, ActionData actionData) onApplicationAction;

  const SectionTile({Key? key, required this.index, required this.baseSection, required this.workApplicationEntity,
  required this.onApplicationAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildSection();
  }

  Widget buildSection() {
    return ApplicationDetailsSectionWidgetProvider.getActionSection(baseSection, workApplicationEntity, onApplicationAction);
  }
}
