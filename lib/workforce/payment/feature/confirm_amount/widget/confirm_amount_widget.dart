import 'package:awign/packages/flutter_switch/flutter_switch.dart';
import 'package:awign/workforce/auth/feature/otp_verification/widget/otp_verification_widget.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/model/earning_data.dart';
import 'package:awign/workforce/payment/data/model/withdrawl_data.dart';
import 'package:awign/workforce/payment/feature/confirm_amount/bottom_sheet/no_upcoming_bottom_sheet.dart';
import 'package:awign/workforce/payment/feature/confirm_amount/bottom_sheet/withdrawal_confirmation_bottom_sheet.dart';
import 'package:awign/workforce/payment/feature/confirm_amount/cubit/confirm_amount_cubit.dart';
import 'package:awign/workforce/payment/feature/earnings/widget/bottom_sheet/earning_deduction_bottom_sheet.dart';
import 'package:awign/workforce/payment/feature/earnings/widget/bottom_sheet/non_withdrawal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/model/button_status.dart';
import '../../../../core/data/remote/capture_event/capture_event_helper.dart';
import '../../../../core/data/remote/capture_event/logging_data.dart';

class ConfirmAmountWidget extends StatefulWidget {
  final EarningData earningData;

  const ConfirmAmountWidget(this.earningData, {Key? key}) : super(key: key);

  @override
  State<ConfirmAmountWidget> createState() => _ConfirmAmountWidgetState();
}

class _ConfirmAmountWidgetState extends State<ConfirmAmountWidget> {
  final ConfirmAmountCubit _confirmAmountCubit = sl<ConfirmAmountCubit>();
  UserData? _currentUser;
  SPUtil? spUtil;
  WidgetResult? otpVerificationResult;
  bool isButtonSetCalled = false;

