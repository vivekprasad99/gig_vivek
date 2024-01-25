import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:flutter/material.dart';

class StatusButtonSectionWidget extends StatelessWidget {
  final WorkApplicationEntity workApplicationEntity;
  final Function(
          WorkApplicationEntity workApplicationEntity, ActionData actionData)
      onApplicationAction;

  const StatusButtonSectionWidget(
      this.workApplicationEntity, this.onApplicationAction,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildButton();
  }

  Widget buildButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_24,
          Dimens.margin_16, Dimens.margin_16),
      child: RaisedRectButton(
        height: Dimens.btnHeight_40,
        text:
            '${workApplicationEntity.supplyPendingAction?.value.replaceAll("_", " ")}'
                .toTitleCase(),
        onPressed: () {
          onApplicationAction(workApplicationEntity,
              workApplicationEntity.pendingAction ?? ActionData());
        },
      ),
    );
  }
}
