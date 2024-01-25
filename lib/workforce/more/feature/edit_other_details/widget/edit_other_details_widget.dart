import 'package:awign/workforce/auth/data/model/profile_attributes_and_application_questions.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/profile_attributes.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/edit_other_details/cubit/edit_other_details_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';

class EditOtherDetailsWidget extends StatefulWidget {
  late ProfileAttributesAndApplicationQuestions
      profileAttributesAndApplicationQuestions;

  EditOtherDetailsWidget(this.profileAttributesAndApplicationQuestions,
      {Key? key})
      : super(key: key);

  @override
  _EditOtherDetailsWidgetState createState() => _EditOtherDetailsWidgetState();
}

class _EditOtherDetailsWidgetState extends State<EditOtherDetailsWidget> {
  final _editOtherDetailsCubit = sl<EditOtherDetailsCubit>();
  UserData? _curUser;
  // bool isOtherDetailsUpdated = false;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _curUser = spUtil?.getUserData();
  }

  void subscribeUIStatus() {
    _editOtherDetailsCubit.uiStatus.listen(
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
          case Event.created:
            List<ProfileAttributes> profileAttributes = uiStatus.data;
            List<ProfileAttributes> profileAttributesList = widget
                .profileAttributesAndApplicationQuestions.userProfileAttributes;
            profileAttributesList.addAll(profileAttributes);
            widget.profileAttributesAndApplicationQuestions
                .userProfileAttributes = profileAttributesList;
            // isOtherDetailsUpdated = true;
            LoggingData loggingData =
                LoggingData(event: LoggingEvents.otherDetailsFilled);
            CaptureEventHelper.captureEvent(loggingData: loggingData);
            setState(() {});
            break;
          case Event.updated:
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
      onWillPop: () {
        MRouter.globalNavigatorKey.currentState?.popUntil((route) {
          if (route.settings.name == MRouter.myProfileWidget) {
            (route.settings.arguments as Map)[Constants.doRefresh] = true;
            return true;
          } else {
            return false;
          }
        });
        return Future.value(true);
      },
      child: ScreenTypeLayout(
        mobile: buildMobileUI(),
        desktop: const DesktopComingSoonWidget(),
      ),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: 'edit_other_details'.tr),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      padding: EdgeInsets.only(
          bottom: defaultTargetPlatform == TargetPlatform.iOS
              ? Dimens.padding_32
              : 0),
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: StreamBuilder<UIStatus>(
        stream: _editOtherDetailsCubit.uiStatus,
        builder: (context, uiStatus) {
          if (uiStatus.hasData && uiStatus.data!.isOnScreenLoading) {
            return AppCircularProgressIndicator();
          } else {
            return InternetSensitive(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0, Dimens.padding_24, 0, Dimens.padding_16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildOtherQuestionList(),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildOtherQuestionList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        itemCount:
            widget.profileAttributesAndApplicationQuestions.questions.length,
        itemBuilder: (_, i) {
          Question? question =
              widget.profileAttributesAndApplicationQuestions.questions[i];
          if (question.configuration?.attributeName == null) {
            return const SizedBox();
          } else {
            ProfileAttributes? profileAttributes =
                ProfileAttributes.getProfileAttribute(
                    question.configuration?.attributeName,
                    widget.profileAttributesAndApplicationQuestions
                        .userProfileAttributes);
            String answer =
                (profileAttributes?.attributeValue ?? '').toLowerCase();
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Dimens.padding_8, 0, Dimens.padding_8, 0),
                    child: TextFieldLabel(
                        label: question.configuration?.questionText ?? ''),
                  ),
                  Row(
                    children: [
                      Row(
                        children: [
                          Radio<String?>(
                            value: Constants.yes.toLowerCase(),
                            groupValue: answer,
                            onChanged: (v) {
                              profileAttributes?.attributeValue = Constants.yes;
                              int? index =
                                  ProfileAttributes.getProfileAttributeIndex(
                                      question.configuration?.attributeName,
                                      widget
                                          .profileAttributesAndApplicationQuestions
                                          .userProfileAttributes);
                              if (index != null) {
                                List<ProfileAttributes> profileAttributesList =
                                    widget
                                        .profileAttributesAndApplicationQuestions
                                        .userProfileAttributes;
                                profileAttributesList[index] =
                                    profileAttributes!;
                                widget.profileAttributesAndApplicationQuestions
                                        .userProfileAttributes =
                                    profileAttributesList;
                                // isOtherDetailsUpdated = true;
                                setState(() {});
                                _editOtherDetailsCubit.updateProfileAttribute(
                                    _curUser!.userProfile!.userId,
                                    profileAttributes);
                              } else {
                                _editOtherDetailsCubit.createProfileAttribute(
                                    _curUser!.userProfile!.userId,
                                    question.configuration?.attributeName,
                                    Constants.yes);
                              }
                            },
                          ),
                          Text('yes'.tr, style: context.textTheme.bodyText1)
                        ],
                      ),
                      const SizedBox(width: Dimens.padding_40),
                      Row(
                        children: [
                          Radio<String?>(
                            value: Constants.no.toLowerCase(),
                            groupValue: answer,
                            onChanged: (v) {
                              profileAttributes?.attributeValue = Constants.no;
                              int? index =
                                  ProfileAttributes.getProfileAttributeIndex(
                                      question.configuration?.attributeName,
                                      widget
                                          .profileAttributesAndApplicationQuestions
                                          .userProfileAttributes);
                              if (index != null) {
                                List<ProfileAttributes> profileAttributesList =
                                    widget
                                        .profileAttributesAndApplicationQuestions
                                        .userProfileAttributes;
                                profileAttributesList[index] =
                                    profileAttributes!;
                                widget.profileAttributesAndApplicationQuestions
                                        .userProfileAttributes =
                                    profileAttributesList;
                                // isOtherDetailsUpdated = true;
                                setState(() {});
                                _editOtherDetailsCubit.updateProfileAttribute(
                                    _curUser!.userProfile!.userId!,
                                    profileAttributes);
                              } else {
                                _editOtherDetailsCubit.createProfileAttribute(
                                    _curUser!.userProfile!.userId!,
                                    question.configuration?.attributeName,
                                    Constants.no);
                              }
                            },
                          ),
                          Text('no'.tr, style: context.textTheme.bodyText1)
                        ],
                      ),
                    ],
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
