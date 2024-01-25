import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/auth/data/model/pan_details_entity.dart';
import 'package:awign/workforce/auth/data/model/submit_answer_request.dart';
import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/aw_questions/widget/tile/question_tile_new.dart';
import 'package:awign/workforce/core/config/cubit/flavor_cubit.dart';
import 'package:awign/workforce/core/config/flavor_config.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/my_local_route_observer.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/profile_details/widget/bottom_sheet/cubit/profile_questions_bottom_sheet_cubit.dart';
import 'package:awign/workforce/payment/data/model/document_verification_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showProfileQuestionsBottomSheet(
    BuildContext context,
    String title,
    int index,
    ScreenRow screenRow,
    Function(int index, ScreenRow screenRow,
            SubmitAnswerResponse submitAnswerResponse)
        onAnswerUpdated) {
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
            home: ProfileQuestionsWidget(
                title, index, screenRow, controller, onAnswerUpdated),
            navigatorObservers: [MyLocalRouteObserver()],
          );
        },
      );
    },
  );
}

class ProfileQuestionsWidget extends StatefulWidget {
  final String title;
  final int index;
  final ScreenRow screenRow;
  final ScrollController scrollController;
  final Function(int index, ScreenRow screenRow, SubmitAnswerResponse)
      onAnswerUpdated;
  const ProfileQuestionsWidget(this.title, this.index, this.screenRow,
      this.scrollController, this.onAnswerUpdated,
      {Key? key})
      : super(key: key);

  @override
  State<ProfileQuestionsWidget> createState() => ProfileQuestionsWidgetState();
}

class ProfileQuestionsWidgetState extends State<ProfileQuestionsWidget> {
  final _profileQuestionsBottomSheetCubit =
      sl<ProfileQuestionsBottomSheetCubit>();
  final _awQuestionsCubit = sl<AwQuestionsCubit>();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    List<ScreenRow> screenRowList = [];
    widget.screenRow.question?.screenRowIndex = 0;
    screenRowList.add(widget.screenRow);
    _awQuestionsCubit.changeScreenRowList(screenRowList);
    if ((widget.screenRow.question?.hasAnswered() ?? false)) {
      _profileQuestionsBottomSheetCubit
          .changeButtonStatus(ButtonStatus(isEnable: true));
    }
    getCurrentUser();
    checkButtonVisibility();
  }

  void subscribeUIStatus() {
    _profileQuestionsBottomSheetCubit.uiStatus.listen(
      (uiStatus) async {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.updated:
            if (uiStatus.data != null &&
                uiStatus.data is SubmitAnswerResponse?) {
              widget.onAnswerUpdated(
                  widget.index, widget.screenRow, uiStatus.data);
            }
            MRouter.pop(null);
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
    if (_currentUser != null) {}
  }

  void checkButtonVisibility() {
    switch (widget.screenRow.question?.uid) {
      case UID.panCard:
      case UID.aadharCard:
      case UID.drivingLicense:
        _profileQuestionsBottomSheetCubit.changeSaveButtonVisibility(false);
        break;
      default:
        _profileQuestionsBottomSheetCubit.changeSaveButtonVisibility(true);
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
        child: Column(
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
            buildScreenTitle(),
            buildScreenQuestionList(),
            const SizedBox(height: Dimens.margin_16),
            buildSaveButton(),
            const SizedBox(height: Dimens.margin_32),
          ],
        ),
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
    if (MRouter.localNavigatorKey.currentState?.canPop() ?? false) {
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

  Widget buildScreenTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text(
        widget.title,
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
            screenRowListStream.data != null &&
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
          return const SizedBox();
        }
      },
    );
  }

  _onAnswerUpdate(Question question, {WidgetResult? widgetResult}) {
    _awQuestionsCubit.updateScreenRowList(question,
        dynamicModuleCategory: DynamicModuleCategory.profileCompletion);
    checkValidation(question);
  }

  void checkValidation(Question question) {
    Result result = _awQuestionsCubit.validateRequiredAnswers(
        dynamicModuleCategory: DynamicModuleCategory.profileCompletion);
    if (result.success) {
      _profileQuestionsBottomSheetCubit
          .changeButtonStatus(ButtonStatus(isEnable: true));
      _checkValidationForPanAadharDL(question);
    } else {
      _profileQuestionsBottomSheetCubit
          .changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  _checkValidationForPanAadharDL(Question question) {
    if (question.answerUnit?.stringValue != null &&
        question.answerUnit?.imageDetails != null) {
      switch (question.uid) {
        case UID.panCard:
          _openDocumentVerificationWidget(question, KYCType.idProofPAN);
          break;
        case UID.aadharCard:
          _openDocumentVerificationWidget(question, KYCType.idProofAadhar);
          break;
        case UID.drivingLicense:
          _openDocumentVerificationWidget(
              question, KYCType.idProofDrivingLicence);
          break;
      }
    }
  }

  _openDocumentVerificationWidget(Question question, KYCType kycType) async {
    if (question.answerUnit?.imageDetails?.url != null) {
      _profileQuestionsBottomSheetCubit.changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));
      _profileQuestionsBottomSheetCubit.changeSaveButtonVisibility(true);
      await Future.delayed(const Duration(milliseconds: 500));
      question.answerUnit?.imageDetails?.fileQuality = FileQuality.high;
      DocumentVerificationData documentVerificationData =
          DocumentVerificationData(
              kycType: kycType,
              imageDetails: question.answerUnit!.imageDetails!);
      WidgetResult? widgetResult = await MRouter.pushNamed(
          MRouter.documentVerificationWidget,
          arguments: documentVerificationData);
      if (widgetResult != null && widgetResult.event == Event.updated) {
        question.answerUnit?.documentDetailsData = widgetResult.data;
        _awQuestionsCubit.updateScreenRowList(question,
            dynamicModuleCategory: DynamicModuleCategory.onboarding);
        switch (question.uid) {
          case UID.panCard:
            DocumentDetailsData? documentDetailsData =
                question.answerUnit?.documentDetailsData;
            if (documentDetailsData?.panDetails?.panStatus ==
                PanVerificationStatus.verified) {
              _profileQuestionsBottomSheetCubit.submitAnswer(_currentUser!);
            } else {
              _profileQuestionsBottomSheetCubit.showDummySubmittingUI();
            }
            break;
          case UID.aadharCard:
            DocumentDetailsData? documentDetailsData =
                question.answerUnit?.documentDetailsData;
            if (documentDetailsData?.aadharDetails?.aadharStatus ==
                PanVerificationStatus.verified) {
              _profileQuestionsBottomSheetCubit.submitAnswer(_currentUser!);
            } else {
              _profileQuestionsBottomSheetCubit.showDummySubmittingUI();
            }
            break;
          default:
            _profileQuestionsBottomSheetCubit.submitAnswer(_currentUser!);
            break;
        }
      } else {
        _profileQuestionsBottomSheetCubit.changeSaveButtonVisibility(false);
      }
    }
  }

  Widget buildSaveButton() {
    return StreamBuilder<bool>(
        stream: _profileQuestionsBottomSheetCubit.saveButtonVisibilityStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
              child: RaisedRectButton(
                text: 'save'.tr,
                elevation: 0,
                textStyle: Get.textTheme.bodyText2SemiBold
                    ?.copyWith(color: AppColors.backgroundWhite),
                buttonStatus: _profileQuestionsBottomSheetCubit.buttonStatus,
                onPressed: () async {
                  Helper.hideKeyBoard(context);
                  _profileQuestionsBottomSheetCubit.submitAnswer(_currentUser!);
                },
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }
}
