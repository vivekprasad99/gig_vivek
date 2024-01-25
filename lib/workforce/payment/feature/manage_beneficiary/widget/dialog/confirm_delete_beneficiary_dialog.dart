import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/dialog/custom_dialog.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/model/manage_beneficiary_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

void showConfirmDeleteBeneficiaryDialog(
    BuildContext context,
    int index,
    Beneficiary beneficiary,
    Function(int, Beneficiary, ManageBeneficiaryOption) onOptionSelected) {
  showDialog<bool>(
    context: context,
    builder: (_) => CustomDialog(
      child: ConfirmDeleteBeneficiaryDialog(index, beneficiary, onOptionSelected),
    ),
  );
}

class ConfirmDeleteBeneficiaryDialog extends StatelessWidget {
  final int index;
  final Beneficiary beneficiary;
  final Function(int, Beneficiary, ManageBeneficiaryOption) onOptionSelected;

  const ConfirmDeleteBeneficiaryDialog(
      this.index, this.beneficiary, this.onOptionSelected,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_32)),
      ),
      child: InternetSensitive(
        child: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimens.padding_8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildTitle(context),
              buildCloseIcon(),
            ],
          ),
          buildSubTitle(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildDeleteButton(),
              const SizedBox(width: Dimens.padding_16),
              buildOkayButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Dimens.padding_16),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/ic_alert.svg',
            color: AppColors.error400,
          ),
          const SizedBox(width: Dimens.padding_8),
          Text('verification_failed'.tr,
              style: context.textTheme.headline7Bold),
        ],
      ),
    );
  }

  Widget buildSubTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: Dimens.padding_16),
      child: Text('your_account_could_not_be_verified'.tr,
          style: Get.textTheme.headline7Bold),
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: const Padding(
          padding: EdgeInsets.all(Dimens.padding_16),
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildDeleteButton() {
    return RaisedRectButton(
      text: 'delete'.tr,
      width: Dimens.btnWidth_162,
      height: Dimens.btnHeight_40,
      onPressed: () {
        MRouter.pop(null);
        onOptionSelected(
            index, beneficiary, ManageBeneficiaryOption.deleteAccount);
      },
    );
  }

  Widget buildOkayButton() {
    return RaisedRectButton(
      text: 'okay'.tr,
      width: Dimens.btnWidth_162,
      height: Dimens.btnHeight_40,
      onPressed: () {
        MRouter.pop(null);
      },
    );
  }
}
