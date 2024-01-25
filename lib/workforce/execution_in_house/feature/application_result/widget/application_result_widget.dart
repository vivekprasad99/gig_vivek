import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/questions_validation_error.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/tile/question_tile.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/update_application_bottom_sheet/widget/update_application_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/application_result/cubit/application_result_cubit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/model/widget_result.dart';
import '../../../../core/widget/network_sensitive/internet_sensitive.dart';
import '../../../data/model/eligibility_entity_response.dart';

class ApplicationResultWidget extends StatefulWidget {
  final EligiblityData eligiblityData;
  const ApplicationResultWidget(this.eligiblityData,{Key? key}) : super(key: key);

  @override
  State<ApplicationResultWidget> createState() => _ApplicationResultWidgetState();
}

class _ApplicationResultWidgetState extends State<ApplicationResultWidget> {
  final _applicationResultCubit = sl<ApplicationResultCubit>();
  UserData? _curUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    subscribeUIStatus();
  }

  void subscribeUIStatus() {
    _applicationResultCubit.uiStatus.listen(
          (uiStatus) async {
        switch (uiStatus.event) {
          case Event.success:
          MRouter.pop(true);
            break;
        }
      },
    );
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _curUser = spUtil?.getUserData();
    _applicationResultCubit.getQuestions(widget.eligiblityData.applicationAnswers,_curUser?.id);
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
            DefaultAppBar(isCollapsable: true, title: 'update_application'.tr),
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
            buildScreenQuestionList(),
            buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget buildScreenQuestionList() {
    return StreamBuilder<List<ScreenRow>>(
      stream: _applicationResultCubit.screenRowListStream,
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
              },
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildSubmitButton() {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_16,
          Dimens.margin_16, Dimens.margin_16),
      child: Column(
        children: [
          Text(
            'changing_response_might_affect_eligibility_for_other_jobs'.tr,
            textAlign: TextAlign.center,
            style: Get.context?.textTheme.bodyMedium?.copyWith(
                color: AppColors.black, fontSize: Dimens.font_16),
          ),
          const SizedBox(height: Dimens.padding_16,),
          RaisedRectButton(
            text: 'submit'.tr,
            onPressed: () {
              submitAnswer();
            },
          ),
        ],
      ),
    );
  }

  _onAnswerUpdate(Question question, {WidgetResult? widgetResult}) {
    _applicationResultCubit.updateScreenRowList(question);
  }

  void submitAnswer() {
    Helper.hideKeyBoard(context);
    Result result = _applicationResultCubit.validateRequiredAnswers();
    if (result.success) {
      updateApplicationBottomSheet(Get.context!,(){
        _applicationResultCubit.onConfirmTap(_curUser!.id.toString(),widget.eligiblityData.categoryId!, _applicationResultCubit.screenRowListValue);
        MRouter.pop(null);
      },);
    } else {
      Helper.showErrorToast(
          (result.error as QuestionsValidationError).error ?? '');
    }
  }
}
