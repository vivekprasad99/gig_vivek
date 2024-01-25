import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/core/data/firebase/remote_config/remote_config_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_add_bank_account_or_upi_bottom_sheet/widget/select_add_bank_account_or_upi_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/divider/v_divider.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/feature/manage_beneficiary/widget/bottom_sheet/max_beneficiary_bottom_sheet.dart';
import 'package:awign/workforce/payment/feature/withdrawal_verification/cubit/withdrawal_verification_cubit.dart';
import 'package:awign/workforce/payment/feature/withdrawal_verification/widget/bottom_sheet/widget/verify_existing_bank_account_bottom_sheet.dart';
import 'package:awign/workforce/payment/feature/withdrawal_verification/widget/dialog/beneficiary_verification_failed_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../auth/data/model/pan_details_entity.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_section_names.dart';

class WithdrawalVerificationWidget extends StatefulWidget {
  const WithdrawalVerificationWidget({Key? key}) : super(key: key);

  @override
  _WithdrawalVerificationWidgetState createState() =>
      _WithdrawalVerificationWidgetState();
}

class _WithdrawalVerificationWidgetState
    extends State<WithdrawalVerificationWidget> {
  final WithdrawalVerificationCubit _withdrawalVerificationCubit =
      sl<WithdrawalVerificationCubit>();
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();
  UserData? _currentUser;
  SPUtil? spUtil;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (_currentUser != null) {
      _withdrawalVerificationCubit.getPANDetails(_currentUser?.id ?? -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: 'verify_account'.tr),
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
        child: StreamBuilder<UIStatus>(
            stream: _withdrawalVerificationCubit.uiStatus,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isOnScreenLoading) {
                return AppCircularProgressIndicator();
              } else {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              Dimens.padding_16,
                              Dimens.padding_32,
                              Dimens.padding_16,
                              Dimens.padding_16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/images/ic_verify_icon.svg',
                              ),
                              const SizedBox(height: Dimens.padding_16),
                              Text('get_verified'.tr, style: Get.textTheme.bodyText1SemiBold
                                      ?.copyWith(color: AppColors.backgroundBlack)),
                              const SizedBox(height: Dimens.padding_8),
                              Text('verify_pan_and_bank_account'.tr,
                                  style: Get.textTheme.bodyText2
                                      ?.copyWith(color: AppColors.backgroundGrey800)),
                              const SizedBox(height: Dimens.padding_8),
                              Text('for_successful_verification_the_name_on_your_bank_account'.tr,
                                  style: Get.textTheme.bodyText2
                                      ?.copyWith(color: AppColors.warning400)),
                              const SizedBox(height: Dimens.padding_16),
                              HDivider(dividerColor: AppColors.backgroundGrey300),
                              const SizedBox(height: Dimens.padding_16),
                              Stack(
                                children: [
                                  StreamBuilder<KycDetails>(
                                      stream: _withdrawalVerificationCubit
                                          .kycDetails,
                                      builder: (context, snapshot) {
                                        return Column(
                                          children: [
                                            buildPANCardVerifyContainer(
                                                snapshot.data),
                                            const SizedBox(
                                                height: Dimens.padding_64),
                                            buildBankAccountVerifyContainer(
                                                snapshot.data),
                                          ],
                                        );
                                      }),
                                  Container(
                                    height: 64,
                                    margin: const EdgeInsets.fromLTRB(
                                        Dimens.padding_4,
                                        Dimens.padding_40,
                                        0,
                                        0),
                                    child: VDivider(
                                        dividerColor:
                                            AppColors.backgroundGrey400),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    buildContactSupportWidget(),
                  ],
                );
              }
            }),
      ),
    );
  }

  Widget buildPANCardVerifyContainer(KycDetails? kycDetails) {
    Color bgColor = AppColors.primaryMain;
    Color textColor = AppColors.backgroundWhite;
    bool isVerified = false;
    String maskPANNumber = '';
    if (kycDetails != null &&
        kycDetails.panVerificationStatus == PanStatus.verified) {
      _withdrawalVerificationCubit.getVerifiedBeneficiaries(
          _currentUser?.id ?? -1, kycDetails);
      bgColor = AppColors.backgroundGrey300;
      textColor = AppColors.backgroundGrey800;
      isVerified = true;
      maskPANNumber = StringUtils.maskString(kycDetails.panCardNumber, 2, 2);
    }
    return Row(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildIndexWidget(isVerified ? '✓' : '1', AppColors.primaryMain,
                  AppColors.backgroundWhite),
              const SizedBox(width: Dimens.padding_12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('pan_card'.tr, style: Get.textTheme.bodyText1SemiBold),
                  const SizedBox(height: Dimens.padding_8),
                  isVerified
                      ? Row(
                          children: [
                            Text(maskPANNumber,
                                style: Get.textTheme.bodyText2?.copyWith(
                                    color: AppColors.backgroundBlack)),
                            const SizedBox(width: Dimens.padding_8),
                            Container(
                              padding: const EdgeInsets.all(Dimens.padding_4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary2100,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(Dimens.radius_4)),
                                border: Border.all(
                                  color: AppColors.secondary2100,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/ic_verify.svg',
                                  ),
                                  const SizedBox(width: Dimens.padding_4),
                                  Text('verified'.tr,
                                      style: Get.textTheme.captionMedium
                                          ?.copyWith(
                                              color:
                                                  AppColors.backgroundBlack)),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
            ],
          ),
        ),
        buildVerifyPANButton(kycDetails),
      ],
    );
  }

  Widget buildBankAccountVerifyContainer(KycDetails? kycDetails) {
    Color bgColor = AppColors.primaryMain;
    Color textColor = AppColors.backgroundWhite;
    if (kycDetails != null &&
        kycDetails.panVerificationStatus != PanStatus.verified) {
      bgColor = AppColors.backgroundGrey300;
      textColor = AppColors.backgroundGrey800;
    }
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              buildIndexWidget('2', bgColor, textColor),
              const SizedBox(width: Dimens.padding_12),
              Text('bank_account'.tr, style: Get.textTheme.bodyText1),
            ],
          ),
        ),
        buildVerifyAccountButton(kycDetails),
      ],
    );
  }

  Widget buildIndexWidget(String text, Color bgColor, Color textColor) {
    return Container(
      width: Dimens.avatarWidth_24,
      height: Dimens.avatarHeight_24,
      decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: bgColor,
          ),
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_16))),
      child: Center(
        child: Text(
          text,
          style: Get.textTheme.captionBold?.copyWith(color: textColor),
        ),
      ),
    );
  }

  Widget buildVerifyPANButton(KycDetails? kycDetails) {
    if (kycDetails != null &&
        kycDetails.panVerificationStatus != PanStatus.verified) {
      return RaisedRectButton(
        text: 'verify'.tr,
        width: Dimens.btnWidth_90,
        height: Dimens.btnHeight_40,
        backgroundColor: AppColors.primaryMain,
        onPressed: () async {
          LoggingData loggingData = LoggingData(
              event: LoggingEvents.withdrawalJourneyVerify,
              pageName: LoggingPageNames.panDetails,
              sectionName: LoggingSectionNames.withdrawalJourney);
          CaptureEventHelper.captureEvent(loggingData: loggingData);
          dynamic data = await MRouter.pushNamed(MRouter.verifyPANWidget);
          if(data is DocumentDetailsData) {
            _withdrawalVerificationCubit.getPANDetails(_currentUser?.id ?? -1);
          }
        },
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildVerifyAccountButton(KycDetails? kycDetails) {
    return StreamBuilder<BeneficiaryResponse>(
      stream: _withdrawalVerificationCubit.beneficiaryResponse,
      builder: (context, snapshot) {
        Color bgColor = AppColors.primaryMain;
        bool isVerifiedBeneficiaryFound = false;
        if (kycDetails != null &&
            kycDetails.panVerificationStatus != PanStatus.verified) {
          bgColor = AppColors.backgroundGrey500;
        } else if (snapshot.hasData &&
            snapshot.data != null &&
            kycDetails != null) {
          bgColor = AppColors.primaryMain;
          isVerifiedBeneficiaryFound = _withdrawalVerificationCubit
              .isVerifiedBeneficiaryFound(snapshot.data!, kycDetails);
          if (isVerifiedBeneficiaryFound) {
            _goBack();
          }
        }
        if (!isVerifiedBeneficiaryFound) {
          return RaisedRectButton(
            text: 'verify'.tr,
            width: Dimens.btnWidth_90,
            height: Dimens.btnHeight_40,
            backgroundColor: bgColor,
            onPressed: () {
              _onBankAccountVerifyClicked();
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  _onBankAccountVerifyClicked() {
    if (!_withdrawalVerificationCubit
        .getUnVerifiedBeneficiaryList()
        .isNullOrEmpty) {
      _showVerifyExistingBankAccountBottomSheet();
    } else {
      _openAddBeneficiaryBottomSheet();
    }
  }

  _showVerifyExistingBankAccountBottomSheet() {
    showVerifyExistingBankAccountBottomSheet(
        Get.context!,
        _withdrawalVerificationCubit.getUnVerifiedBeneficiaryList()!,
        _onAddBankAccountTapped,
        _onBeneficiaryVerified,
        _onBeneficiaryVerificationFailed);
  }

  _onAddBankAccountTapped() {
    _openAddBeneficiaryBottomSheet();
  }

  _onBeneficiaryVerified() {
    MRouter.pop(true);
  }

  _goBack() async {
    await Future.delayed(const Duration(seconds: 1));
    MRouter.pop(true);
  }

  _onBeneficiaryVerificationFailed(onSelectedBeneficiary, failedMessage) {
    showBeneficiaryVerificationFailedDialog(Get.context!, null,
        onSelectedBeneficiary, failedMessage, _onDeleteAccountTap);
  }

  _onDeleteAccountTap(int? index, Beneficiary onSelectedBeneficiary) {
    _withdrawalVerificationCubit.deleteBeneficiary(onSelectedBeneficiary);
  }

  _openAddBeneficiaryBottomSheet() {
    if (_withdrawalVerificationCubit.noOfBeneficiary >= 7) {
      showMaxBeneficiaryBottomSheet(context);
    } else {
      showSelectAddBankAccountOrUPIBottomSheet(Get.context!,
          (onSelectOption) async {
        switch (onSelectOption) {
          case AddBeneficiaryOption.bankAccount:
            bool? isRefreshed =
                await MRouter.pushNamed(MRouter.addBankDetailsWidget);
            if (isRefreshed != null && isRefreshed) {
              _withdrawalVerificationCubit
                  .getPANDetails(_currentUser?.id ?? -1);
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
              _withdrawalVerificationCubit
                  .getPANDetails(_currentUser?.id ?? -1);
            }
            break;
        }
      });
    }
  }

  Widget buildContactSupportWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_24, Dimens.padding_16,
          Dimens.padding_24, Dimens.padding_32),
      child: MyInkWell(
        onTap: () {
          MRouter.pushNamed(MRouter.faqAndSupportWidget, arguments: {});
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/ic_headphone_blue.svg',
            ),
            const SizedBox(width: Dimens.padding_16),
            Text('contact_support'.tr,
                style: Get.textTheme.bodyText1SemiBold
                    ?.copyWith(color: AppColors.primaryMain)),
          ],
        ),
      ),
    );
  }
}
