import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteSectionWidget extends StatelessWidget {
  final BulletPointsSection bulletPointsSection;
  final WorkApplicationEntity workApplicationEntity;

  const NoteSectionWidget(this.bulletPointsSection, this.workApplicationEntity,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.margin_16, Dimens.margin_16, 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTitleWidget(),
            buildPointsList(bulletPointsSection.points),
          ],
        ),
      ),
    );
  }

  Widget buildTitleWidget() {
    return Text(bulletPointsSection.title,
        style: Get.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget buildPointsList(List<String>? points) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 0),
      itemCount: points?.length,
      itemBuilder: (_, i) {
        return NotesTile(
          index: i,
          point: points![i],
        );
      },
    );
  }
}

class NotesTile extends StatelessWidget {
  final int index;
  final String point;

  const NotesTile({required this.index, required this.point, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: Dimens.padding_16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Dimens.iconSize_8,
            height: Dimens.iconSize_8,
            margin: const EdgeInsets.only(top: Dimens.padding_4),
            decoration: const BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.all(
                Radius.circular(Dimens.radius_12),
              ),
            ),
          ),
          const SizedBox(width: Dimens.padding_16),
          Flexible(child: Text(point, style: Get.textTheme.bodyText2)),
        ],
      ),
    );
  }
}
