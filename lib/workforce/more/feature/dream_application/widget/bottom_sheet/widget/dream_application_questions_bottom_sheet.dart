import 'package:awign/workforce/auth/data/model/dream_application_completion_stage.dart';
import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/auth/feature/onboarding_questions/widget/onboarding_step_indicator.dart';
import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/tile/question_tile_new.dart';
import 'package:awign/workforce/core/config/cubit/flavor_cubit.dart';
import 'package:awign/workforce/core/config/flavor_config.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/router/my_local_route_observer.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/thanks_for_submitting_bottom_sheet/thanks_for_submitting_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/dream_application/widget/bottom_sheet/cubit/dream_application_questions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../../../core/data/model/widget_result.dart';

void showDreamApplicationQuestionsBottomSheet(
    BuildContext context,
    DreamApplicationCompletionStage dreamApplicationCompletionStage,
    Function onBottomSheetClosed) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      FlavorCubit flavorCubit = context.read<FlavorCubit>();
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        builder: (_, controller) {
          return MaterialApp(
            debugShowCheckedModeBanner:
                flavorCubit.flavorConfig.appFlavor != AppFlavor.production
                    ? false
                    : false,
            theme: ThemeManager.appTheme,
            darkTheme: ThemeManager.appThemeDark,
            themeMode: ThemeMode.light,
            onGenerateRoute: sl<MRouter>().onGenerateRoute,
            navigatorKey: MRouter.localNavigatorKey,
            home: DreamApplicationQuestionsWidget(
                controller, dreamApplicationCompletionStage),
            navigatorObservers: [MyLocalRouteObserver()],
          );
        },
      );
    },
  ).whenComplete(() {
    onBottomSheetClosed();
  });
}

class DreamApplicationQuestionsWidget extends StatefulWidget {
  final ScrollController scrollController;
  final DreamApplicationCompletionStage dreamApplicationCompletionStage;
  const DreamApplicationQuestionsWidget(
      this.scrollController, this.dreamApplicationCompletionStage,
      {Key? key})
      : super(key: key);

  @override
  State<DreamApplicationQuestionsWidget> createState() =>
      _DreamApplicationQuestionsWidgetState();
}

