import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/university/data/model/university_entity.dart';
import 'package:awign/workforce/university/feature/awign_university/cubit/awign_university_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';

class UniversityVideoWidget extends StatefulWidget {
  final CoursesEntity coursesEntity;
  const UniversityVideoWidget(this.coursesEntity, {Key? key}) : super(key: key);

  @override
  State<UniversityVideoWidget> createState() => _UniversityVideoWidgetState();
}

class _UniversityVideoWidgetState extends State<UniversityVideoWidget> {
  final _awignUniversityCubit = sl<AwignUniversityCubit>();
  late YoutubePlayerController controller;
  bool isReadMore = false;
  bool isStartLearningSelected = false;

  @override
  void initState() {
    super.initState();
    _awignUniversityCubit.getCourse(widget.coursesEntity.id!);
    subscribeUIStatus();
    controller = YoutubePlayerController(
      initialVideoId:
          YoutubePlayer.convertUrlToId(widget.coursesEntity.videoLink!.url!) ??
              "",
      flags: const YoutubePlayerFlags(
        autoPlay: true,
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    controller.pause();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void subscribeUIStatus() {
    _awignUniversityCubit.uiStatus.listen(
      (uiStatus) {
        switch (uiStatus.event) {
          case Event.success:
            _awignUniversityCubit.getCourse(widget.coursesEntity.id!);
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(context),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if(isStartLearningSelected) {
          setState(() {
            isStartLearningSelected = !isStartLearningSelected;
          });
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: YoutubePlayerBuilder(
        builder: (BuildContext, player) {
          return AppScaffold(
              backgroundColor: AppColors.primaryMain,
              bottomPadding: 0,
              topPadding: 0,
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return <Widget>[
                    const DefaultAppBar(
                      isCollapsable: true,
                    ),
                  ];
                },
                body: buildBody(context, player),
              ));
        },
        player: YoutubePlayer(
          controller: controller,
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context, Widget player) {
    return Container(
      decoration: BoxDecoration(
        color: Get.context!.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16,
            Dimens.padding_24,
            Dimens.padding_16,
            Dimens.padding_16,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(visible: isStartLearningSelected, child: player),
                  const SizedBox(height: Dimens.margin_12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: StreamBuilder<CourseResponse>(
                          stream: _awignUniversityCubit.courseResponseStream,
                          builder: (context, courseResponse) {
                            if (courseResponse.hasData &&
                                courseResponse.data != null) {
                              CoursesEntity? coursesEntity = courseResponse
                                  .data!.courseData!.coursesEntity;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(coursesEntity!.name ?? '',
                                      textAlign: TextAlign.start,
                                      style: Get
                                          .context!.textTheme.bodyText1Bold
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                  const SizedBox(height: Dimens.margin_12),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                        color: AppColors.backgroundGrey400,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(Dimens.radius_4))),
                                    child: Text(coursesEntity!.category ?? '',
                                        textAlign: TextAlign.start,
                                        style: Get.context!.textTheme.bodyText1
                                            ?.copyWith(
                                                fontSize: Dimens.font_16,
                                                fontWeight: FontWeight.w400)),
                                  ),
                                  const SizedBox(height: Dimens.margin_12),
                                  Row(
                                    children: [
                                      Text(coursesEntity!.byWhom ?? '',
                                          textAlign: TextAlign.start,
                                          style: Get
                                              .context!.textTheme.bodyText1
                                              ?.copyWith(
                                                  fontSize: Dimens.font_16,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors
                                                      .backgroundGrey800)),
                                      const SizedBox(width: Dimens.margin_8),
                                      Text('|',
                                          textAlign: TextAlign.start,
                                          style: Get
                                              .context!.textTheme.bodyText1
                                              ?.copyWith(
                                                  fontSize: Dimens.font_16,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors
                                                      .backgroundGrey800)),
                                      const SizedBox(width: Dimens.margin_8),
                                      const Icon(
                                        Icons.remove_red_eye,
                                        color: AppColors.backgroundGrey800,
                                        size: Dimens.iconSize_16,
                                      ),
                                      const SizedBox(width: Dimens.margin_4),
                                      Text(
                                          "${coursesEntity!.views.toString()} Views" ??
                                              '',
                                          textAlign: TextAlign.start,
                                          style: Get
                                              .context!.textTheme.bodyText1
                                              ?.copyWith(
                                                  fontSize: Dimens.font_16,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors
                                                      .backgroundGrey800)),
                                    ],
                                  ),
                                  const SizedBox(height: Dimens.margin_24),
                                  Text('description'.tr,
                                      textAlign: TextAlign.start,
                                      style: Get
                                          .context!.textTheme.bodyText1Bold
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                  buildDescription(),
                                  MyInkWell(
                                    onTap: () {
                                      setState(() {
                                        isReadMore = !isReadMore;
                                      });
                                    },
                                    child: Text(isReadMore ? '' : 'Read More',
                                        textAlign: TextAlign.start,
                                        style: Get.context!.textTheme.bodyText1
                                            ?.copyWith(
                                                fontSize: Dimens.font_16,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.primaryMain)),
                                  ),
                                  const SizedBox(height: Dimens.margin_24),
                                  Text('things_to_learn'.tr,
                                      textAlign: TextAlign.start,
                                      style: Get
                                          .context!.textTheme.bodyText1Bold
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                  Html(
                                    data: coursesEntity!.thingsToLearn!
                                            .replaceAll(
                                                "</b> <b>", "</b>&nbsp;<b>") ??
                                        '',
                                    style: {
                                      "body": Style(
                                        fontSize: const FontSize(15.0),
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.backgroundGrey800,
                                        margin: EdgeInsets.zero,
                                        padding: EdgeInsets.zero,
                                      ),
                                    },
                                  ),
                                ],
                              );
                            } else {
                              return const SizedBox();
                            }
                          }),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: !isStartLearningSelected,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: Dimens.margin_38,
                    margin: const EdgeInsets.fromLTRB(Dimens.margin_4,
                        Dimens.margin_24, Dimens.margin_4, Dimens.margin_4),
                    child: RaisedRectButton(
                      text: 'start_learning'.tr,
                      onPressed: () {
                        setState(() {
                          isStartLearningSelected = !isStartLearningSelected;
                        });
                        _awignUniversityCubit
                            .updateViews(widget.coursesEntity.id!);
                        LoggingData loggingData = LoggingData(
                            action: LoggingActions.startCourseClicked,
                            otherProperty: getLoggingEvents());
                        CaptureEventHelper.captureEvent(
                            loggingData: loggingData);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDescription() {
    final lines = isReadMore ? 50 : 3;
    return Html(
      data: widget.coursesEntity.description!
              .replaceAll("</b> <b>", "</b>&nbsp;<b>") ??
          '',
      style: {
        "body": Style(
          fontSize: const FontSize(15.0),
          fontWeight: FontWeight.w400,
          maxLines: lines,
          textOverflow: TextOverflow.ellipsis,
          color: AppColors.backgroundGrey800,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
        ),
      },
    );
  }

  Map<String, String> getLoggingEvents() {
    Map<String, String> properties = {};
    properties[LoggingEvents.courseId] =
        widget.coursesEntity.id?.toString() ?? '';
    properties[LoggingEvents.category] =
        widget.coursesEntity.category?.toString() ?? '';
    properties[LoggingEvents.byWhom] =
        widget.coursesEntity.byWhom?.toString() ?? '';
    properties[LoggingEvents.skills] =
        widget.coursesEntity.skills?.toString() ?? '';
    return properties;
  }
}
