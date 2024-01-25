import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/divider/dashed_divider/dashed_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/amount_deduction_response.dart';
import 'package:awign/workforce/payment/feature/earnings/widget/bottom_sheet/withdrawal_bottom_sheet/cubit/withdrawal_bottom_sheet_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';

void showWithdrawalBottomSheet(BuildContext context, double requestedAmount,
    Function onSelectBeneficiaryTapped) {
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
      return WithdrawalBottomSheetWidget(
          requestedAmount, onSelectBeneficiaryTapped);
    },
  );
}

class WithdrawalBottomSheetWidget extends StatefulWidget {
  final double requestedAmount;
  final Function onSelectBeneficiaryTapped;

  const WithdrawalBottomSheetWidget(
      this.requestedAmount, this.onSelectBeneficiaryTapped,
      {Key? key})
      : super(key: key);

  @override
  State<WithdrawalBottomSheetWidget> createState() =>
      WithdrawalBottomSheetWidgetState();
}

class WithdrawalBottomSheetWidgetState
    extends State<WithdrawalBottomSheetWidget> {
  final WithdrawalBottomSheetCubit _withdrawalBottomSheetCubit =
      sl<WithdrawalBottomSheetCubit>();
  UserData? _currentUser;
  KycDetails? _kycDetails;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void subscribeUIStatus() {
    _withdrawalBottomSheetCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
      },
    );
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    _kycDetails = _currentUser?.userProfile?.kycDetails;
    _withdrawalBottomSheetCubit.calculateTDS(
        widget.requestedAmount, _currentUser?.id ?? -1);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.radius_16),
              topRight: Radius.circular(Dimens.radius_16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildCloseIcon(),
              StreamBuilder<AmountDeductionResponse>(
                  stream: _withdrawalBottomSheetCubit.amountDeductionResponse,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          buildEarningsWidgets(snapshot.data!),
                          buildTDSWidgets(snapshot.data!),
                          buildTDSDetailsWidget(snapshot.data!),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimens.padding_16),
                            child: HDashedWidget(totalWidth: Get.width - 32),
                          ),
                          // const SizedBox(height: Dimens.padding_16),
                          buildFinalAmountWidgets(snapshot.data!),
                          buildWithdrawButton(),
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  }),
            ],
          ),
        );
      },
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
        child: MyInkWell(
          onTap: () {
            MRouter.pop(null);
          },
          child: const Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildEarningsWidgets(AmountDeductionResponse amountDeductionResponse) {
    String strAmount = '${Constants.rs}0';
    if (amountDeductionResponse.requestedAmount != null &&
        amountDeductionResponse.requestedAmount! > 0) {
      strAmount =
          '${Constants.rs}${StringUtils.getIndianFormatNumber(amountDeductionResponse.requestedAmount)}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('earnings'.tr, style: Get.textTheme.bodyText2),
          Text(strAmount, style: Get.textTheme.bodyText2),
        ],
      ),
    );
  }

  Widget buildTDSWidgets(AmountDeductionResponse amountDeductionResponse) {
    double tds = 0;
    if (amountDeductionResponse.transferDeductions.isNotEmpty) {
      tds = amountDeductionResponse.transferDeductions[0].amount;
    }
    String strTDS = '-${Constants.rs}$tds';
    if (tds > 0) {
      strTDS = '-${Constants.rs}${StringUtils.getIndianFormatNumber(tds)}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('tds'.tr, style: Get.textTheme.bodyText2),
              const SizedBox(width: Dimens.padding_8),
              tds != 0
                  ? SvgPicture.asset(
                      'assets/images/ic_tds_info.svg',
                      color: AppColors.backgroundGrey800,
                    )
                  : const SizedBox(),
            ],
          ),
          Text(strTDS, style: Get.textTheme.bodyText2),
        ],
      ),
    );
  }

  Widget buildTDSDetailsWidget(
      AmountDeductionResponse amountDeductionResponse) {
    int oneLakh = 100000;
    int thirtyK = 30000;
    int amount = 0;
    double percentage = 0.0;
    double taxableAmount = 0.0;
    String baseDeduction = '2';
    if (_kycDetails?.panCardNumber != null &&
        _kycDetails!.panCardNumber!.length >= 4 &&
        _kycDetails?.panCardNumber?[3] != null &&
        (_kycDetails!.panCardNumber?[3].toUpperCase() == 'P' ||
            _kycDetails?.panCardNumber?[3].toUpperCase() == 'H')) {
      baseDeduction = '1';
    }
    if (amountDeductionResponse.transferDeductions.isNotEmpty) {
      percentage = amountDeductionResponse.transferDeductions[0].percentage;
      taxableAmount =
          amountDeductionResponse.transferDeductions[0].taxableAmount;
    }
    amount = ((taxableAmount / 100) * ((20.0) - (5.0))).toInt();
    String strTDSPercentage = '0';
    if (percentage > 0) {
      strTDSPercentage =
          StringUtils.getIndianFormatNumber(percentage).split('.')[0];
    }
    String tdsDetails = '';
    if ((amountDeductionResponse.financialYearEarning ?? 0) > oneLakh) {
      // tds percentage != 5 means ITR filed status is true
      if (percentage != 5.00) {
        tdsDetails =
            sprintf('tds_info_pan_ver_itr_t_one_lakh'.tr, [strTDSPercentage]);
      } else {
        tdsDetails = sprintf('tds_info_pan_ver_itr_f_one_lakh'.tr,
            [strTDSPercentage, baseDeduction]);
      }
    } else if ((amountDeductionResponse.financialYearEarning ?? 0) > thirtyK) {
      // tds percentage != 5 means ITR filed status is true
      if (percentage != 5.00) {
        tdsDetails =
            sprintf('tds_info_pan_ver_itr_t_thirty_k'.tr, [strTDSPercentage]);
      } else {
        tdsDetails = sprintf('tds_info_pan_ver_itr_f_thirty_k'.tr,
            [strTDSPercentage, baseDeduction]);
      }
    }

    if (_kycDetails?.panVerificationStatus == PanStatus.verified) {
      return Container(
        margin: const EdgeInsets.all(Dimens.padding_16),
        padding: const EdgeInsets.all(Dimens.padding_8),
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey300,
          border: Border.all(
            color: AppColors.backgroundGrey300,
          ),
        ),
        child: Html(
          data: tdsDetails,
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildFinalAmountWidgets(
      AmountDeductionResponse amountDeductionResponse) {
    double finalAmount = 0;
    String strFinalAmount = '${Constants.rs}$finalAmount';
    if ((amountDeductionResponse.withdrawalAmount ?? 0) > 0) {
      finalAmount = amountDeductionResponse.withdrawalAmount!;
    }
    if (finalAmount > 0) {
      strFinalAmount =
          '${Constants.rs}${StringUtils.getIndianFormatNumber(finalAmount)}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('final_amount'.tr, style: Get.textTheme.bodyText2),
          Text(strFinalAmount, style: Get.textTheme.bodyText2),
        ],
      ),
    );
  }

  Widget buildWithdrawButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
      child: RaisedRectButton(
        text: 'withdraw'.tr,
        onPressed: () {
          widget.onSelectBeneficiaryTapped();
        },
      ),
    );
  }
}
