import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_education_level_bottom_sheet/widget/select_education_level_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/model/working_domain.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/widget/select_working_domain_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/widget/tile/selected_working_domain_tile.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/edit_professional_details/cubit/edit_professional_details_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:responsive_builder/responsive_builder.dart';

class EditProfessionalDetailsWidget extends StatefulWidget {
  late UserProfile userProfile;
  EditProfessionalDetailsWidget(this.userProfile, {Key? key}) : super(key: key);

  @override
  _EditProfessionalDetailsWidgetState createState() =>
      _EditProfessionalDetailsWidgetState();
}

class _EditProfessionalDetailsWidgetState
    extends State<EditProfessionalDetailsWidget> {
  final _editProfessionalDetailsCubit = sl<EditProfessionalDetailsCubit>();
  final TextEditingController _qualificationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    _qualificationController.text = widget.userProfile.educationLevel ?? '';
    _editProfessionalDetailsCubit
        .changeSelectedEducationLevel(widget.userProfile.educationLevel ?? '');
    _editProfessionalDetailsCubit.updateSelectedWorkingDomainList(
        widget.userProfile.professionalExperiences ?? []);
  }

  void subscribeUIStatus() {
    _editProfessionalDetailsCubit.uiStatus.listen(
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
          case Event.updated:
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
            DefaultAppBar(
                isCollapsable: true, title: 'edit_professional_details'.tr),
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
          stream: _editProfessionalDetailsCubit.uiStatus,
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
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.margin_16, Dimens.padding_24, 0),
                          child: Text('education_and_professional_details'.tr,
                              style: context.textTheme.headline6),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.margin_16, Dimens.padding_24, 0),
                          child: TextFieldLabel(label: 'qualification'.tr),
                        ),
                        buildSelectQualificationTextField(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                              Dimens.margin_16, Dimens.padding_24, 0),
                          child:
                              TextFieldLabel(label: 'professional_domain'.tr),
                        ),
                        buildSelectWorkingDomainContainer(),
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

  Widget buildSelectQualificationTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_16, Dimens.padding_24, 0),
      child: MyInkWell(
        onTap: () {
          showSelectEducationLevelBottomSheet(
            context,
            (selectedEducationLevel) {
              _qualificationController.text = selectedEducationLevel ?? '';
              _editProfessionalDetailsCubit
                  .changeSelectedEducationLevel(selectedEducationLevel ?? '');
            },
          );
        },
        child: Stack(
          children: [
            TextField(
              style: context.textTheme.bodyText1,
              controller: _qualificationController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                    Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
                fillColor: context.theme.textFieldBackgroundColor,
                hintText: 'select_qualification'.tr,
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.theme.textFieldBackgroundColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.theme.textFieldBackgroundColor),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(Dimens.padding_12),
                child: Icon(Icons.arrow_drop_down),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSelectWorkingDomainContainer() {
    return StreamBuilder<List<WorkingDomain>?>(
      stream: _editProfessionalDetailsCubit.selectedWorkingDomainList,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_16, Dimens.padding_24, 0),
      child: MyInkWell(
        onTap: () {
          showSelectWorkingDomainBottomSheet(
            context,
            (selectedWorkingDomainList) {
              _editProfessionalDetailsCubit
                  .changeSelectedWorkingDomainList(selectedWorkingDomainList);
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
                contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                    Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
                fillColor: context.theme.textFieldBackgroundColor,
                hintText: 'select_domain'.tr,
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.theme.textFieldBackgroundColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.theme.textFieldBackgroundColor),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(Dimens.padding_12),
                child: Icon(Icons.arrow_drop_down),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildWorkingDomainList(List<WorkingDomain>? workingDomainList) {
    return MyInkWell(
      onTap: () {
        showSelectWorkingDomainBottomSheet(
          context,
          (selectedWorkingDomainList) {
            _editProfessionalDetailsCubit
                .changeSelectedWorkingDomainList(selectedWorkingDomainList);
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(Dimens.padding_8),
        margin: const EdgeInsets.fromLTRB(
            Dimens.margin_24, Dimens.margin_8, Dimens.margin_24, 0),
        color: context.theme.textFieldBackgroundColor,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 0),
          itemCount: workingDomainList?.length,
          itemBuilder: (_, i) {
            return SelectedWorkingDomainTile(
              index: i,
              workingDomain: workingDomainList![i],
            );
          },
        ),
      ),
    );
  }

  Widget buildSaveChangesButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: RaisedRectButton(
        text: 'save_changes'.tr,
        onPressed: () {
          _editProfessionalDetailsCubit.updateProfessionalDetails(
              widget.userProfile.userId!, widget.userProfile);
        },
      ),
    );
  }
}
