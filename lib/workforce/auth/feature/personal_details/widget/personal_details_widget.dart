import 'package:awign/workforce/auth/data/model/get_question_answers_response.dart';
import 'package:awign/workforce/auth/feature/personal_details/cubit/personal_details_cubit.dart';
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

class PersonalDetailsWidget extends StatefulWidget {
  const PersonalDetailsWidget({Key? key}) : super(key: key);

  @override
  _PersonalDetailsWidgetState createState() => _PersonalDetailsWidgetState();
}

class _PersonalDetailsWidgetState extends State<PersonalDetailsWidget> {
  final _personalDetailsCubit = sl<PersonalDetailsCubit>();
  final _awQuestionsCubit = sl<AwQuestionsCubit>();
  UserData? _currentUser;
  bool isSwitched = false;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void subscribeUIStatus() {
    _personalDetailsCubit.uiStatus.listen(
      (uiStatus) async {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.updated:
            SPUtil? spUtil = await SPUtil.getInstance();
            _currentUser = spUtil?.getUserData();
            AuthHelper.checkOnboardingStages(_currentUser!);
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
      _personalDetailsCubit.getQuestionAnswers(_currentUser!);
      _personalDetailsCubit.subscribeWhatsapp(_currentUser!);
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
            buildAppBar(),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildAppBar() {
    return StreamBuilder<QuestionAnswersResponse>(
        stream: _personalDetailsCubit.questionAnswersResponseStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return DefaultAppBar(
              isCollapsable: true,
              title: snapshot.data!.screenDetails?.title ?? '',
              isPopUpMenuVisible: true,
            );
          } else {
            return const DefaultAppBar(
              isCollapsable: true,
              isPopUpMenuVisible: true,
            );
          }
        });
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
            stream: _personalDetailsCubit.questionAnswersResponseStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0, Dimens.padding_32, 0, Dimens.padding_32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildScreenDescription(snapshot.data!),
                        buildScreenQuestionList(),
                        buildWhatsAppCheckBox(),
                        buildSubmitButton(),
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

  Widget buildScreenDescription(
      QuestionAnswersResponse questionAnswersResponse) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text(
        questionAnswersResponse.screenDetails?.description ?? '',
        style: context.textTheme.bodyText1SemiBold
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
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
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
      _personalDetailsCubit.changeButtonStatus(ButtonStatus(isEnable: true));
    } else {
      _personalDetailsCubit.changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  Widget buildWhatsAppCheckBox() {
    return StreamBuilder<bool?>(
      stream: _personalDetailsCubit.isWhatsappSubscribed,
      builder: (context, subscribeWhatsapp) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_4, Dimens.padding_24, Dimens.padding_16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(Dimens.radius_4))),
                    value: subscribeWhatsapp.data ?? false,
                    onChanged: (v) {
                      if (v ?? false) {
                        _personalDetailsCubit.subscribeWhatsapp(_currentUser!);
                      } else {
                        _personalDetailsCubit
                            .unSubscribeWhatsapp(_currentUser!);
                      }
                      _personalDetailsCubit
                          .changeIsWhatsappSubscribed(v ?? false);
                    },
                  ),
                  Text('receive_message_on'.tr,
                      style: context.textTheme.bodyText1
                          ?.copyWith(color: AppColors.backgroundBlack)),
                  const SizedBox(width: Dimens.margin_8),
                  Image.asset('assets/images/whatsapp.png'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_24,
          Dimens.margin_16, Dimens.margin_16),
      child: RaisedRectButton(
        text: 'next'.tr,
        buttonStatus: _personalDetailsCubit.buttonStatus,
        onPressed: () {
          Helper.hideKeyBoard(context);
          _personalDetailsCubit.submitAnswer(_currentUser!);
        },
      ),
    );
  }
}
