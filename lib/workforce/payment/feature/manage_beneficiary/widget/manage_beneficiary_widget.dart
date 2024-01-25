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
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/application_question/application_question_response.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/model/document_verification_data.dart';
import 'package:awign/workforce/payment/data/model/manage_beneficiary_option.dart';
import 'package:awign/workforce/payment/feature/manage_beneficiary/cubit/manage_beneficiary_cubit.dart';
import 'package:awign/workforce/payment/feature/manage_beneficiary/widget/bottom_sheet/beneficiary_details_bottom_sheet.dart';
import 'package:awign/workforce/payment/feature/manage_beneficiary/widget/bottom_sheet/max_beneficiary_bottom_sheet.dart';
import 'package:awign/workforce/payment/feature/manage_beneficiary/widget/dialog/confirm_delete_beneficiary_dialog.dart';
import 'package:awign/workforce/payment/feature/manage_beneficiary/widget/tile/manage_beneficiary_tile.dart';
import 'package:awign/workforce/payment/feature/withdrawal_verification/widget/dialog/beneficiary_verification_failed_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_section_names.dart';

class ManageBeneficiaryWidget extends StatefulWidget {
  const ManageBeneficiaryWidget({Key? key}) : super(key: key);

  @override
  _ManageBeneficiaryWidgetState createState() =>
      _ManageBeneficiaryWidgetState();
}

