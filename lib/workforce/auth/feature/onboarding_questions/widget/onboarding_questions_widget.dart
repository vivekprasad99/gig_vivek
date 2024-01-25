import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/auth/data/model/onboarding_completion_stage.dart';
import 'package:awign/workforce/auth/feature/onboarding_questions/cubit/onboarding_questions_cubit.dart';
import 'package:awign/workforce/auth/feature/onboarding_questions/widget/onboarding_step_indicator.dart';
import 'package:awign/workforce/auth/helper/auth_helper.dart';
import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/tile/question_tile_new.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/mobile_on_desktop_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/model/widget_result.dart';

class OnboardingQuestionsWidget extends StatefulWidget {
  const OnboardingQuestionsWidget({Key? key}) : super(key: key);

  @override
  State<OnboardingQuestionsWidget> createState() =>
      _OnboardingQuestionsWidgetState();
}

class _OnboardingQuestionsWidgetState extends State<OnboardingQuestionsWidget> {
  final _onboardingQuestionsCubit = sl<OnboardingQuestionsCubit>();
  final _awQuestionsCubit = sl<AwQuestionsCubit>();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void subscribeUIStatus() {
    _onboardingQuestionsCubit.uiStatus.listen(
      (uiStatus) async {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.updated:
            if (_currentUser?.userProfile?.onboardingCompletionStage ==
                    OnboardingCompletionStage.availabilityType &&
                uiStatus.data != null) {
              AuthHelper.checkOnboardingStages(uiStatus.data!);
            } else {
              Map? map = await MRouter.pushNamedWithResult(
                  context,
                  OnboardingQuestionsWidget(),
                  MRouter.onboardingQuestionsWidget);
              _onboardingQuestionsCubit
                  .changeButtonStatus(ButtonStatus(isEnable: true));
              if (!_onboardingQuestionsCubit.screenRowListValue.isNullOrEmpty) {
                _awQuestionsCubit.checkVisibilityAndUpdateQuestionList(
                    _onboardingQuestionsCubit.screenRowListValue);
              }
            }
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (_currentUser != null) {
      _onboardingQuestionsCubit.getQuestionAnswers(_currentUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mobileWidget = buildMobileUI();
    return ScreenTypeLayout(
      mobile: mobileWidget,
      desktop: MobileOnDesktopWidget(mobileWidget),
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
            const DefaultAppBar(
              isCollapsable: true,
              isPopUpMenuVisible: true,
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
        child: StreamBuilder<QuestionAnswersResponse>(
            stream: _onboardingQuestionsCubit.questionAnswersResponseStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0, Dimens.padding_32, 0, Dimens.padding_32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OnboardingStepIndicator(
                            (snapshot.data!.categoryDetails?.screenCount ??
                                    -1) -
                                1,
                            (snapshot.data!.screenDetails?.screenOrder ?? -1) -
                                1),
                        const SizedBox(height: Dimens.padding_32),
                        buildScreenTitle(snapshot.data!),
                        const SizedBox(height: Dimens.padding_8),
                        buildScreenDescription(snapshot.data!),
                        buildScreenQuestionList(),
                        buildContinueButton(),
                      ],
                    ),
                  ),
                );
              } else {
                return AppCircularProgressIndicator();
              }
            }),
      ),
    );
  }

  Widget buildScreenTitle(QuestionAnswersResponse questionAnswersResponse) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text(
        questionAnswersResponse.screenDetails?.title ?? '',
        style: context.textTheme.bodyText1SemiBold
            ?.copyWith(color: AppColors.backgroundBlack),
      ),
    );
  }

  Widget buildScreenDescription(
      QuestionAnswersResponse questionAnswersResponse) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text(
        questionAnswersResponse.screenDetails?.description ?? '',
        style: context.textTheme.caption
            ?.copyWith(color: AppColors.backgroundGrey800),
      ),
    );
  }

  Widget buildScreenQuestionList() {
    return StreamBuilder<List<ScreenRow>>(
      stream: _awQuestionsCubit.screenRowListStream,
      builder: (context, screenRowListStream) {
        if (screenRowListStream.hasData &&
            screenRowListStream.data!.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_16, 0, Dimens.padding_16, 0),
            itemCount: screenRowListStream.data?.length ?? 0,
            itemBuilder: (_, i) {
              ScreenRow screenRow = screenRowListStream.data![i];
              return QuestionTileNew(
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
    _awQuestionsCubit.updateScreenRowList(question,
        dynamicModuleCategory: DynamicModuleCategory.onboarding);
    checkValidation();
  }

  void checkValidation() {
    Result result = _awQuestionsCubit.validateRequiredAnswers();
    if (result.success) {
      _onboardingQuestionsCubit
          .changeButtonStatus(ButtonStatus(isEnable: true));
    } else {
      _onboardingQuestionsCubit
          .changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  Widget buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_24,
          Dimens.margin_16, Dimens.margin_16),
      child: RaisedRectButton(
        text: 'save_and_continue'.tr,
        buttonStatus: _onboardingQuestionsCubit.buttonStatus,
        onPressed: () {
          Helper.hideKeyBoard(context);
          _onboardingQuestionsCubit.submitAnswer(_currentUser!);
        },
      ),
    );
  }
}
