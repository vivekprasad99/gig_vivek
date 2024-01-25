import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/worklog/cubit/worklog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../aw_questions/data/model/question.dart';
import '../../../../aw_questions/data/model/questions_validation_error.dart';
import '../../../../aw_questions/data/model/result.dart';
import '../../../../aw_questions/widget/tile/question_tile.dart';
import '../../../../core/data/model/widget_result.dart';
import '../../../data/model/worklog_widget_data.dart';

class WorkLogWidget extends StatefulWidget {
  final WorkLogWidgetData workLogWidgetData;
  const WorkLogWidget(this.workLogWidgetData, {Key? key}) : super(key: key);

  @override
  State<WorkLogWidget> createState() => _WorkLogWidgetState();
}

class _WorkLogWidgetState extends State<WorkLogWidget> {
  final WorklogCubit _workLogCubit = sl<WorklogCubit>();
  final _awQuestionsCubit = sl<AwQuestionsCubit>();

  @override
  void initState() {
    super.initState();
    _workLogCubit.getWorklog(widget.workLogWidgetData.execution!.projectId!,
        widget.workLogWidgetData!.projectRoleId!);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      topPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
                isCollapsable: true,
                title: widget.workLogWidgetData.execution!.projectName ?? '',
                leadingURL: widget.workLogWidgetData.execution!.projectIcon),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Get.context?.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<UIStatus>(
            stream: _workLogCubit.uiStatus,
            builder: (context, uiStatus) {
              if (uiStatus.hasData &&
                  (uiStatus.data?.isOnScreenLoading ?? false)) {
                return AppCircularProgressIndicator();
              } else {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0, Dimens.padding_16, 0, Dimens.padding_16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTitleText(),
                      buildScreenQuestionList(),
                      buildSubmitButton(),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget buildTitleText() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimens.padding_16, vertical: Dimens.padding_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('heading_out_to_work'.tr,
              style: Get.context?.textTheme.headline7Bold
                  .copyWith(color: AppColors.backgroundBlack)),
          const SizedBox(height: Dimens.padding_4),
          Text('worklog_question_description'.tr,
              style: Get.context?.textTheme.bodySmall
                  ?.copyWith(color: AppColors.backgroundGrey500)),
        ],
      ),
    );
  }

  Widget buildScreenQuestionList() {
    return StreamBuilder<List<ScreenRow>>(
      stream: _awQuestionsCubit.screenRowListStream,
      builder: (context, screenRowListStream) {
        if (screenRowListStream.hasData &&
            screenRowListStream.data!.isNotEmpty) {
          return Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    Dimens.padding_16, 0, Dimens.padding_16, 0),
                itemCount: screenRowListStream.data?.length,
                itemBuilder: (_, i) {
                  ScreenRow screenRow = screenRowListStream.data![i];
                  return QuestionTile(
                    screenRow: screenRow,
                    renderType: RenderType.DEFAULT,
                    onAnswerUpdate: _onAnswerUpdate,
                  );
                }),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  _onAnswerUpdate(Question question, {WidgetResult? widgetResult}) {
    _awQuestionsCubit.updateScreenRowList(question);
  }

  Widget buildSubmitButton() {
    String text = 'submit'.tr;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_16,
          Dimens.margin_16, Dimens.margin_16),
      child: RaisedRectButton(
        text: text,
        onPressed: () {
          submitAnswer();
        },
      ),
    );
  }

  void submitAnswer() {
    Helper.hideKeyBoard(context);
    Result result = _awQuestionsCubit.validateRequiredAnswers();
    if (result.success) {
      _workLogCubit.createWorklog(widget.workLogWidgetData.execution!.id ?? "",
          widget.workLogWidgetData.projectRoleUid!);
      MRouter.pop(result);
    } else {
      Helper.showErrorToast(
          (result.error as QuestionsValidationError).error ?? '');
    }
  }
}
