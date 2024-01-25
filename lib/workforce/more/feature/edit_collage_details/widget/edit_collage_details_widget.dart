import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_collage_bottom_sheet/widget/select_collage_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/dialog/select_end_year/widget/select_end_year_dialog.dart';
import 'package:awign/workforce/core/widget/dialog/select_start_year/widget/select_start_year_dialog.dart';
import 'package:awign/workforce/core/widget/dialog/select_stream_dialog/widget/select_stream_dialog.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/edit_collage_details/cubit/edit_collage_details_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';

class EditCollageDetailsWidget extends StatefulWidget {
  late UserProfile userProfile;
  EditCollageDetailsWidget(this.userProfile, {Key? key}) : super(key: key);

  @override
  _EditCollageDetailsWidgetState createState() =>
      _EditCollageDetailsWidgetState();
}

class _EditCollageDetailsWidgetState extends State<EditCollageDetailsWidget> {
  final _editCollageDetailsCubit = sl<EditCollageDetailsCubit>();
  final TextEditingController _collageNameController = TextEditingController();
  final TextEditingController _otherStreamController = TextEditingController();
  final TextEditingController _fieldOfStudyController = TextEditingController();
  final TextEditingController _startYearController = TextEditingController();
  final TextEditingController _endYearController = TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    setCollegeDetails();
  }

  void subscribeUIStatus() {
    _editCollageDetailsCubit.uiStatus.listen(
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
          case Event.updated:
            LoggingData loggingData =
                LoggingData(event: LoggingEvents.collegeDetailsFilled);
            CaptureEventHelper.captureEvent(loggingData: loggingData);
            MRouter.globalNavigatorKey.currentState?.popUntil((route) {
              if (route.settings.name == MRouter.myProfileWidget) {
                (route.settings.arguments as Map)[Constants.doRefresh] = true;
                return true;
              } else {
                return false;
              }
            });
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  void setCollegeDetails() {
    _collageNameController.text =
        widget.userProfile.education?.collegeName ?? '';
    if ((widget.userProfile.education?.collegeName ?? '').isNotEmpty) {
      _editCollageDetailsCubit
          .changeCollageName(widget.userProfile.education?.collegeName!);
    }
    _fieldOfStudyController.text =
        widget.userProfile.education?.fieldOfStudy ?? '';
    if ((widget.userProfile.education?.fieldOfStudy ?? '').isNotEmpty) {
      _editCollageDetailsCubit
          .changeFieldOfStudy(widget.userProfile.education?.fieldOfStudy!);
    }
    _startYearController.text = widget.userProfile.education?.fromYear ?? '';
    if ((widget.userProfile.education?.fromYear ?? '').isNotEmpty) {
      _editCollageDetailsCubit
          .changeStartYear(widget.userProfile.education?.fromYear!);
    }
    _endYearController.text = widget.userProfile.education?.toYear ?? '';
    if ((widget.userProfile.education?.toYear ?? '').isNotEmpty) {
      _editCollageDetailsCubit
          .changeEndYear(widget.userProfile.education?.toYear!);
    }
  }

  @override
  void dispose() {
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
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: 'edit_profile'.tr),
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
          stream: _editCollageDetailsCubit.uiStatus,
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              Dimens.padding_24, 0, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'collage'.tr),
                        ),
                        buildCollageNameTextField(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.padding_24, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'field_of_study'.tr),
                        ),
                        buildSelectFieldOfStudyTextField(),
                        buildOtherStreamTextField(),
                        buildStartYearEndYearContainer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.margin_16, Dimens.padding_24, 0),
                          child: HDivider(),
                        ),
                        buildSaveChangesButton(),
                      ],
                    ),
                  ),
                ),
              );
            }
          }),
    );
  }

  Widget buildCollageNameTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_16, Dimens.padding_24, 0),
      child: MyInkWell(
        onTap: () {
          showSelectCollageBottomSheet(
            context,
            (selectedCollage) {
              _collageNameController.text = selectedCollage?.collegeName ?? '';
              _editCollageDetailsCubit
                  .changeCollageName(selectedCollage?.collegeName);
            },
          );
        },
        child: TextField(
          enabled: false,
          style: context.textTheme.bodyText1,
          onChanged: _editCollageDetailsCubit.changeCollageName,
          controller: _collageNameController,
          keyboardType: TextInputType.name,
          maxLines: 1,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: 'collage_name'.tr,
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: context.theme.textFieldBackgroundColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: context.theme.textFieldBackgroundColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: context.theme.textFieldBackgroundColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSelectFieldOfStudyTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_16, Dimens.padding_24, 0),
      child: MyInkWell(
        onTap: () {
          showSelectStreamDialog(context, (selectedStream, isOtherStream) {
            if (selectedStream != null && selectedStream.isNotEmpty) {
              _fieldOfStudyController.text = selectedStream;
              _editCollageDetailsCubit.changeFieldOfStudy(selectedStream);
              _editCollageDetailsCubit.changeIsOtherStream(isOtherStream);
            }
          });
        },
        child: TextField(
          enabled: false,
          style: context.textTheme.bodyText1,
          onChanged: _editCollageDetailsCubit.changeFieldOfStudy,
          controller: _fieldOfStudyController,
          keyboardType: TextInputType.name,
          maxLines: 1,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: 'select_field_of_study'.tr,
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: context.theme.textFieldBackgroundColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: context.theme.textFieldBackgroundColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: context.theme.textFieldBackgroundColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOtherStreamTextField() {
    return StreamBuilder<bool>(
        stream: _editCollageDetailsCubit.isOtherStream,
        builder: (context, isOtherStream) {
          if (isOtherStream.hasData &&
              isOtherStream.data != null &&
              isOtherStream.data!) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                      Dimens.margin_16, Dimens.padding_24, 0),
                  child: TextFieldLabel(label: 'other_stream'.tr),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                      Dimens.padding_24, Dimens.padding_24, 0),
                  child: TextField(
                    style: context.textTheme.bodyText1,
                    onChanged: _editCollageDetailsCubit.changeOtherStream,
                    controller: _otherStreamController,
                    keyboardType: TextInputType.name,
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.fromLTRB(
                          Dimens.padding_16,
                          Dimens.padding_8,
                          Dimens.padding_16,
                          Dimens.padding_8),
                      fillColor: context.theme.textFieldBackgroundColor,
                      hintText: 'other_stream'.tr,
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: context.theme.textFieldBackgroundColor),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: context.theme.textFieldBackgroundColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: context.theme.textFieldBackgroundColor),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildStartYearEndYearContainer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: Row(
        children: [
          Expanded(child: buildStartYearTextFieldContainer()),
          const SizedBox(width: Dimens.padding_24),
          Expanded(child: buildEndYearTextFieldContainer()),
        ],
      ),
    );
  }

  Widget buildStartYearTextFieldContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldLabel(label: 'start_year'.tr),
        const SizedBox(height: Dimens.padding_8),
        buildStartYearTextField(),
      ],
    );
  }

  Widget buildStartYearTextField() {
    return MyInkWell(
      onTap: () {
        showSelectStartYearDialog(context, (selectedYear) {
          _startYearController.text = selectedYear.toString();
          _editCollageDetailsCubit.changeStartYear(selectedYear.toString());
        });
      },
      child: TextField(
        enabled: false,
        style: context.textTheme.bodyText1,
        onChanged: _editCollageDetailsCubit.changeStartYear,
        controller: _startYearController,
        keyboardType: TextInputType.name,
        maxLines: 1,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          filled: true,
          contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
              Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
          fillColor: context.theme.textFieldBackgroundColor,
          hintText: '',
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: context.theme.textFieldBackgroundColor),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: context.theme.textFieldBackgroundColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: context.theme.textFieldBackgroundColor),
          ),
        ),
      ),
    );
  }

  Widget buildEndYearTextFieldContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldLabel(label: 'end_year'.tr),
        const SizedBox(height: Dimens.padding_8),
        buildEndYearTextField(),
      ],
    );
  }

  Widget buildEndYearTextField() {
    return MyInkWell(
      onTap: () {
        showSelectEndYearDialog(context, (selectedYear) {
          _endYearController.text = selectedYear.toString();
          _editCollageDetailsCubit.changeEndYear(selectedYear.toString());
        });
      },
      child: TextField(
        enabled: false,
        style: context.textTheme.bodyText1,
        onChanged: _editCollageDetailsCubit.changeEndYear,
        controller: _endYearController,
        keyboardType: TextInputType.name,
        maxLines: 1,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          filled: true,
          contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
              Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
          fillColor: context.theme.textFieldBackgroundColor,
          hintText: '',
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: context.theme.textFieldBackgroundColor),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: context.theme.textFieldBackgroundColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: context.theme.textFieldBackgroundColor),
          ),
        ),
      ),
    );
  }

  Widget buildSaveChangesButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_16, Dimens.padding_24, 0),
      child: RaisedRectButton(
        text: 'save_changes'.tr,
        onPressed: () {
          _editCollageDetailsCubit.createOrUpdateEducation(
              widget.userProfile.userId, widget.userProfile.education);
        },
      ),
    );
  }
}
