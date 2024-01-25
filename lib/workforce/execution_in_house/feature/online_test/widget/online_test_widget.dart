import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/questions_validation_error.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/online_test_exit_bottom_sheet/widget/online_test_exit_bottom.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/resources_bottom_sheet/widget/resources_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/online_test/cubit/online_test_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/online_test/helper/question_inflate_helper.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/model/widget_result.dart';

class OnlineTestWidget extends StatefulWidget {
  final WorkApplicationEntity workApplicationEntity;

  const OnlineTestWidget(this.workApplicationEntity, {Key? key})
      : super(key: key);

  @override
  State<OnlineTestWidget> createState() => _OnlineTestWidgetState();
}

class _OnlineTestWidgetState extends State<OnlineTestWidget> {
  final OnlineTestCubit _onlineTestCubit = sl<OnlineTestCubit>();
  final _awQuestionsCubit = sl<AwQuestionsCubit>();
  UserData? _currentUser;
  bool isSkipSaasOrgID = false;
  bool showTimerInQuestion = true;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (spUtil!.getSaasOrgID().isNullOrEmpty) {
      isSkipSaasOrgID = true;
    }
    _onlineTestCubit.fetchScreens(_currentUser!, widget.workApplicationEntity);
    _onlineTestCubit.fetchResource(_currentUser?.id,widget.workApplicationEntity);

  }

  void subscribeUIStatus() {
    _onlineTestCubit.uiStatus.listen(
      (uiStatus) {
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
          case Event.answerSubmitSuccess:
            setNextQuestion();
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => onBackTap(),
      child: ScreenTypeLayout(
        mobile: buildMobileUI(),
        desktop: const DesktopComingSoonWidget(),
      ),
    );
  }

  bool onBackTap() {
    Helper.hideKeyBoard(context);
    showOnlineTestExitBottomSheet(context, () {
      MRouter.pop(null);
      MRouter.pop(null);
    });
    return false;
  }

  Widget buildMobileUI() {
    String title = '';
    StepType? stepType = widget.workApplicationEntity.pendingAction?.actionKey
        ?.getOnlineTestStepType();
    switch (stepType) {
      case StepType.interview:
        title = 'In-App Interview';
        break;
      case StepType.training:
        title = 'In-App Training';
        break;
      case StepType.pitchDemo:
        title = 'Pitch Demo';
        break;
      case StepType.pitchTest:
        title = 'Pitch Test';
        break;
    }
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: title),
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
        child: StreamBuilder<List<ScreenRow>>(
          stream: _awQuestionsCubit.screenRowListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && !snapshot.data.isNullOrEmpty) {
              return Column(
                children: [
                  Expanded(child: buildCurrentQuestion(snapshot.data!)),
                  buildSubmitButton(snapshot.data!),
                  buildBottomOverlayWidget()
                ],
              );
            } else {
              return AppCircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget buildCurrentQuestion(List<ScreenRow> screenRowList) {
    if (_onlineTestCubit.currentIndex == -1) {
      _onlineTestCubit.currentIndex++;
    }
    ScreenRow screenRow = screenRowList[_onlineTestCubit.currentIndex];
    if (screenRow.question?.configuration?.timeToAnswer != null
        && (screenRow.question?.configuration?.showTimer ?? false)
        && !(_onlineTestCubit.timer?.isActive ?? false)) {
      _onlineTestCubit.startTimeout();
    }
    return QuestionInflateHelper(
        screenRow,
        RenderType.DEFAULT,
        _onlineTestCubit.screenResponseValue?.offset ?? 0 + _onlineTestCubit.currentIndex,
        _onlineTestCubit.screenResponseValue?.total ?? 0,
        _onlineTestCubit.timerText,
        showTimerInQuestion,
        _timerCompleted,
        _onAnswerUpdate);
  }

  _timerCompleted() {
    showTimerInQuestion = false;
  }

  _onAnswerUpdate(Question question, {WidgetResult? widgetResult}) {
    _awQuestionsCubit.updateScreenRowList(question);
    if (question.hasAnswered()) {
      _onlineTestCubit.changeButtonStatus(ButtonStatus(isEnable: true));
    } else {
      _onlineTestCubit.changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  Widget buildSubmitButton(List<ScreenRow> screenRowList) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          Dimens.margin_16,
          Dimens.margin_16,
          Dimens.margin_16,
          defaultTargetPlatform == TargetPlatform.iOS
              ? Dimens.margin_32
              : Dimens.margin_16),
      child: StreamBuilder<ButtonStatus>(
        stream: _onlineTestCubit.buttonStatusStream,
        builder: (context, snapshot) {
          return RaisedRectButton(
            text: 'submit'.tr,
            buttonStatus: _onlineTestCubit.buttonStatus,
            onPressed: () {
              if (snapshot.hasData && snapshot.data?.isEnable == true) {
                submitAnswer(screenRowList);
              }
            },
          );
        }
      ),
    );
  }

  void submitAnswer(List<ScreenRow> screenRowList) {
    Helper.hideKeyBoard(context);
    ScreenRow screenRow = screenRowList[_onlineTestCubit.currentIndex];
    Result result = _awQuestionsCubit.validateRequiredAnswer(
        screenRow.question!, _onlineTestCubit.currentIndex);
    if (result.success) {
      if (screenRow.question?.hasAnswered() == true) {
        _onlineTestCubit.submitAnswer(
          widget.workApplicationEntity,
          _currentUser!,
          int.parse((screenRow.question?.configuration?.uid ?? '-1')),
          screenRow.question!.answerUnit!,
          10);
      } else {
        Helper.showErrorToast("Please answer first");
      }
    } else {
      Helper.showErrorToast(
          (result.error as QuestionsValidationError).error ?? '');
    }
  }

  void setNextQuestion() {
    showTimerInQuestion = true;
    if (_onlineTestCubit.isNextQuestionLoaded()) {
      _onlineTestCubit.currentIndex++;
      _awQuestionsCubit.reloadScreenRowList();
    } else if (_onlineTestCubit.hasMoreScreens()) {
      _onlineTestCubit.fetchScreens(
          _currentUser!, widget.workApplicationEntity);
    } else {
      MRouter.popNamedWithResult(
          widget.workApplicationEntity.fromRoute ?? MRouter.categoryApplicationDetailsWidget, Constants.doRefresh, true);
    }
  }

  Widget buildBottomOverlayWidget() {
    return StreamBuilder<String?>(
      stream: _onlineTestCubit.timerText,
      builder: (context, snapshot) {
        if(snapshot.data == '00:00'){
          return Hero(
            tag: 'ResourcesBottomSheet',
            child: MyInkWell(
              onTap: () {
                showResourcesBottomSheet(context,_onlineTestCubit.resourceValue, () {
                  // MRouter.pop(null);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(Dimens.padding_16),
                decoration: const BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimens.radius_16),
                    topRight: Radius.circular(Dimens.radius_16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb,
                                  color: AppColors.yellow, size: Dimens.iconSize_16),
                              const SizedBox(width: Dimens.padding_8),
                              Text(
                                'not_able_to_answer'.tr,
                                textAlign: TextAlign.center,
                                style: Get.textTheme.headline5
                                    ?.copyWith(color: AppColors.backgroundWhite),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down,
                            color: AppColors.backgroundWhite),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: Dimens.padding_24),
                      child: Text(
                        'view_material'.tr,
                        textAlign: TextAlign.center,
                        style: Get.textTheme.bodyText2
                            ?.copyWith(color: AppColors.backgroundWhite),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }else{
          return const SizedBox();
        }

      }
    );
  }
}
