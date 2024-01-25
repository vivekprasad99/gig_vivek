import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/image_loader/network_image_loader.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/university/data/model/university_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../../core/data/local/repository/logging_event/helper/logging_events.dart';

class UniversityTile extends StatelessWidget {
  final int index;
  final CoursesEntity coursesEntity;
  final Function(CoursesEntity coursesEntity) onCourseTileClicked;

  const UniversityTile(
      {Key? key, required this.index, required this.coursesEntity, required this.onCourseTileClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
      child: MyInkWell(
        onTap: () {
          onCourseTileClicked(coursesEntity);
          LoggingData loggingData = LoggingData(
              action: LoggingActions.courseCardClicked,
              otherProperty: getLoggingEvents());
          CaptureEventHelper.captureEvent(loggingData: loggingData);
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: Dimens.margin_8),
          elevation: Dimens.margin_4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimens.margin_16)),
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_12))),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NetworkImageLoader(
                    url: coursesEntity.thumbnail ?? " ",
                    width: Dimens.imageWidth_56,
                    height: Dimens.imageHeight_56,
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: Dimens.margin_12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coursesEntity.name ?? '',
                          textAlign: TextAlign.start,
                          style: context.textTheme.bodyText1Bold
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: Dimens.margin_8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: AppColors.backgroundGrey400,
                            borderRadius: BorderRadius.all(
                                Radius.circular(Dimens.radius_4))),
                        child: Text(coursesEntity.category ?? '',
                            textAlign: TextAlign.start,
                            style: context.textTheme.bodyText1?.copyWith(
                                fontSize: Dimens.font_16,
                                fontWeight: FontWeight.w400)),
                      ),
                      const SizedBox(height: Dimens.margin_8),
                      Row(
                        children: [
                          Text(coursesEntity.byWhom ?? '',
                              textAlign: TextAlign.start,
                              style: context.textTheme.bodyText1?.copyWith(
                                  fontSize: Dimens.font_16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.backgroundGrey800)),
                          const SizedBox(width: Dimens.margin_8),
                          Text('|',
                              textAlign: TextAlign.start,
                              style: context.textTheme.bodyText1?.copyWith(
                                  fontSize: Dimens.font_16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.backgroundGrey800)),
                          const SizedBox(width: Dimens.margin_8),
                          const Icon(
                            Icons.remove_red_eye,
                            color: AppColors.backgroundGrey800,
                            size: Dimens.iconSize_16,
                          ),
                          const SizedBox(width: Dimens.margin_4),
                          Text("${coursesEntity.views.toString()} Views" ?? '',
                              textAlign: TextAlign.start,
                              style: context.textTheme.bodyText1?.copyWith(
                                  fontSize: Dimens.font_16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.backgroundGrey800)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, String> getLoggingEvents() {
    Map<String, String> properties = {};
    properties[LoggingEvents.courseId] = coursesEntity.id?.toString() ?? '';
    properties[LoggingEvents.category] =
        coursesEntity.category?.toString() ?? '';
    properties[LoggingEvents.byWhom] = coursesEntity.byWhom?.toString() ?? '';
    properties[LoggingEvents.skills] = coursesEntity.skills?.toString() ?? '';
    return properties;
  }
}
