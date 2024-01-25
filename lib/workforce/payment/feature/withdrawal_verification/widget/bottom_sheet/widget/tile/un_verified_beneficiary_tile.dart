import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class UnVerifiedBeneficiaryTile extends StatelessWidget {
  final int index;
  final Beneficiary beneficiary;
  final Function(int index, Beneficiary beneficiary) onBeneficiarySelected;

  const UnVerifiedBeneficiaryTile({
    Key? key,
    required this.index,
    required this.beneficiary,
    required this.onBeneficiarySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyInkWell(
      onTap: () {
        onBeneficiarySelected(index, beneficiary);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
        padding: const EdgeInsets.all(Dimens.padding_16),
        decoration: BoxDecoration(
          color: beneficiary.isSelected ? AppColors.primary50 : AppColors.backgroundWhite,
          border: Border.all(color: beneficiary.isSelected ? AppColors.primaryMain : AppColors.backgroundGrey400),
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimens.radius_8),
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/ic_bank.svg',
            ),
            const SizedBox(width: Dimens.padding_16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildAccountNameText(),
                const SizedBox(height: Dimens.padding_4),
                buildAccountNumberText(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAccountNameText() {
    return Text(beneficiary.name ?? '',
        style: Get.textTheme.bodyText2Medium
            ?.copyWith(color: AppColors.backgroundBlack));
  }

  Widget buildAccountNumberText() {
    String maskAccountNumber = '';
    if(beneficiary.bankAccount != null && beneficiary.bankAccount!.isNotEmpty) {
      maskAccountNumber = StringUtils.maskString(beneficiary.bankAccount, 4, 4);
    }
    return Text(maskAccountNumber,
        style: Get.textTheme.caption
            ?.copyWith(color: AppColors.backgroundBlack));
  }
}
