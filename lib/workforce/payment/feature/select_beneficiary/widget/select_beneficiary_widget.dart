import 'dart:io';

import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/helper/file_picker_helper.dart';
import 'package:awign/workforce/core/data/firebase/remote_config/remote_config_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_add_bank_account_or_upi_bottom_sheet/widget/select_add_bank_account_or_upi_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_camera_or_gallery_bottom_sheet/widget/select_camera_or_gallery_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/application_question/application_question_response.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/model/document_verification_data.dart';
import 'package:awign/workforce/payment/feature/manage_beneficiary/widget/bottom_sheet/max_beneficiary_bottom_sheet.dart';
import 'package:awign/workforce/payment/feature/select_beneficiary/cubit/select_beneficiary_cubit.dart';
import 'package:awign/workforce/payment/feature/select_beneficiary/widget/tile/select_beneficiary_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_section_names.dart';

import '../../../../core/widget/buttons/my_ink_well.dart';

class SelectBeneficiaryWidget extends StatefulWidget {
  const SelectBeneficiaryWidget({Key? key}) : super(key: key);

  @override
  _SelectBeneficiaryWidgetState createState() =>
      _SelectBeneficiaryWidgetState();
}

class _SelectBeneficiaryWidgetState extends State<SelectBeneficiaryWidget> {
  final SelectBeneficiaryCubit _selectBeneficiaryCubit =
      sl<SelectBeneficiaryCubit>();
  UserData? _currentUser;
  SPUtil? spUtil;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void subscribeUIStatus() {
    _selectBeneficiaryCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.none:
            break;
        }
      },
    );
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    _selectBeneficiaryCubit.getBeneficiaries(_currentUser?.id ?? -1);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: 'select_beneficiary'.tr),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                    Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildBeneficiaryListWidget(),
                  ],
                ),
              ),
            ),
            buildBottomWidgets(),
          ],
        ),
      ),
    );
  }

  Widget buildBeneficiaryListWidget() {
    return StreamBuilder<List<Beneficiary>>(
      stream: _selectBeneficiaryCubit.beneficiaryList,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 0),
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    itemBuilder: (_, i) {
                      return SelectBeneficiaryTile(
                          index: i,
                          beneficiary: snapshot.data![i],
                          onSelectBeneficiaryTapped:
                              _onSelectBeneficiaryTapped);
                    },
                  ),
                ),
                MyInkWell(
                  onTap: () {
                    _addBeneficiaryTapped();
                  },
                  child: Text(
                    '+${'add_beneficiary'.tr}',
                    style: Get.textTheme.bodyLarge
                        ?.copyWith(color: AppColors.primaryMain),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return buildNoBeneficiaryContainer();
        } else {
          return AppCircularProgressIndicator();
        }
      },
    );
  }

  _onSelectBeneficiaryTapped(int index, Beneficiary beneficiary) {
    _selectBeneficiaryCubit.updateBeneficiaryList(index, beneficiary);
  }

  _showSelectCameraOrGalleryBottomSheet() {
    showSelectCameraOrGalleryBottomSheet(Get.context!, (onSelectOption) {
      if (onSelectOption == UploadFromOptionEntity.camera) {
        _captureImage();
      } else if (onSelectOption == UploadFromOptionEntity.gallery) {
        _pickMedia();
      }
    });
  }

  void _captureImage() async {
    ImageDetails imageDetails = ImageDetails(uploadLater: false);
    WidgetResult? cameraWidgetResult = await MRouter.pushNamed(
        MRouter.inAppCameraWidget,
        arguments: imageDetails);
    if (cameraWidgetResult != null &&
        cameraWidgetResult.event == Event.selected &&
        cameraWidgetResult.data != null) {
      DocumentVerificationData documentVerificationData =
          DocumentVerificationData(
              kycType: KYCType.idProofPAN,
              imageDetails: cameraWidgetResult.data);
      WidgetResult? widgetResult = await MRouter.pushNamed(
          MRouter.documentVerificationWidget,
          arguments: documentVerificationData);
      if (widgetResult != null && widgetResult.event == Event.updated) {
        _selectBeneficiaryCubit.getBeneficiaries(_currentUser?.id ?? -1);
      }
    }
  }

  void _pickMedia() {
    FilePickerHelper.pickMedia(
      SubType.image,
      null,
      (result) async {
        File file = File(result.files.single.path ?? '');
        ImageDetails imageDetailsResult = ImageDetails(
            originalFileName: result.names[0],
            originalFilePath: file.path,
            fileQuality: FileQuality.high);
        DocumentVerificationData documentVerificationData =
            DocumentVerificationData(
                kycType: KYCType.idProofPAN, imageDetails: imageDetailsResult);
        WidgetResult? widgetResult = await MRouter.pushNamed(
            MRouter.documentVerificationWidget,
            arguments: documentVerificationData);
        if (widgetResult != null && widgetResult.event == Event.updated) {
          _selectBeneficiaryCubit.getBeneficiaries(_currentUser?.id ?? -1);
        }
      },
    );
  }

  Widget buildNoBeneficiaryContainer() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CachedNetworkImage(
            width: Dimens.imageWidth_100,
            height: Dimens.imageHeight_100,
            imageUrl: Constants.noBeneficiaryImage,
            filterQuality: FilterQuality.high,
            errorWidget: (context, url, error) =>
                Container(color: AppColors.backgroundGrey600),
          ),
          const SizedBox(height: Dimens.padding_16),
          Text(
            'no_beneficiary_added'.tr,
            style: Get.textTheme.headline7SemiBold
                .copyWith(color: AppColors.backgroundBlack),
          ),
          const SizedBox(height: Dimens.padding_16),
          Text(
            'add_beneficiary_to_receive_payment'.tr,
            style: Get.textTheme.bodyText2
                ?.copyWith(color: AppColors.backgroundGrey800),
          ),
          const SizedBox(height: Dimens.padding_16),
          buildAddBeneficiaryButton1(),
        ],
      ),
    );
  }

  Widget buildAddBeneficiaryButton1() {
    return RaisedRectButton(
      text: 'add_beneficiary'.tr,
      width: Dimens.btnWidth_162,
      height: Dimens.btnHeight_40,
      onPressed: () {
        _addBeneficiaryTapped();
      },
    );
  }

  _addBeneficiaryTapped() {
    if (_currentUser?.userProfile?.kycDetails?.panVerificationStatus !=
        PanStatus.verified) {
      _showSelectCameraOrGalleryBottomSheet();
    } else if (_selectBeneficiaryCubit.noOfBeneficiary >= 7) {
      showMaxBeneficiaryBottomSheet(context);
    } else {
      _openAddBeneficiaryBottomSheet();
    }
    LoggingData loggingData = LoggingData(
        event: LoggingEvents.addBeneficiary,
        action: LoggingActions.clicked,
        pageName: LoggingPageNames.earnings,
        sectionName: LoggingSectionNames.manageBeneficiaries);
    CaptureEventHelper.captureEvent(loggingData: loggingData);
  }

  _openAddBeneficiaryBottomSheet() {
    showSelectAddBankAccountOrUPIBottomSheet(Get.context!,
        (onSelectOption) async {
      switch (onSelectOption) {
        case AddBeneficiaryOption.bankAccount:
          bool? isRefreshed =
              await MRouter.pushNamed(MRouter.addBankDetailsWidget);
          if (isRefreshed != null && isRefreshed) {
            _selectBeneficiaryCubit.getBeneficiaries(_currentUser?.id ?? -1);
          }
          break;
        case AddBeneficiaryOption.upi:
          if (RemoteConfigHelper.instance().isBeneficiaryUpiModeDisabled) {
            Helper.showErrorToast(
                'disabled_due_to_low_transfer_success_with_upi'.tr);
            return;
          }
          bool? isRefreshed = await MRouter.pushNamed(MRouter.addUPIWidget);
          if (isRefreshed != null && isRefreshed) {
            _selectBeneficiaryCubit.getBeneficiaries(_currentUser?.id ?? -1);
          }
          break;
      }
    });
  }

  Widget buildBottomWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
          Dimens.padding_16, Dimens.padding_32),
      child: Column(
        children: [
          buildProceedToWithdrawButton(),
        ],
      ),
    );
  }

  Widget buildProceedToWithdrawButton() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, Dimens.padding_16),
      child: RaisedRectButton(
        text: 'proceed_to_withdraw'.tr,
        onPressed: () {
          _verifyOtp();
        },
      ),
    );
  }

  _verifyOtp() {
    if (_selectBeneficiaryCubit.lastSelectedBeneficiary != null) {
      MRouter.pop(_selectBeneficiaryCubit.lastSelectedBeneficiary);
    } else {
      Helper.showErrorToast('select_beneficiary'.tr);
    }
  }
}
