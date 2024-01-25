import 'package:awign/workforce/auth/feature/education_details/cubit/education_details_cubit.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_events.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/new_default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_education_level_bottom_sheet/cubit/select_education_level_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_education_level_bottom_sheet/widget/select_education_level_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/cubit/select_working_domain_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/model/working_domain.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/widget/select_working_domain_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/stepper/stepper.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class EducationDetailsWidget extends StatefulWidget {
  const EducationDetailsWidget({Key? key}) : super(key: key);

  @override
  _EducationDetailsWidgetState createState() => _EducationDetailsWidgetState();
}

class _EducationDetailsWidgetState extends State<EducationDetailsWidget> {
  final _educationDetailsCubit = sl<EducationDetailsCubit>();
  final _selectEducationLevelCubit = sl<SelectEducationLevelCubit>();
  final _selectWorkingDomainCubit = sl<SelectWorkingDomainCubit>();
  final TextEditingController _selectedEducationLevelController =
      TextEditingController();
  UserData? _userData;

  @override
  void initState() {
    super.initState();
    setData();
    subscribeUIStatus();
  }

  void subscribeUIStatus() {
    _educationDetailsCubit.uiStatus.listen((uiStatus) async {
      if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
        Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
      }
      switch (uiStatus.event) {
        case Event.none:
          break;
        case Event.updated:
          LoggingData loggingData =
              LoggingData(event: LoggingEvents.signUpSuccessful);
          CaptureEventHelper.captureEvent(loggingData: loggingData);
          SPUtil? spUtil = await SPUtil.getInstance();
          _userData = spUtil?.getUserData();
          MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
          break;
      }
    });
  }

  Future<void> setData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _userData = spUtil?.getUserData();
  }

  @override
  void dispose() {
    _selectedEducationLevelController.dispose();
    super.dispose();
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
      backgroundColor: AppColors.backgroundWhite,
      body: Column(
        children: [
          NewDefaultAppBar(
            isBackButton: true,
            isActionButton: true,
            title: "Personal Details",
          ),
          buildBody(),
        ],
      ),
    );
  }

  Widget buildBody() {
    return Expanded(
      child: InternetSensitive(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: Dimens.margin_16),
                        child: CustomStepper(
                          icon1: "assets/images/done_step.svg",
                          hDivider1: AppColors.success300,
                          icon2: 'assets/images/done_step.svg',
                          hDivider2: AppColors.success300,
                          icon3: 'assets/images/ongoing_step.svg',
                          icon3TextColor: AppColors.success300,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.margin_16,
                            Dimens.margin_40, Dimens.margin_16, 0),
                        child: Text(
                          "Fill in the last few columns to start a new journey with us!",
                          style: context.textTheme.bodyText1SemiBold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(Dimens.margin_16,
                            Dimens.padding_32, Dimens.margin_16, 0),
                        child: TextFieldLabel(label: 'Qualification'),
                      ),
                      buildSelectEducationLevelTextField(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.margin_16,
                            Dimens.padding_32, Dimens.margin_16, 0),
                        child:
                            TextFieldLabel(label: 'have_you_worked_before'.tr),
                      ),
                      buildRadioButtons(),
                      buildSelectDomainVisibility(),
                    ],
                  ),
                ),
              ),
            ),
            buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget buildSelectEducationLevelTextField() {
    return StreamBuilder<String?>(
        stream: _educationDetailsCubit.selectedEducationLevel,
        builder: (context, selectedEducationLevel) {
          if (selectedEducationLevel.hasData) {
            _selectedEducationLevelController.text =
                selectedEducationLevel.data ?? '';
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
            child: MyInkWell(
              onTap: () {
                showSelectEducationLevelBottomSheet(
                  context,
                  (selectedEducationLevel) {
                    _educationDetailsCubit
                        .changeSelectedEducationLevel(selectedEducationLevel);
                  },
                );
              },
              child: Stack(
                children: [
                  TextField(
                    style: context.textTheme.bodyText1,
                    controller: _selectedEducationLevelController,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.fromLTRB(
                          Dimens.padding_16,
                          Dimens.padding_8,
                          Dimens.padding_16,
                          Dimens.padding_8),
                      fillColor: context.theme.textFieldBackgroundColor,
                      hintText: "Select Qualification",
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(Dimens.radius_8)),
                        borderSide:
                            BorderSide(color: AppColors.backgroundGrey400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                            Radius.circular(Dimens.radius_8)),
                        borderSide: BorderSide(
                            color: context.theme.textFieldBackgroundColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget buildRadioButtons() {
    return StreamBuilder<int?>(
      stream: _educationDetailsCubit.selectedWorkedBefore,
      builder: (context, selectedWorkedBefore) {
        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimens.padding_16, vertical: Dimens.padding_12),
          child: Container(
            decoration: BoxDecoration(
                color: context.theme.textFieldBackgroundColor,
                border: Border.all(color: AppColors.backgroundGrey400),
                borderRadius:
                    const BorderRadius.all(Radius.circular(Dimens.radius_8))),
            child: Column(
              children: [
                Row(
                  children: [
                    Radio<int?>(
                      value: 1,
                      groupValue: selectedWorkedBefore.data,
                      onChanged:
                          _educationDetailsCubit.changeSelectedWorkedBefore,
                    ),
                    Text('yes'.tr, style: Get.context?.textTheme.bodyText1)
                  ],
                ),
                Row(
                  children: [
                    Radio<int?>(
                      value: 2,
                      groupValue: selectedWorkedBefore.data,
                      onChanged:
                          _educationDetailsCubit.changeSelectedWorkedBefore,
                    ),
                    Text('no'.tr, style: Get.context?.textTheme.bodyText1)
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSelectDomainVisibility() {
    return StreamBuilder<int?>(
      stream: _educationDetailsCubit.selectedWorkedBefore,
      builder: (context, selectedWorkedBefore) {
        if (selectedWorkedBefore.data == 1) {
          return buildSelectWorkingDomainContainer();
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildSelectWorkingDomainContainer() {
    return StreamBuilder<List<WorkingDomain>?>(
      stream: _educationDetailsCubit.selectedWorkingDomainList,
      builder: (context, selectedWorkingDomainList) {
        if (selectedWorkingDomainList.hasData &&
            selectedWorkingDomainList.data!.isNotEmpty) {
          return buildWorkingDomainList(selectedWorkingDomainList.data);
        } else {
          return buildSelectYourDomainTextField();
        }
      },
    );
  }

  Widget buildSelectYourDomainTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.margin_16, Dimens.padding_32, Dimens.margin_16, 0),
          child: TextFieldLabel(label: 'Professional Domain'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: MyInkWell(
            onTap: () {
              showSelectWorkingDomainBottomSheet(
                context,
                (selectedWorkingDomainList) {
                  _educationDetailsCubit.changeSelectedWorkingDomainList(
                      selectedWorkingDomainList);
                },
              );
            },
            child: Stack(
              children: [
                TextField(
                  style: context.textTheme.bodyText1,
                  readOnly: true,
                  decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.fromLTRB(
                          Dimens.padding_16,
                          Dimens.padding_8,
                          Dimens.padding_16,
                          Dimens.padding_8),
                      fillColor: context.theme.textFieldBackgroundColor,
                      hintText: "Select Professional Domain",
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(Dimens.radius_8)),
                        borderSide:
                            BorderSide(color: AppColors.backgroundGrey400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                            Radius.circular(Dimens.radius_8)),
                        borderSide: BorderSide(
                            color: context.theme.textFieldBackgroundColor),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.margin_16,
                            Dimens.margin_8, Dimens.margin_12, Dimens.margin_8),
                        child:
                            SvgPicture.asset('assets/images/ic_language.svg'),
                      )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildWorkingDomainList(List<WorkingDomain>? workingDomainList) {
    var text = "";
    if (workingDomainList != null) {
      if (workingDomainList.length <= 2) {
        for (int i = 0; i < workingDomainList.length; i++) {
          text += workingDomainList[i].name;
          if (i + 1 < workingDomainList.length) {
            text += ", ";
          }
        }
      } else {
        for (int i = 0; i < 2; i++) {
          text += workingDomainList[i].name;
          if (i + 1 < 2) {
            text += ", ";
          }
        }
        text += " +${workingDomainList.length - 2}";
      }
    }
    return MyInkWell(
      onTap: () {
        showSelectWorkingDomainBottomSheet(
          context,
          (selectedWorkingDomainList) {
            _educationDetailsCubit
                .changeSelectedWorkingDomainList(selectedWorkingDomainList);
          },
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
                Dimens.margin_16, Dimens.padding_32, Dimens.margin_16, 0),
            child: TextFieldLabel(label: 'Professional Domain'),
          ),
          Container(
            width: double.infinity,
            height: Dimens.etHeight_48,
            // padding: const EdgeInsets.all(Dimens.padding_8),
            margin: const EdgeInsets.fromLTRB(
                Dimens.margin_16, Dimens.margin_12, Dimens.margin_16, 0),
            decoration: BoxDecoration(
                color: Get.theme.textFieldBackgroundColor,
                border: Border.all(color: AppColors.backgroundGrey400),
                borderRadius:
                    const BorderRadius.all(Radius.circular(Dimens.radius_8))),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(Dimens.padding_8),
                child: Text(
                  text,
                  style: context.textTheme.bodyText1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNextButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
            Dimens.padding_16, Dimens.padding_16),
        child: RaisedRectButton(
          text: 'submit'.tr,
          buttonStatus: _educationDetailsCubit.buttonStatus,
          onPressed: () {
            _educationDetailsCubit.updateProfile(_userData!);
          },
        ),
      ),
    );
  }
}
