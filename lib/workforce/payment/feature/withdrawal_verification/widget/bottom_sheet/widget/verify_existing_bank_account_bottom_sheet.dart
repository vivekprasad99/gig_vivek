import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/feature/withdrawal_verification/widget/bottom_sheet/cubit/verify_existing_bank_account_cubit.dart';
import 'package:awign/workforce/payment/feature/withdrawal_verification/widget/bottom_sheet/widget/tile/un_verified_beneficiary_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showVerifyExistingBankAccountBottomSheet(
    BuildContext context,
    List<Beneficiary> beneficiaryList,
    Function() onAddBankAccountTapped,
    Function() onBeneficiaryVerified,
    Function(Beneficiary, String) onBeneficiaryVerificationFailed) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return VerifyExistingBankAccountWidget(
                beneficiaryList,
                onAddBankAccountTapped,
                onBeneficiaryVerified,
                onBeneficiaryVerificationFailed);
          },
        ),
      );
    },
  );
}

class VerifyExistingBankAccountWidget extends StatefulWidget {
  final List<Beneficiary> beneficiaryList;
  final Function() onAddBankAccountTapped;
  final Function() onBeneficiaryVerified;
  final Function(Beneficiary, String) onBeneficiaryVerificationFailed;

  const VerifyExistingBankAccountWidget(
      this.beneficiaryList,
      this.onAddBankAccountTapped,
      this.onBeneficiaryVerified,
      this.onBeneficiaryVerificationFailed,
      {Key? key})
      : super(key: key);

  @override
  State<VerifyExistingBankAccountWidget> createState() =>
      VerifyExistingBankAccountWidgetState();
}

class VerifyExistingBankAccountWidgetState
    extends State<VerifyExistingBankAccountWidget> {
  final VerifyExistingBankAccountCubit _verifyExistingBankAccountCubit =
      sl<VerifyExistingBankAccountCubit>();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    _verifyExistingBankAccountCubit
        .changeBeneficiaryList(widget.beneficiaryList);
    if (widget.beneficiaryList.isNotEmpty) {
      _verifyExistingBankAccountCubit.selectedBeneficiary =
          widget.beneficiaryList[0];
    }
  }

  void subscribeUIStatus() {
    _verifyExistingBankAccountCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.verified:
            MRouter.pop(null);
            widget.onBeneficiaryVerified();
            break;
          case Event.failed:
            MRouter.pop(null);
            widget.onBeneficiaryVerificationFailed(
                _verifyExistingBankAccountCubit.selectedBeneficiary!,
                uiStatus.failedWithAlertMessage);
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_16, Dimens.padding_32, Dimens.padding_16, 0),
            child: Row(
              children: [
                buildTitle(),
                buildCloseIcon(),
              ],
            ),
          ),
          buildBeneficiaryListWidget(),
          buildAddNewAccountText(),
          buildVerifyNowButton(),
        ],
      ),
    );
  }

  Widget buildTitle() {
    return Expanded(
      child: Text('select_account_to_verify'.tr,
          style: Get.textTheme.headline6
              ?.copyWith(color: AppColors.backgroundBlack)),
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: SvgPicture.asset(
          'assets/images/ic_close_circle.svg',
        ),
      ),
    );
  }

  Widget buildBeneficiaryListWidget() {
    return StreamBuilder<List<Beneficiary>>(
      stream: _verifyExistingBankAccountCubit.beneficiaryList,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: Dimens.padding_16),
            itemCount: snapshot.data!.length,
            itemBuilder: (_, i) {
              return UnVerifiedBeneficiaryTile(
                index: i,
                beneficiary: snapshot.data![i],
                onBeneficiarySelected: _onBeneficiarySelected,
              );
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  _onBeneficiarySelected(int index, Beneficiary beneficiary) {
    _verifyExistingBankAccountCubit.updateBeneficiaryList(index, beneficiary);
  }

  Widget buildAddNewAccountText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
          widget.onAddBankAccountTapped();
        },
        child: Text('add_new_account'.tr,
            style: Get.textTheme.bodyText2
                ?.copyWith(color: AppColors.primaryMain)),
      ),
    );
  }

  Widget buildVerifyNowButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_24, Dimens.padding_24,
          Dimens.padding_24, Dimens.padding_24),
      child: RaisedRectButton(
        text: 'verify_now'.tr,
        buttonStatus: _verifyExistingBankAccountCubit.buttonStatus,
        onPressed: () {
          _verifyExistingBankAccountCubit.verifyBeneficiary();
        },
      ),
    );
  }
}
