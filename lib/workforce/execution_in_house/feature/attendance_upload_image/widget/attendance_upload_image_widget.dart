import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/questions_validation_error.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/tile/question_tile.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/data/screen_question_arguments.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance_upload_image/cubit/attendance_upload_image_cubit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';


class AttendanceUploadImageWidget extends StatefulWidget {
  final ScreenQuestionArguments screenQuestionArguments;

  const AttendanceUploadImageWidget(this.screenQuestionArguments, {Key? key})
      : super(key: key);

  @override
  State<AttendanceUploadImageWidget> createState() =>
      _AttendanceUploadImageWidgetState();
}

class _AttendanceUploadImageWidgetState
    extends State<AttendanceUploadImageWidget> {
  final AttendanceUploadImageCubit _attendanceUploadImageCubit = sl<AttendanceUploadImageCubit>();
  final _awQuestionsCubit = sl<AwQuestionsCubit>();

  @override
  void initState() {
    super.initState();
    _attendanceUploadImageCubit.getScreenRowList(widget.screenQuestionArguments);
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
        bottomPadding: 0,
        body: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            iconTheme: const IconThemeData(
              color: AppColors.black,
            ),
            elevation: 0,
            backgroundColor: AppColors.backgroundWhite,
            title: Text(
              'upload_image'.tr,
              style: Get.context?.textTheme.titleLarge?.copyWith(
                  color: AppColors.black, fontWeight: FontWeight.w500),
            ),
            actions: [
              buildCloseButton(),
            ],
          ),
          body: buildBody(),
        ));
  }

  Widget buildCloseButton() {
    return MyInkWell(
      onTap: () {
        MRouter.pop(null);
      },
      child: const Padding(
        padding: EdgeInsets.only(top: Dimens.margin_16,right: Dimens.padding_16),
        child: CircleAvatar(
          backgroundColor: AppColors.backgroundGrey700,
          radius: Dimens.padding_12,
          child: Icon(
            Icons.close,
            color: AppColors.backgroundWhite,
            size: Dimens.padding_16,
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      color: AppColors.backgroundWhite,
      width: double.infinity,
      child: InternetSensitive(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16,
            Dimens.padding_16,
            Dimens.padding_16,
            Dimens.padding_16,
          ),
          child: Column(
            children: [
              buildScreenQuestionList(),
              buildSubmitButton(),
            ],
          ),
        ),
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

  Widget buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
          Dimens.padding_16, Dimens.padding_16),
      child: RaisedRectButton(
        text: widget.screenQuestionArguments.isNotLastScreen! ? 'submit_proceed'.tr : 'submit'.tr,
        buttonStatus: _attendanceUploadImageCubit.buttonStatus,
        onPressed: () {
          submitAnswer();
        },
      ),
    );
  }

  _onAnswerUpdate(Question question, {WidgetResult? widgetResult}) {
    _awQuestionsCubit.updateScreenRowList(question,
        dynamicModuleCategory: DynamicModuleCategory.attendance);
        checkValidation();
  }

  void checkValidation() {
    Result result = _awQuestionsCubit.validateRequiredAnswers();
    if (result.success) {
      _attendanceUploadImageCubit
          .changeButtonStatus(ButtonStatus(isEnable: true));
    } else {
      _attendanceUploadImageCubit
          .changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  void submitAnswer() {
    Result result = _awQuestionsCubit.validateRequiredAnswers();
    if (result.success) {
      MRouter.pop(_awQuestionsCubit.screenRowListValue);
    } else {
      Helper.showErrorToast(
          (result.error as QuestionsValidationError).error ?? '');
    }
  }
}
