import 'package:awign/workforce/core/data/firebase/remote_config/remote_config_helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/model/manage_beneficiary_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ManageBeneficiaryTile extends StatelessWidget {
  final int index;
  final Beneficiary beneficiary;
  final Function(int index, Beneficiary beneficiary)
      onShowBeneficiaryDetailsTapped;
  final Function(int index, Beneficiary beneficiary) onVerifyTapped;
  final Function(int index, Beneficiary beneficiary,
      ManageBeneficiaryOption menageBeneficiaryOption) onMoreOptionTapped;

  const ManageBeneficiaryTile({
    Key? key,
    required this.index,
    required this.beneficiary,
    required this.onShowBeneficiaryDetailsTapped,
    required this.onVerifyTapped,
    required this.onMoreOptionTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Dimens.padding_12),
        Row(
          children: [
            Expanded(
              child: MyInkWell(
                onTap: () {
                  onShowBeneficiaryDetailsTapped(index, beneficiary);
                },
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/ic_bank.svg',
                    ),
                    const SizedBox(width: Dimens.padding_16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildBankNameText(),
                        const SizedBox(height: Dimens.padding_4),
                        buildAccountNumberText(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            buildLoadingWidget(),
            buildVerifiedWidget(),
            buildRejectedWidget(),
            buildVerifyButton(),
            buildMenuWidget(),
          ],
        ),
        const SizedBox(height: Dimens.padding_12),
        HDivider(dividerColor: AppColors.backgroundGrey300),
      ],
    );
  }

  Widget buildBankNameText() {
    String bankName = '';
    if (beneficiary.vpa == null) {
      bankName = beneficiary.bankName ?? '';
    } else {
      bankName = beneficiary.name ?? '';
    }
    if(bankName != '')
    {
    return Text(bankName,
        style: Get.textTheme.bodyText2Medium
            ?.copyWith(color: AppColors.backgroundBlack));
    }else{
      return const SizedBox();
    }
  }

  Widget buildAccountNumberText() {
    String maskAccountNumber = '';
    if (beneficiary.vpa == null &&
        beneficiary.bankAccount != null &&
        beneficiary.bankAccount!.isNotEmpty) {
      maskAccountNumber = StringUtils.maskString(beneficiary.bankAccount, 4, 4);
    } else {
      maskAccountNumber = beneficiary.name ?? '';
    }
    return Text(maskAccountNumber,
        style:
            Get.textTheme.caption?.copyWith(color: AppColors.backgroundBlack));
  }

  Widget buildLoadingWidget() {
    if (beneficiary.isVerifyLoading) {
      return const Padding(
        padding: EdgeInsets.only(right: Dimens.padding_8),
        child: SizedBox(
            width: Dimens.pbWidth_16,
            height: Dimens.pbHeight_16,
            child: CircularProgressIndicator()),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildVerifiedWidget() {
    if (beneficiary.verificationStatus?.toLowerCase() ==
        BeneficiaryVerificationStatus.verified.value.toString().toLowerCase()) {
      return Container(
        padding: const EdgeInsets.all(Dimens.padding_4),
        decoration: BoxDecoration(
          color: AppColors.secondary2100,
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_4)),
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
                    ?.copyWith(color: AppColors.backgroundBlack)),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildRejectedWidget() {
    if (beneficiary.verificationStatus?.toLowerCase() ==
            BeneficiaryVerificationStatus.rejected.value
                .toString()
                .toLowerCase() ||
        beneficiary.verificationStatus?.toLowerCase() ==
            BeneficiaryVerificationStatus.panVerificationRejected.value
                .toString()
                .toLowerCase()) {
      return Container(
        padding: const EdgeInsets.all(Dimens.padding_4),
        decoration: BoxDecoration(
          color: AppColors.error200,
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_4)),
          border: Border.all(
            color: AppColors.error200,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/ic_alert.svg',
            ),
            const SizedBox(width: Dimens.padding_4),
            Text('failed'.tr,
                style: Get.textTheme.captionMedium
                    ?.copyWith(color: AppColors.error300)),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildVerifyButton() {
    if (RemoteConfigHelper.instance().isVerifyBeneficiaryConfigured &&
        beneficiary.verificationStatus?.toLowerCase() ==
            BeneficiaryVerificationStatus.unverified.value
                .toString()
                .toLowerCase()) {
      return CustomTextButton(
        width: Dimens.btnWidth_72,
        height: Dimens.btnHeight_40,
        text: 'verify'.tr,
        fontSize: Dimens.font_14,
        backgroundColor: AppColors.transparent,
        borderColor: AppColors.primaryMain,
        textColor: AppColors.primaryMain,
        onPressed: () {
          onVerifyTapped(index, beneficiary);
        },
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildMenuWidget() {
    List<PopupMenuEntry<ManageBeneficiaryOption>> items = [];
    if (beneficiary.verificationStatus?.toLowerCase() ==
            BeneficiaryVerificationStatus.rejected.value
                .toString()
                .toLowerCase() ||
        beneficiary.verificationStatus?.toLowerCase() ==
            BeneficiaryVerificationStatus.panVerificationRejected.value
                .toString()
                .toLowerCase()) {
      items.add(PopupMenuItem<ManageBeneficiaryOption>(
        value: ManageBeneficiaryOption.deleteAccount,
        child: Text('delete'.tr, style: Get.textTheme.bodyText2SemiBold),
      ));
    } else {
      if (beneficiary.active) {
        items.add(PopupMenuItem<ManageBeneficiaryOption>(
          value: ManageBeneficiaryOption.deactivateAccount,
          child: Text('deactivate_account'.tr,
              style: Get.textTheme.bodyText2SemiBold),
        ));
      } else {
        items.add(PopupMenuItem<ManageBeneficiaryOption>(
          value: ManageBeneficiaryOption.activate,
          child: Text('activate'.tr, style: Get.textTheme.bodyText2SemiBold),
        ));
      }
    }
    return PopupMenuButton<ManageBeneficiaryOption>(
        itemBuilder: (context) => items,
        child: buildOptionButton(),
        onSelected: (item) => selectedItem(item));
  }

  Widget buildOptionButton() {
    return Padding(
      padding: const EdgeInsets.only(left: Dimens.padding_16),
      child: SvgPicture.asset(
        'assets/images/ic_more_solid.svg',
      ),
    );
  }

  void selectedItem(item) {
    onMoreOptionTapped(index, beneficiary, item);
  }
}