class _ManageBeneficiaryWidgetState extends State<ManageBeneficiaryWidget> {
  final ManageBeneficiaryCubit _manageBeneficiaryCubit =
      sl<ManageBeneficiaryCubit>();
  UserData? _currentUser;
  SPUtil? spUtil;
  final TextEditingController _upiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  void subscribeUIStatus() {
    _manageBeneficiaryCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.rejected:
            Tuple3 tuple3 = uiStatus.data;
            _onBeneficiaryVerificationFailed(
                tuple3.item1, tuple3.item2, tuple3.item3);
            break;
        }
      },
    );
  }

  _onBeneficiaryVerificationFailed(
      int? index, onSelectedBeneficiary, failedMessage) {
    showBeneficiaryVerificationFailedDialog(Get.context!, index,
        onSelectedBeneficiary, failedMessage, _onDeleteAccountTap);
  }

  _onDeleteAccountTap(int? index, Beneficiary beneficiary) {
    if (index != null) {
      _manageBeneficiaryCubit.deleteBeneficiary(index, beneficiary);
    }
  }

  _showConfirmDeleteBeneficiaryDialog(int index, Beneficiary beneficiary) {
    showConfirmDeleteBeneficiaryDialog(
        Get.context!, index, beneficiary, _onOptionSelected);
  }

  _onOptionSelected(int index, Beneficiary beneficiary,
      ManageBeneficiaryOption manageBeneficiaryOption) {
    switch (manageBeneficiaryOption) {
      case ManageBeneficiaryOption.deleteAccount:
        _manageBeneficiaryCubit.deleteBeneficiary(index, beneficiary);
        break;
      default:
        break;
    }
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    _manageBeneficiaryCubit.getBeneficiaries(_currentUser?.id ?? -1);
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody() {
    return Column(
      children: [
        buildBeneficiaryListWidget(),
      ],
    );
  }

  Widget buildBeneficiaryListWidget() {
    return StreamBuilder<List<Beneficiary>>(
      stream: _manageBeneficiaryCubit.beneficiaryList,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          return Expanded(
            child: Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 0),
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    itemBuilder: (_, i) {
                      return ManageBeneficiaryTile(
                        index: i,
                        beneficiary: snapshot.data![i],
                        onShowBeneficiaryDetailsTapped:
                            _onShowBeneficiaryDetailsTapped,
                        onVerifyTapped: _onVerifyTapped,
                        onMoreOptionTapped: _onMoreOptionTapped,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: Dimens.padding_16,
                ),
                buildAddBeneficiaryButton2(),
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

  _onShowBeneficiaryDetailsTapped(int index, Beneficiary beneficiary) {
    if (beneficiary.bankAccount != null &&
        beneficiary.bankAccount!.isNotEmpty) {
      showBeneficiaryDetailsBottomSheet(context, beneficiary);
    } else if (beneficiary.paymentMode == BeneficiaryType.upi.value &&
        RemoteConfigHelper.instance().isBeneficiaryUpiModeDisabled) {
      Helper.showErrorToast('disabled_due_to_low_transfer_success_with_upi'.tr);
      return;
    }
  }

  _onVerifyTapped(int index, Beneficiary beneficiary) {
    if (beneficiary.verificationStatus?.toLowerCase() !=
        BeneficiaryVerificationStatus.verified.value.toString().toLowerCase()) {
      _showSelectCameraOrGalleryBottomSheet();
    } else {
      _manageBeneficiaryCubit.verifyBeneficiary(index, beneficiary);
      LoggingData loggingData = LoggingData(
          event: LoggingEvents.verify,
          action: LoggingActions.clicked,
          pageName: LoggingPageNames.earnings,
          sectionName: LoggingSectionNames.manageBeneficiaries);
      CaptureEventHelper.captureEvent(loggingData: loggingData);
    }
  }

  _onMoreOptionTapped(int index, Beneficiary beneficiary,
      ManageBeneficiaryOption manageBeneficiaryOption) {
    switch (manageBeneficiaryOption) {
      case ManageBeneficiaryOption.activate:
        _manageBeneficiaryCubit.updateBeneficiaryActiveStatus(
            index, beneficiary, true);
        LoggingData loggingData = LoggingData(
            event: LoggingEvents.activate,
            action: LoggingActions.clicked,
            pageName: LoggingPageNames.earnings,
            sectionName: LoggingSectionNames.manageBeneficiaries);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        break;
      case ManageBeneficiaryOption.deactivateAccount:
        _manageBeneficiaryCubit.updateBeneficiaryActiveStatus(
            index, beneficiary, false);
        LoggingData loggingData = LoggingData(
            event: LoggingEvents.deactivate,
            action: LoggingActions.clicked,
            pageName: LoggingPageNames.earnings,
            sectionName: LoggingSectionNames.manageBeneficiaries);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        break;
      case ManageBeneficiaryOption.deleteAccount:
        _showConfirmDeleteBeneficiaryDialog(index, beneficiary);
        break;
    }
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
        _manageBeneficiaryCubit.getBeneficiaries(_currentUser?.id ?? -1);
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
          _manageBeneficiaryCubit.getBeneficiaries(_currentUser?.id ?? -1);
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
    } else if (_manageBeneficiaryCubit.noOfBeneficiary >= 7) {
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
            _manageBeneficiaryCubit.getBeneficiaries(_currentUser?.id ?? -1);
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
            _manageBeneficiaryCubit.getBeneficiaries(_currentUser?.id ?? -1);
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
          buildAddBeneficiaryButton2(),
          const SizedBox(height: Dimens.padding_16),
          const SizedBox(height: Dimens.padding_16),
        ],
      ),
    );
  }

  Widget buildNoteWidget() {
    return Container(
      padding: const EdgeInsets.all(Dimens.padding_12),
      decoration: BoxDecoration(
        color: AppColors.warning100,
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_16)),
        border: Border.all(
          color: AppColors.warning200,
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: context.textTheme.bodyText1
              ?.copyWith(color: AppColors.backgroundGrey700),
          children: <TextSpan>[
            TextSpan(
              text: 'note'.tr,
              style: Get.textTheme.bodyText2SemiBold,
            ),
            TextSpan(
              text: 'make_sure_your_back_account_has_the'.tr,
              style: Get.textTheme.bodyText2,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddBeneficiaryButton2() {
    return MyInkWell(
      onTap: () {
        _addBeneficiaryTapped();
      },
      child: Row(
        children: [
          const Icon(
            Icons.add_circle_outline,
            color: AppColors.primaryMain,
            size: 16,
          ),
          const SizedBox(width: Dimens.padding_8),
          Text(
            'add_beneficiary'.tr,
            style: Get.textTheme.bodyMedium
                ?.copyWith(color: AppColors.primaryMain),
          ),
        ],
      ),
    );
  }
}