class _DreamApplicationQuestionsWidgetState
    extends State<DreamApplicationQuestionsWidget> {
  final _dreamApplicationQuestionsCubit = sl<DreamApplicationQuestionsCubit>();
  final _awQuestionsCubit = sl<AwQuestionsCubit>();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void subscribeUIStatus() {
    _dreamApplicationQuestionsCubit.uiStatus.listen(
      (uiStatus) async {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.updated:
            if (widget.dreamApplicationCompletionStage ==
                    DreamApplicationCompletionStage.preference &&
                uiStatus.data != null) {
              MRouter.pop(null);
              showThanksForSubmittingBottomSheet(Get.context!);
            } else {
              Map? map = await MRouter.pushNamedWithResult(
                  context,
                  DreamApplicationQuestionsWidget(
                      widget.scrollController,
                      DreamApplicationCompletionStage
                          .getNextDreamApplicationStage(
                              widget.dreamApplicationCompletionStage)),
                  MRouter.onboardingQuestionsWidget,
                  isLocal: true);
              if (!_dreamApplicationQuestionsCubit
                  .screenRowListValue.isNullOrEmpty) {
                _awQuestionsCubit.checkVisibilityAndUpdateQuestionList(
                    _dreamApplicationQuestionsCubit.screenRowListValue);
                _dreamApplicationQuestionsCubit
                    .changeButtonStatus(ButtonStatus(isEnable: true));
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
      getQuestionAnswersOrLaunchNextStep();
    }
  }

  Future<void> getQuestionAnswersOrLaunchNextStep() async {
    if (_currentUser?.userProfile?.dreamApplicationCompletionStage !=
            widget.dreamApplicationCompletionStage &&
        widget.dreamApplicationCompletionStage !=
            DreamApplicationCompletionStage.preference) {
      Map? map = await MRouter.pushNamedWithResult(
          context,
          DreamApplicationQuestionsWidget(
              widget.scrollController,
              DreamApplicationCompletionStage.getNextDreamApplicationStage(
                  widget.dreamApplicationCompletionStage)),
          MRouter.onboardingQuestionsWidget,
          isLocal: true);
      if (_dreamApplicationQuestionsCubit.hasScreenRowListValue()) {
        _awQuestionsCubit.checkVisibilityAndUpdateQuestionList(
            _dreamApplicationQuestionsCubit.screenRowListValue);
        _dreamApplicationQuestionsCubit
            .changeButtonStatus(ButtonStatus(isEnable: true));
      } else {
        _awQuestionsCubit.changeScreenRowList([]);
        _dreamApplicationQuestionsCubit.getQuestionAnswers(
            _currentUser!, widget.dreamApplicationCompletionStage);
      }
    } else {
      _dreamApplicationQuestionsCubit.getQuestionAnswers(
          _currentUser!, widget.dreamApplicationCompletionStage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<QuestionAnswersResponse>(
            stream:
                _dreamApplicationQuestionsCubit.questionAnswersResponseStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildBackIcon(),
                        buildCloseIcon(),
                      ],
                    ),
                    const SizedBox(height: Dimens.padding_16),
                    OnboardingStepIndicator(
                        snapshot.data!.categoryDetails?.screenCount ?? -1,
                        snapshot.data!.screenDetails?.screenOrder ?? -1),
                    const SizedBox(height: Dimens.padding_16),
                    buildScreenTitle(snapshot.data!),
                    buildScreenQuestionList(),
                    const SizedBox(height: Dimens.margin_16),
                    buildCompleteNowButton(),
                    const SizedBox(height: Dimens.margin_32),
                  ],
                );
              } else {
                return AppCircularProgressIndicator();
              }
            }),
      ),
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
          child: SvgPicture.asset('assets/images/ic_close_circle.svg'),
        ),
      ),
    );
  }

  Widget buildBackIcon() {
    if ((MRouter.localNavigatorKey.currentState?.canPop() ?? false) &&
        widget.dreamApplicationCompletionStage !=
            DreamApplicationCompletionStage.professionalDetails1) {
      return Align(
        alignment: Alignment.topLeft,
        child: MyInkWell(
          onTap: () {
            MRouter.pop(null, isLocal: true);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
            child: SvgPicture.asset('assets/images/ic_arrow_left.svg'),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildScreenTitle(QuestionAnswersResponse questionAnswersResponse) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text(
        questionAnswersResponse.screenDetails?.title ?? '',
        style: context.textTheme.bodyText1Bold
            ?.copyWith(color: AppColors.backgroundBlack),
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
              controller: widget.scrollController,
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
            ),
          );
        } else {
          return Expanded(child: AppCircularProgressIndicator());
        }
      },
    );
  }

  _onAnswerUpdate(Question question, {WidgetResult? widgetResult}) {
    _awQuestionsCubit.updateScreenRowList(question,
        dynamicModuleCategory: DynamicModuleCategory.dreamApplication);
    _dreamApplicationQuestionsCubit.checkValidation();
  }

  Widget buildCompleteNowButton() {
    String text = 'next'.tr;
    if (widget.dreamApplicationCompletionStage ==
        DreamApplicationCompletionStage.preference) {
      text = 'submit'.tr;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: RaisedRectButton(
        text: text,
        elevation: 0,
        textStyle: Get.textTheme.bodyText2SemiBold
            ?.copyWith(color: AppColors.backgroundWhite),
        buttonStatus: _dreamApplicationQuestionsCubit.buttonStatus,
        onPressed: () async {
          Helper.hideKeyBoard(context);
          _dreamApplicationQuestionsCubit.submitAnswer(
              _currentUser!, widget.dreamApplicationCompletionStage);
        },
      ),
    );
  }
}
