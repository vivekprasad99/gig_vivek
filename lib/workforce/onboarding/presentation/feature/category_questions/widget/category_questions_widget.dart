import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/questions_validation_error.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/tile/question_tile.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_questions/cubit/category_questions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../../core/data/model/widget_result.dart';

class CategoryQuestionsWidget extends StatefulWidget {
  final int categoryID;
  final List<ScreenRow> categoryQuestions;
  final String fromRoute;

  const CategoryQuestionsWidget(
      this.categoryID, this.categoryQuestions, this.fromRoute,
      {Key? key})
      : super(key: key);

  @override
  State<CategoryQuestionsWidget> createState() =>
      _CategoryQuestionsWidgetState();
}

class _CategoryQuestionsWidgetState extends State<CategoryQuestionsWidget> {
  final _categoryQuestionsCubit = sl<CategoryQuestionsCubit>();
  final _awQuestionsCubit = sl<AwQuestionsCubit>();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    subscribeUIStatus();
    _awQuestionsCubit.changeScreenRowList(widget.categoryQuestions);
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    setState(() {
      _currentUser = spUtil?.getUserData();
    });

    Map<String, dynamic> properties =
        await UserProperty.getUserProperty(_currentUser!);
    properties[CleverTapConstant.categoryId] = widget.categoryID;
    ClevertapData clevertapData = ClevertapData(
        eventName: ClevertapHelper.categoryApplicationFormOpened,
        properties: properties);
    LoggingData loggingData = LoggingData(
        event: LoggingEvents.categoryQuestionsOpened,
        otherProperty: {Constants.categoryId: widget.categoryID.toString()});
    CaptureEventHelper.captureEvent(
        clevertapData: clevertapData, loggingData: loggingData);
  }

  void subscribeUIStatus() {
    _categoryQuestionsCubit.uiStatus.listen(
      (uiStatus) async {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.success:
            MRouter.popNamedWithResult(
                widget.fromRoute, Constants.success, true);
            break;
          case Event.failed:
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
            DefaultAppBar(isCollapsable: true, title: 'application_form'.tr),
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimens.padding_24,
                    Dimens.padding_24,
                    Dimens.padding_24,
                    Dimens.padding_24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildCategoryQuestionList(),
                    ],
                  ),
                ),
              ),
            ),
            buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_24, Dimens.padding_16,
          Dimens.padding_24, Dimens.padding_24),
      child: RaisedRectButton(
        text: 'submit'.tr,
        onPressed: () async {
          Helper.hideKeyBoard(context);
          Result result = _awQuestionsCubit.validateRequiredAnswers();
          if (result.success) {
            if (_awQuestionsCubit.screenRowListValue != null) {
              _categoryQuestionsCubit.submit(_currentUser!.id.toString(),
                  widget.categoryID, _awQuestionsCubit.screenRowListValue!);
            }
          } else {
            Helper.showErrorToast(
                (result.error as QuestionsValidationError).error ?? '');
          }
          Map<String, dynamic> properties =
              await UserProperty.getUserProperty(_currentUser!);
          properties[CleverTapConstant.categoryId] = widget.categoryID;
          ClevertapData clevertapData = ClevertapData(
              eventName: ClevertapHelper.categoryApplicationFormSubmitted,
              properties: properties);
          LoggingData loggingData = LoggingData(
              event: LoggingEvents.categoryQuestionsSubmitted,
              otherProperty: {
                Constants.categoryId: widget.categoryID.toString()
              });
          CaptureEventHelper.captureEvent(
              clevertapData: clevertapData, loggingData: loggingData);
        },
      ),
    );
  }

  Widget buildCategoryQuestionList() {
    return StreamBuilder<List<ScreenRow>>(
      stream: _awQuestionsCubit.screenRowListStream,
      builder: (context, screenRowListStream) {
        if (screenRowListStream.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 0),
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
    _awQuestionsCubit.updateScreenRowList(question);
  }
}