  @override
  void initState() {
    super.initState();
    calculateAmountOnToggle();
    getCurrentUser();
    _confirmAmountCubit.getExpectedTransferTime();
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return WillPopScope(
      onWillPop: () async {
        if (otpVerificationResult?.event != Event.verified) {
          MRouter.popNamedWithResult(
              MRouter.earningsWidget, Constants.success, null);
        }
        return true;
      },
      child: AppScaffold(
        backgroundColor: AppColors.primaryMain,
        bottomPadding: 0,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              DefaultAppBar(isCollapsable: true, title: 'confirm_amount'.tr),
            ];
          },
          body: buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: StreamBuilder<UIStatus>(
          stream: _confirmAmountCubit.uiStatus,
          builder: (context, uiStatus) {
            if (uiStatus.hasData && uiStatus.data!.isOnScreenLoading) {
              return AppCircularProgressIndicator();
            } else {
              return InternetSensitive(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                      Dimens.padding_36, Dimens.padding_16, Dimens.padding_36),
                  child: StreamBuilder<bool>(
                      stream: _confirmAmountCubit.isUpcomingEarningEnabled,
                      builder: (context, isEnabled) {
                        return StreamBuilder<bool>(
                            stream: _confirmAmountCubit
                                .isOverAllDeductionShownStream,
                            builder: (context, snapshot) {
                              if (!isButtonSetCalled) {
                                _confirmAmountCubit
                                    .setButtonStatus(widget.earningData);
                                isButtonSetCalled = true;
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  buildWithdrawlEarning(),
                                  const SizedBox(height: Dimens.padding_12),
                                  buildUpcomingEarning(isEnabled.data),
                                  const SizedBox(height: Dimens.padding_48),
                                  HDivider(
                                      dividerColor:
                                          AppColors.backgroundGrey500),
                                  const SizedBox(height: Dimens.padding_20),
                                  buildTotalWithdraw(),
                                  const SizedBox(height: Dimens.padding_20),
                                  if ((isEnabled.data ??
                                          widget.earningData.isToggleOn) &&
                                      widget.earningData
                                              .calculateDeductionResponse !=
                                          null) ...[
                                    buildOverAllDeduction(snapshot.data),
                                  ],
                                  const SizedBox(height: Dimens.padding_8),
                                  const Spacer(),
                                  HDivider(
                                      dividerColor:
                                          AppColors.backgroundGrey500),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('total'.tr,
                                                  style: context
                                                      .textTheme.bodyText2
                                                      ?.copyWith(
                                                          color: AppColors
                                                              .backgroundBlack,
                                                          fontSize:
                                                              Dimens.font_16,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                              const SizedBox(
                                                  height: Dimens.padding_8),
                                              buildWithDrawEarning(),
                                            ],
                                          ),
                                          buildWithDrawButton(isEnabled.data),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: Dimens.margin_16,
                                      ),
                                      StreamBuilder<ButtonStatus>(
                                          stream: _confirmAmountCubit
                                              .buttonStatusStream,
                                          builder: (context, showText) {
                                            return Visibility(
                                                visible: showText.hasData &&
                                                    showText.data?.isEnable ==
                                                        false,
                                                child: Text(
                                                  'cannot_proceed_to_withdraw_as_total_amount_less_than_100'
                                                      .tr,
                                                  style: const TextStyle(
                                                      color:
                                                          AppColors.error300),
                                                ));
                                          })
                                    ],
                                  ),
                                ],
                              );
                            });
                      }),
                ),
              );
            }
          }),
    );
  }

  Widget buildWithdrawlEarning() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('withdrawable_earnings'.tr,
            style: context.textTheme.bodyText2?.copyWith(
                color: AppColors.backgroundGrey900,
                fontWeight: FontWeight.w500,
                fontSize: Dimens.font_16)),
        Text(
            StringUtils.getIndianFormatNumber(
                widget.earningData.workforcePayoutResponse.redeemable),
            style: context.textTheme.headline7Bold.copyWith(
                color: AppColors.backgroundBlack,
                fontSize: Dimens.font_16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget buildUpcomingEarning(bool? isEnabled) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FlutterSwitch(
                activeColor: AppColors.success400,
                inactiveColor: AppColors.backgroundGrey500,
                value: isEnabled ?? widget.earningData.isToggleOn,
                height: Dimens.font_20,
                width: Dimens.padding_48,
                onToggle: (value) {
                  if (widget.earningData.workforcePayoutResponse.approved > 0) {
                    _confirmAmountCubit.changeIsUpcomingEarningEnabled(value);
                    _confirmAmountCubit.calculateWithDrawAmountAfterUpcoming(
                        value,
                        widget.earningData.workforcePayoutResponse.redeemable,
                        widget.earningData.workforcePayoutResponse.approved);
                    _confirmAmountCubit.calculateWithDrawAmountOnToggle(
                        value,
                        widget.earningData.workforcePayoutResponse.redeemable,
                        widget.earningData.workforcePayoutResponse.approved,
                        widget.earningData.calculateDeductionResponse!
                            .deductions![1].amount!,
                        widget.earningData.calculateDeductionResponse!
                            .deductions![0].amount!);
                  } else {
                    showNoUpComingBottomSheet(context);
                    null;
                  }
                }),
            const SizedBox(width: Dimens.padding_8),
            Text('upcoming_earnings'.tr,
                style: context.textTheme.bodyText2?.copyWith(
                    color: AppColors.backgroundGrey900,
                    fontWeight: FontWeight.w500,
                    fontSize: Dimens.font_16)),
          ],
        ),
        Text(
            StringUtils.getIndianFormatNumber(
                widget.earningData.workforcePayoutResponse.approved),
            style: context.textTheme.headline7Bold.copyWith(
                color: isEnabled ?? widget.earningData.isToggleOn
                    ? AppColors.backgroundBlack
                    : AppColors.backgroundGrey600,
                fontSize: Dimens.font_16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget buildTotalWithdraw() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('total_withdraw'.tr,
            style: context.textTheme.bodyText2?.copyWith(
                color: AppColors.backgroundGrey900,
                fontSize: Dimens.padding_16,
                fontWeight: FontWeight.w500)),
        StreamBuilder<double>(
            stream: _confirmAmountCubit.totalWithdrawAfterUpcomingEarningStream,
            builder: (context, withdrawEarningAfterCalc) {
              return Text(
                  StringUtils.getIndianFormatNumber(withdrawEarningAfterCalc
                          .hasData
                      ? withdrawEarningAfterCalc.data
                      : widget.earningData.workforcePayoutResponse.redeemable),
                  style: context.textTheme.headline7Bold.copyWith(
                      color: AppColors.backgroundBlack,
                      fontSize: Dimens.font_20,
                      fontWeight: FontWeight.w700));
            })
      ],
    );
  }

  Widget buildOverAllDeduction(bool? isAllChargesHide) {
    double overAllDeduction = widget
            .earningData.calculateDeductionResponse!.deductions![0].amount! +
        widget.earningData.calculateDeductionResponse!.deductions![1].amount!;
    return Container(
      padding: const EdgeInsets.all(Dimens.padding_4),
      decoration: const BoxDecoration(
        color: AppColors.secondary2200,
        borderRadius: BorderRadius.all(
          Radius.circular(Dimens.radius_8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: Dimens.margin_8, top: Dimens.margin_8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('deductions'.tr,
                    style: context.textTheme.bodyText2
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text('- ${overAllDeduction.toStringAsFixed(2)}',
                    style: context.textTheme.bodyText1?.copyWith(
                        color: AppColors.error500, fontWeight: FontWeight.w600))
              ],
            ),
          ),
          buildApprovedCheckBoxWidget(),
          MyInkWell(
            onTap: () {
              showEarningDeductionBottomSheet(
                  context, widget.earningData.calculateDeductionResponse);
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  left: Dimens.margin_8, bottom: Dimens.margin_8),
              child: Text('what_are_deductions'.tr,
                  style: context.textTheme.bodyText2?.copyWith(
                      color: AppColors.primaryMain,
                      fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }

  Widget buildWithDrawEarning() {
    return Row(
      children: [
        Image.asset(
          "assets/images/coin.png",
          height: Dimens.font_16,
        ),
        const SizedBox(
          width: Dimens.padding_4,
        ),
        StreamBuilder<double>(
            stream: _confirmAmountCubit.totalWithdrawAfterCalculationStream,
            builder: (context, withdrawEarningAfterCalc) {
              return Text(
                  StringUtils.getIndianFormatNumber(withdrawEarningAfterCalc
                          .hasData
                      ? withdrawEarningAfterCalc.data
                      : widget.earningData.workforcePayoutResponse.redeemable),
                  style: context.textTheme.headline7Bold
                      .copyWith(color: AppColors.backgroundBlack));
            }),
      ],
    );
  }

  Widget buildApprovedCheckBoxWidget() {
    return StreamBuilder<bool?>(
        stream: _confirmAmountCubit.isChecked,
        builder: (context, snapshot) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 0.6,
                child: Checkbox(
                    value: snapshot.data ?? false,
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                    ),
                    checkColor: AppColors.backgroundWhite,
                    activeColor: AppColors.primaryMain,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimens.padding_4)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (value) {
                      _confirmAmountCubit.changeIsChecked(value!);
                      if (!value) {
                        LoggingData loggingData = LoggingData(
                            action: LoggingEvents.uncheckApproveDeduction);
                        CaptureEventHelper.captureEvent(
                            loggingData: loggingData);
                      }
                    }),
              ),
              Text(
                'i_approve_deduction'.tr,
                style: Get.context?.textTheme.bodyMedium?.copyWith(
                    color: AppColors.black, fontSize: Dimens.font_12),
              )
            ],
          );
        });
  }

  Widget buildWithDrawButton(bool? isEnabled) {
    return StreamBuilder<bool?>(
        stream: _confirmAmountCubit.isChecked,
        builder: (context, snapshot) {
          return RaisedRectButton(
              buttonStatus: _confirmAmountCubit.buttonStatus,
              text: 'initiate_withdrawal'.tr,
              height: Dimens.btnHeight_40,
              width: Dimens.padding_150,
              backgroundColor: isEnabled ?? widget.earningData.isToggleOn
                  ? (snapshot.data ?? false)
                      ? AppColors.primaryMain
                      : AppColors.backgroundGrey500
                  : AppColors.primaryMain,
              onPressed: () async {
                if ((isEnabled != null && isEnabled) || widget.earningData.isToggleOn) {
                  if (snapshot.data != null && snapshot.data!) {
                    showWithdrawalConfirmationBottomSheet(
                        context,
                        _confirmAmountCubit
                            .expectedTransferTimeValue?['expected_time_to_clear'],
                            () async {
                          if (isButttonEnabled(isEnabled, snapshot.data) ?? false) {
                            if (!(isEnabled ?? widget.earningData.isToggleOn) &&
                                widget.earningData.workforcePayoutResponse.redeemable ==
                                    0) {
                              showNonWithdrawalBottomSheet(context);
                            } else {
                              Beneficiary? beneficiary = await MRouter.pushNamed(
                                  MRouter.selectBeneficiaryWidget);
                              if (beneficiary != null) {
                                _openOTPVerificationWidget(beneficiary, isEnabled);
                              }
                            }
                          }
                        });
                  }
                } else {
                  showWithdrawalConfirmationBottomSheet(
                      context,
                      _confirmAmountCubit
                          .expectedTransferTimeValue?['expected_time_to_clear'],
                          () async {
                        if (isButttonEnabled(isEnabled, snapshot.data) ?? false) {
                          if (!(isEnabled ?? widget.earningData.isToggleOn) &&
                              widget.earningData.workforcePayoutResponse.redeemable ==
                                  0) {
                            showNonWithdrawalBottomSheet(context);
                          } else {
                            Beneficiary? beneficiary = await MRouter.pushNamed(
                                MRouter.selectBeneficiaryWidget);
                            if (beneficiary != null) {
                              _openOTPVerificationWidget(beneficiary, isEnabled);
                            }
                          }
                        }
                      });
                }
                LoggingData loggingData =
                    LoggingData(action: LoggingEvents.initiateWithdrawal);
                CaptureEventHelper.captureEvent(loggingData: loggingData);
              });
        });
  }

  bool? isButttonEnabled(bool? isEnabled, bool? isChecked) {
    if (isEnabled ?? widget.earningData.isToggleOn) {
      if (isChecked ?? false) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  _openOTPVerificationWidget(Beneficiary beneficiary, bool? isEnabled) async {
    otpVerificationResult =
        await MRouter.pushNamed(MRouter.oTPVerificationWidget, arguments: {
      'mobile_number': _currentUser?.mobileNumber ?? '',
      'from_route': MRouter.confirmAmountWidget,
      'page_type': PageType.verifyWithdrawlPin,
    });
    if (otpVerificationResult?.event == Event.verified) {
      WithdrawlData withdrawlData = WithdrawlData(
          userId: _currentUser?.id.toString(),
          beneficiaryId: beneficiary.beneId,
          amount: widget.earningData.workforcePayoutResponse.redeemable,
          approvedAmount: widget.earningData.workforcePayoutResponse.approved,
          isEarlyWithdrawalIncluded: isEnabled ?? widget.earningData.isToggleOn,
          deductions: [
            Deductions(
                type: "TDS",
                amount: widget.earningData.calculateDeductionResponse != null
                    ? widget.earningData.calculateDeductionResponse!
                        .deductions![0].amount
                    : 0),
            Deductions(
                type: "Discount",
                amount: widget.earningData.calculateDeductionResponse != null
                    ? widget.earningData.calculateDeductionResponse!
                        .deductions![1].amount
                    : 0),
          ]);
      otpVerificationResult?.data = withdrawlData;
      MRouter.popNamedWithResult(
          MRouter.earningsWidget, Constants.success, otpVerificationResult);
    }
  }

  void calculateAmountOnToggle() {
    if (widget.earningData.isToggleOn) {
      _confirmAmountCubit.calculateWithDrawAmountAfterUpcoming(
          widget.earningData.isToggleOn,
          widget.earningData.workforcePayoutResponse.redeemable,
          widget.earningData.workforcePayoutResponse.approved);
      _confirmAmountCubit.calculateWithDrawAmountOnToggle(
          widget.earningData.isToggleOn,
          widget.earningData.workforcePayoutResponse.redeemable,
          widget.earningData.workforcePayoutResponse.approved,
          widget.earningData.calculateDeductionResponse!.deductions![1].amount!,
          widget
              .earningData.calculateDeductionResponse!.deductions![0].amount!);
    }
  }
}
