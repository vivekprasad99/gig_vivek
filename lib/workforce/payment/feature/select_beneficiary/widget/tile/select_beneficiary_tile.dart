import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SelectBeneficiaryTile extends StatelessWidget {
  final int index;
  final Beneficiary beneficiary;
  final Function(int index, Beneficiary beneficiary) onSelectBeneficiaryTapped;

  const SelectBeneficiaryTile({
    Key? key,
    required this.index,
    required this.beneficiary,
    required this.onSelectBeneficiaryTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Dimens.padding_12),
        Row(
          children: [
            MyInkWell(
              onTap: () {
                onSelectBeneficiaryTapped(index, beneficiary);
              },
              child: Row(
                children: [
                  SizedBox(
                    width: Dimens.radioButtonWidth,
                    height: Dimens.radioButtonHeight,
                    child: Radio<int?>(
                        value: 1,
                        groupValue: beneficiary.isSelected ? 1 : 0,
                        onChanged: (v) {}),
                  ),
                  const SizedBox(width: Dimens.padding_16),
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
}
