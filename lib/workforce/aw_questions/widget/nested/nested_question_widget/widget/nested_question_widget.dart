import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/questions_validation_error.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/nested/nested_question_widget/cubit/nested_question_cubit.dart';
import 'package:awign/workforce/aw_questions/widget/tile/question_tile.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../../core/data/model/widget_result.dart';

class NestedQuestionWidget extends StatefulWidget {
  final Question question;

  const NestedQuestionWidget(this.question, {Key? key}) : super(key: key);

  @override
  State<NestedQuestionWidget> createState() => NestedQuestionWidgetState();
}

class NestedQuestionWidgetState extends State<NestedQuestionWidget> {
  final NestedQuestionCubit _nestedQuestionCubit = sl<NestedQuestionCubit>();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    _nestedQuestionCubit.setNestedQuestionList(widget.question);
  }

  void subscribeUIStatus() {
    _nestedQuestionCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.success:
            break;
        }
      },
    );
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
              isCollapsable: true,
              title: (widget.question.configuration?.questionText ?? '')
                  .toCapitalized(),
            ),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: buildNestedQuestionList(),
              ),
            ),
            buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget buildNestedQuestionList() {
    return StreamBuilder<List<ScreenRow>>(
      stream: _nestedQuestionCubit.screenRowListStream,
      builder: (context, screenRowListStream) {
        if (screenRowListStream.hasData &&
            screenRowListStream.data!.isNotEmpty) {
          return ListView.builder(
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
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  _onAnswerUpdate(Question question, {WidgetResult? widgetResult}) {
    _nestedQuestionCubit.updateScreenRowList(question);
  }

  Widget buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_24, Dimens.padding_16,
          Dimens.padding_24, Dimens.padding_24),
      child: RaisedRectButton(
        text: 'submit'.tr,
        onPressed: () {
          Helper.hideKeyBoard(context);
          Result result = _nestedQuestionCubit.validateRequiredAnswers();
          if (result.success) {
            AnswerUnit? answerUnit =
                _nestedQuestionCubit.getAnswerUnit(widget.question);
            MRouter.pop(answerUnit);
          } else {
            Helper.showErrorToast(
                (result.error as QuestionsValidationError).error ?? '');
          }
        },
      ),
    );
  }
}
