import 'package:awign/packages/flutter_switch/flutter_switch.dart';
import 'package:awign/workforce/auth/feature/otp_verification/widget/otp_verification_widget.dart';
import 'package:awign/workforce/core/data/firebase/remote_config/remote_config_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/earning_withdraw_bottom_sheet/widget/earning_withdraw_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/pin_locked_bottom_sheet/widget/pin_locked_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/pin_verify_bottom_sheet/widget/pin_verify_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/route_widget/route_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/rate_us/widget/rate_us_widget.dart';
import 'package:awign/workforce/payment/data/model/calculate_deduction_response.dart';
import 'package:awign/workforce/payment/data/model/earning_data.dart';
import 'package:awign/workforce/payment/data/model/earning_item_data.dart';
import 'package:awign/workforce/payment/data/model/withdrawl_data.dart';
import 'package:awign/workforce/payment/data/model/workforce_payout_response.dart';
import 'package:awign/workforce/payment/feature/confirm_amount/widget/confirm_amount_widget.dart';
import 'package:awign/workforce/payment/feature/earning_statement/widget/earning_statement_widget.dart';
import 'package:awign/workforce/payment/feature/earnings/cubit/earnings_cubit.dart';
import 'package:awign/workforce/payment/feature/earnings/widget/bottom_sheet/currently_unavailable_bottom_sheet.dart';
import 'package:awign/workforce/payment/feature/earnings/widget/bottom_sheet/upcoming_earning_bottom_sheet.dart';
import 'package:awign/workforce/payment/feature/earnings_faq_support/widget/earning_faq_support_widget.dart';
import 'package:awign/workforce/payment/feature/manage_beneficiary/widget/manage_beneficiary_widget.dart';
import 'package:awign/workforce/payment/feature/withdrawal_history/widget/withdrawal_history_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_section_names.dart';
import '../../../../core/data/model/button_status.dart';
import '../../../data/model/beneficiary.dart';
import '../../../data/model/transfer_history_response.dart';
import '../../confirm_amount/bottom_sheet/no_upcoming_bottom_sheet.dart';
import '../../withdrawal_history/widget/bottom_sheet/widget/transfer_details_bottom_sheet.dart';
import 'bottom_sheet/earning_deduction_bottom_sheet.dart';
import 'bottom_sheet/non_withdrawal_bottom_sheet.dart';
import 'bottom_sheet/trasaction_status_bottom_sheet.dart';

class EarningsWidget extends StatefulWidget {
  static const nonWithdrawalAmount = 100.0;
  final String? fromRoute;
  static const String earnings = 'Earnings';
  static const String history = 'History';
  static const String beneficiary = 'Beneficiary';
  final Map<String, dynamic>? fromRouteMap;

  const EarningsWidget({this.fromRouteMap, Key? key, this.fromRoute})
      : super(key: key);

  @override
  _EarningsWidgetState createState() => _EarningsWidgetState();
}

class _EarningsWidgetState extends State<EarningsWidget> {
  final EarningsCubit _earningsCubit = sl<EarningsCubit>();
  UserData? _currentUser;
  KycDetails? _kycDetails;
  String? _paymentChannel;
  Map<String, String> earningProperties = {};
  final panelController = PanelController();
  bool? isToggleOn;
  bool isButtonSetCalled = false;
  int deeplinkCount = 0;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void setUpFromDeepLink() {
    if (widget.fromRouteMap?['is_from_deep_link'] == true &&
        widget.fromRouteMap?['action'] == 'open_withdrawal_history' &&
        widget.fromRouteMap?['data'] != null) {
      panelController.open();
      _earningsCubit.updateEarningList(1, _earningsCubit.earningDataList[1]);
      showTransferDetailsBottomSheet(context, widget.fromRouteMap?['data']);
    }
  }

  void subscribeUIStatus() {
    _earningsCubit.uiStatus.listen(
          (uiStatus) {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.success:
            _pinVerifiedShowEarningDetails();
            earningProperties[LoggingEvents.panStatus] = _currentUser
                    ?.userProfile?.kycDetails?.panVerificationStatus?.value
                    .toString() ??
                '';
            LoggingData loggingData = LoggingData(
                event: LoggingEvents.earningsWithdrawn,
                pageName: LoggingPageNames.myJobs,
                sectionName: LoggingSectionNames.office,
                otherProperty: earningProperties);
            CaptureEventHelper.captureEvent(loggingData: loggingData);
            _earningsCubit.changeTransactionStatus(TransferStatus.success);
            break;
          case Event.created:
            _earningsCubit.feedbackEvent();
            break;
          case Event.rateus:
            showrateUsBottomSheet(context, MRouter.earningsWidget);
            break;
          case Event.updated:
            _earningsCubit.getTransfersInFailedStatus(_currentUser?.id ?? -1);
            _earningsCubit
                .getTransfersInProcessingStatus(_currentUser?.id ?? -1);
            _earningsCubit.changeUIStatus(UIStatus(event: Event.success));
            _earningsCubit.changeTransactionStatus(TransferStatus.success);
            // showTransactionStatusBottomSheet(context, _earningsCubit.transactionStatus, _onGreatTap);
            break;
          case Event.updateError:
            _earningsCubit.changeTransactionStatus(TransferStatus.failure);
            break;
        }
      },
    );
    _earningsCubit.withdrawlResponseStream.listen((withdrawlResponse) {
      if (withdrawlResponse.transfer != null) {
        if (isToggleOn != null) {
          _earningsCubit.showEmptyEarning(isToggleOn!);
        }
        // showWithdrawnBottomSheet(context, withdrawlResponse.transfer?.amount);
      }
    });
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    _kycDetails = _currentUser?.userProfile?.kycDetails;
    if (_kycDetails != null) {
      _earningsCubit.changeKycDetails(_kycDetails!);
    }
    if (_currentUser != null) {
      _verifyPINOrShowPINLockedWidget(spUtil);
      _earningsCubit.changeCurrentUser(_currentUser!);
    }
  }

  _verifyPINOrShowPINLockedWidget(SPUtil? spUtil) async {
    int? lastEarningSectionAccessTime =
    spUtil?.getLastEarningSectionAccessTime();
    if (_currentUser?.pinBlockedTill != null &&
        _currentUser?.pinBlockedTill?.getDateTimeObjectFromUTCDateTime() !=
            null &&
        _currentUser!.pinBlockedTill!
            .getDateTimeObjectFromUTCDateTime()!
            .millisecondsSinceEpoch >
            DateTime
                .now()
                .millisecondsSinceEpoch) {
      _showPINLockedBottomSheet(spUtil);
    } else if (lastEarningSectionAccessTime != null &&
        (lastEarningSectionAccessTime + (5 * 60 * 1000)) >
            DateTime
                .now()
                .millisecondsSinceEpoch) {
      _pinVerifiedShowEarningDetails();
    } else if (_currentUser?.pinSet ?? false) {
      _showVerifyPINBottomSheet(spUtil);
    } else {
      WidgetResult? otpVerificationWidgetResult =
      await MRouter.pushNamed(MRouter.oTPVerificationWidget, arguments: {
        'mobile_number': _currentUser?.mobileNumber ?? '',
        'from_route': MRouter.earningsWidget,
        'page_type': PageType.verifyPIN
      });
      if (otpVerificationWidgetResult != null &&
          otpVerificationWidgetResult.event == Event.verified) {
        if (_currentUser?.pinSet ?? false) {
          _showVerifyPINBottomSheet(spUtil);
        } else {
          WidgetResult? confirmPINWidgetResult =
          await MRouter.pushNamed(MRouter.confirmPINWidget);
          if (confirmPINWidgetResult?.event == Event.updated) {
            _pinVerifiedShowEarningDetails();
          }
        }
      } else {
        _goBack();
      }
    }
  }

  _goBack() {
    MRouter.pushNamedAndRemoveUntil(!widget.fromRoute.isNullOrEmpty
        ? widget.fromRoute!
        : MRouter.categoryListingWidget);
  }

  _showVerifyPINBottomSheet(SPUtil? spUtil) {
    showPINVerifyBottomSheet(Get.context!, (result) {
      if (result.event == Event.failed) {
        _goBack();
      } else if (result.event == Event.updated) {
        _showPINLockedBottomSheet(spUtil);
      } else if (result.event == Event.success) {
        spUtil?.putLastEarningSectionAccessTime(
            DateTime
                .now()
                .millisecondsSinceEpoch);
        if (spUtil!.getShouldShowEarningWithdrawnBottomSheet() ?? true) {
          showEarningWithDrawBottomSheet(
            context,
                () async {
              _pinVerifiedShowEarningDetails();
              spUtil = await SPUtil.getInstance();
              spUtil!.shouldShowEarningWithdrawnBottomSheet(false);
              MRouter.pop(null);
            },
          );
        } else {
          _pinVerifiedShowEarningDetails();
        }
      }
    });
  }

  _showPINLockedBottomSheet(SPUtil? spUtil) {
    showPINLockedBottomSheet(Get.context!, (result) {
      if (result.event == Event.failed) {
        _goBack();
      } else {
        _showVerifyPINBottomSheet(spUtil);
      }
    });
  }

  _pinVerifiedShowEarningDetails() {
    if (_kycDetails?.panVerificationStatus != PanStatus.verified) {
      _earningsCubit.getPANDetails(_currentUser?.id ?? -1);
    } else {
      _earningsCubit.getVerifiedBeneficiaries(_currentUser?.id ?? -1);
    }
    if (_paymentChannel.isNullOrEmpty) {
      _earningsCubit.getWorkForcePayout(_currentUser?.id ?? -1);
    } else {
      Future.delayed(const Duration(milliseconds: Constants.duration_500))
          .then((value) {
        _earningsCubit.getWorkForcePayout(_currentUser?.id ?? -1);
      });
    }
    _earningsCubit.getTransfersInFailedStatus(_currentUser?.id ?? -1);
    _earningsCubit.getTransfersInProcessingStatus(_currentUser?.id ?? -1);
    setUpFromDeepLink();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
        return true;
      },
      child: RouteWidget(
        bottomNavigation: true,
        child: AppScaffold(
          backgroundColor: AppColors.primaryMain,
          body: StreamBuilder<UserData>(
              stream: _earningsCubit.currentUser,
              builder: (context, snapshot) {
                return InternetSensitive(
                  child: snapshot.data == null
                      ? buildNoEarningFound()
                      : StreamBuilder<UIStatus>(
                      stream: _earningsCubit.uiStatus,
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            !snapshot.data!.isOnScreenLoading &&
                            snapshot.data!.data != null) {
                          WorkforcePayoutResponse workforcePayoutResponse =
                          snapshot.data!.data as WorkforcePayoutResponse;
                          if (!isButtonSetCalled) {
                            _earningsCubit
                                .setButtonStatus(workforcePayoutResponse);
                            isButtonSetCalled = true;
                          }
                          double? total = workforcePayoutResponse.redeemable +
                              workforcePayoutResponse.approved +
                              workforcePayoutResponse.redeemed;
                          return Column(
                            children: [
                              Expanded(child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          Dimens.padding_16,
                                          Dimens.padding_48,
                                          Dimens.padding_16,
                                          0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          buildNotificationIcon(),
                                          const SizedBox(
                                              height: Dimens.padding_16),
                                          buildAllTimeEarningText(total),
                                          const SizedBox(
                                              height: Dimens.padding_8),
                                          if (workforcePayoutResponse
                                              .earningsSince !=
                                              "") ...[
                                            buildEarningDateText(
                                                workforcePayoutResponse
                                                    .earningsSince),
                                          ],
                                          const SizedBox(
                                              height: Dimens.padding_16),
                                          workforcePayoutResponse.redeemable ==
                                              0 &&
                                              workforcePayoutResponse
                                                  .approved ==
                                                  0
                                              ? buildEmptyEarningCard()
                                              : buildEarningCard(
                                              workforcePayoutResponse),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                              SlidingUpPanel(
                                minHeight:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.23,
                                maxHeight:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.80,
                                parallaxOffset: 0.0,
                                parallaxEnabled: true,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(Dimens.padding_16)),
                                controller: panelController,
                                body: const SizedBox(),
                                panelBuilder: (controller) =>
                                    buildBody(
                                        workforcePayoutResponse, controller),
                              ),
                            ],
                          );
                        } else {
                          return Container(
                              height: double.infinity,
                              color: AppColors.backgroundWhite,
                              child: AppCircularProgressIndicator());
                        }
                      }),
                );
              }),
        ),
      ),
    );
  }

  Widget buildBody(WorkforcePayoutResponse workforcePayoutResponse,
      ScrollController controller) {
    return Container(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
        child: Column(
          children: [
            buildDragHandle(),
            const SizedBox(height: Dimens.padding_8),
            buildEarningMenu(),
            Flexible(
                child: StreamBuilder<String?>(
                    stream: _earningsCubit.earningItemStream,
                    builder: (context, earningItem) {
                      if (earningItem.data == EarningsWidget.beneficiary) {
                        return const ManageBeneficiaryWidget();
                      } else if (earningItem.data == EarningsWidget.history) {
                        return WithdrawalHistoryWidget(
                          controller: controller,
                          earningSectionRefresh: _refreshWithdrawal,
                        );
                      } else if (earningItem.data == EarningsWidget.earnings) {
                        return const EarningStatementWidget();
                      } else {
                        return const EarningFaqSupportWidget();
                      }
                    })),
          ],
        ));
  }

  void _refreshWithdrawal() {
    _earningsCubit.getTransfersInFailedStatus(_currentUser?.id ?? -1);
    _earningsCubit.getTransfersInProcessingStatus(_currentUser?.id ?? -1);
  }

  Widget buildNotificationIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: StreamBuilder<UserData>(
          stream: _earningsCubit.currentUser,
          builder: (context, snapshot) {
            return MyInkWell(
                onTap: () {
                  snapshot.data != null
                      ? MRouter.pushNamed(MRouter.notificationWidget)
                      : MRouter.pushNamed(MRouter.phoneVerificationWidget);
                },
                child: snapshot.data != null
                    ? SvgPicture.asset('assets/images/ic_notification.svg',
                    color: AppColors.backgroundWhite)
                    : Container(
                  width: Dimens.margin_56,
                  padding: const EdgeInsets.all(Dimens.padding_4),
                  margin: const EdgeInsets.all(Dimens.padding_4),
                  decoration: const BoxDecoration(
                      color: AppColors.backgroundBlack,
                      borderRadius: BorderRadius.all(
                          Radius.circular(Dimens.radius_16))),
                  child: Center(
                      child: Text('login'.tr,
                          style: Get.textTheme.bodySmall?.copyWith(
                              color: AppColors.backgroundWhite))),
                ));
          }),
    );
  }

  Widget buildAllTimeEarningText(double total) {
    return Row(
      children: [
        Image.asset(
          "assets/images/coin.png",
        ),
        const SizedBox(width: Dimens.padding_4),
        Text(StringUtils.getIndianFormatNumber(total),
            textAlign: TextAlign.center,
            style: context.textTheme.headline5
                ?.copyWith(color: AppColors.backgroundWhite)),
      ],
    );
  }

  Widget buildEarningDateText(String? earningsSince) {
    return Text("Earnings since ${earningsSince?.parseDateToMonthAndYear()}",
        textAlign: TextAlign.center,
        style: context.textTheme.headline5?.copyWith(
            color: AppColors.backgroundWhite,
            fontSize: Dimens.font_16,
            fontWeight: FontWeight.w400));
  }

  Widget buildEarningCard(WorkforcePayoutResponse workforcePayoutResponse) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: StreamBuilder<bool>(
            stream: _earningsCubit.isUpcomingEarningEnabled,
            builder: (context, isEnabled) {
              return StreamBuilder<CalculateDeductionResponse>(
                  stream: _earningsCubit.calculateDeductionResponseStream,
                  builder: (context, calculateDeductionResponse) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildWithdrawleEarning(workforcePayoutResponse),
                        const SizedBox(height: Dimens.padding_12),
                        buildUpcomingEarning(workforcePayoutResponse,
                            isEnabled.data, calculateDeductionResponse.data),
                        const SizedBox(height: Dimens.padding_8),
                        HDivider(dividerColor: AppColors.backgroundGrey400),
                        if (isEnabled.hasData) ...[
                          buildTotalWithdraw(workforcePayoutResponse,
                              isEnabled.data, calculateDeductionResponse.data),
                        ],
                        const SizedBox(height: Dimens.padding_16),
                        buildProceedSlotButton(workforcePayoutResponse,
                            calculateDeductionResponse.data),
                        const SizedBox(height: Dimens.margin_4),
                        StreamBuilder<ButtonStatus>(
                            stream: _earningsCubit.buttonStatusStream,
                            builder: (context, showText) {
                              return (showText.hasData &&
                                  showText.data?.isEnable == false) ? Text(
                                  'cannot_proceed_to_withdraw_as_total_amount_less_than_100'
                                      .tr) : Text(
                                  'payments_after_3_pm_will_be_processed_next_day_at_8_pm'
                                      .tr);
                            }),
                        const SizedBox(height: Dimens.padding_8),
                        buildFailedAndProcessingPaymentCard()
                      ],
                    );
                  });
            }),
      ),
    );
  }

  Widget buildFailedAndProcessingPaymentCard() {
    return Column(
      children: [
        StreamBuilder<TransferHistoryResponse>(
            stream: _earningsCubit.transactionsInFailedStatus,
            builder: (context, failedTransaction) {
              if (failedTransaction.data?.transfers != null
                  && failedTransaction.data!.transfers!.isNotEmpty) {
                return Column(
                  children: [
                    CarouselSlider(
                        items:
                        failedTransaction.data!.transfers?.map((transfer) {
                          return Builder(builder: (BuildContext context) {
                            return buildFailedTransactionTile(transfer);
                          });
                        }).toList(),
                        options: CarouselOptions(
                          height: 200,
                          viewportFraction: 1,
                          autoPlay: false,
                          onPageChanged: (index, reason) {
                            _earningsCubit.changeFailedTransactionSlider(index);
                          },
                          reverse: false,
                          enableInfiniteScroll: false,
                        )),
                    StreamBuilder<int>(
                        stream: _earningsCubit.failedTransactionSlider,
                        builder: (context, failedTransactionSlider) {
                          return Visibility(
                            visible:
                            (failedTransaction.data?.transfers?.length ?? 0) >
                                1,
                            child: DotsIndicator(
                              dotsCount: failedTransaction.data?.transfers
                                  ?.length ?? 0,
                              position: failedTransactionSlider.data!
                                  .toDouble(),
                              decorator: const DotsDecorator(
                                color: AppColors.backgroundGrey500,
                                // Inactive color
                                activeColor: AppColors.backgroundGrey900,
                              ),
                            ),
                          );
                        }),
                  ],
                );
              } else {
                return const SizedBox();
              }
            }),
        StreamBuilder<TransferHistoryResponse>(
            stream: _earningsCubit.transactionsInProcessingStatus,
            builder: (context, processingTransaction) {
              if (processingTransaction.data?.transfers != null &&
                  processingTransaction.data!.transfers!.isNotEmpty) {
                return Column(
                  children: [
                    CarouselSlider(
                        items: processingTransaction.data!.transfers
                            ?.map((transfer) {
                          return Builder(builder: (BuildContext context) {
                            return buildProcessingTransactionTile(transfer);
                          });
                        }).toList(),
                        options: CarouselOptions(
                          height: 100,
                          viewportFraction: 1,
                          autoPlay: false,
                          onPageChanged: (index, reason) {
                            _earningsCubit.changeProcessingTransactionSlider(
                                index);
                          },
                          reverse: false,
                          enableInfiniteScroll: false,
                        )),
                    StreamBuilder<int>(
                        stream: _earningsCubit.processingTransactionSlider,
                        builder: (context, processingTransactionSlider) {
                          return Visibility(
                            visible:
                            (processingTransaction.data?.transfers?.length ??
                                0) >
                                1,
                            child: DotsIndicator(
                              dotsCount:
                              processingTransaction.data?.transfers?.length ??
                                  0,
                              position: processingTransactionSlider.data?.toDouble() ?? 0.0,
                              decorator: const DotsDecorator(
                                color: AppColors.backgroundGrey500,
                                // Inactive color
                                activeColor: AppColors.backgroundGrey900,
                              ),
                            ),
                          );
                        }
                    ),
                  ],
                );
              } else {
                return const SizedBox();
              }
            })
      ],
    );
  }

  Widget buildFailedTransactionTile(Transfer transfer) {
    return Card(
      color: AppColors.error100,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_8))),
      borderOnForeground: false,
      elevation: Dimens.elevation_8,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Dimens.padding_4, horizontal: Dimens.padding_4),
        child: Row(
          children: [
            MyInkWell(
                onTap: () {
                  _clickOnFailedCard(transfer);
                },
                child: Image.asset('assets/images/ic_payment_failed.png')),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyInkWell(
                    onTap: () {
                      _clickOnFailedCard(transfer);
                    },
                    child: Text(
                      'payment_unsuccessful'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  MyInkWell(
                    onTap: () {
                      _clickOnFailedCard(transfer);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: Dimens.margin_8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                              children: (transfer.statusReason != null)
                                  ? getBeforeUpdateDetailsClickedText(transfer)
                                  : getAfterUpdateDetailsClickedText(transfer)),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible:
                        transfer.statusReason == "INVALID_BENEFICIARY_DETAILS",
                    child: TextButton(
                      onPressed: () async {
                        LoggingData loggingData =
                            LoggingData(action: LoggingEvents.contactSupport);
                        CaptureEventHelper.captureEvent(
                            loggingData: loggingData);

                        Beneficiary? beneficiary = await MRouter.pushNamed(
                            MRouter.selectBeneficiaryWidget);
                        if (beneficiary != null) {
                          transfer.beneficiaryId = beneficiary.beneId;
                          _openOTPVerificationWidget(transfer, beneficiary);
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimens.margin_8),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(Dimens.radius_8)),
                              border: Border.all(
                                  color: AppColors.primaryMain,
                                  width: Dimens.border_2)),
                          child: Center(
                            child: Text(
                              'Update bank details'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.primaryMain,
                                  fontSize: Dimens.font_12),
                            ),
                          )),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<TextSpan> getBeforeUpdateDetailsClickedText(Transfer transfer) {
    var elements = <TextSpan>{};

    elements.add(TextSpan(
        text: 'The withdrawal of ',
        style: Get.context?.textTheme.labelLarge?.copyWith(
            color: AppColors.backgroundGrey800,
            fontSize: Dimens.font_14,
            fontWeight: FontWeight.w400)));

    elements.add(TextSpan(
      text: 'INR ${transfer.amount}',
      style: Get.context?.textTheme.labelLarge?.copyWith(
          color: AppColors.black,
          fontSize: Dimens.font_14,
          fontWeight: FontWeight.bold),
    ));

    elements.add(TextSpan(
        text:
        getEarningSectionText(transfer),
        style: Get.context?.textTheme.labelLarge?.copyWith(
            color: AppColors.backgroundGrey800,
            fontSize: Dimens.font_14,
            fontWeight: FontWeight.w400)));

    elements.add(TextSpan(
        text:
        transfer.expectedTransferTime != null ?
        ' ${StringUtils.getDateInLocalFromUtc(transfer.expectedTransferTime ?? '')} by 9 PM.' : '',
        style: Get.context?.textTheme.labelLarge?.copyWith(
            color: AppColors.black,
            fontSize: Dimens.font_14,
            fontWeight: FontWeight.bold)));

    return elements.toList();
  }

  List<TextSpan> getAfterUpdateDetailsClickedText(Transfer transfer) {
    var elements = <TextSpan>{};

    elements.add(TextSpan(
        text:
            'Relax, your payment is secure! Automatic retry is scheduled for ',
        style: Get.context?.textTheme.labelLarge?.copyWith(
            color: AppColors.backgroundGrey800,
            fontSize: Dimens.font_14,
            fontWeight: FontWeight.w400)));

    elements.add(TextSpan(
      text:
          ' ${StringUtils.getDateInLocalFromUtc(transfer.expectedTransferTime ?? '')} by 9 PM',
      style: Get.context?.textTheme.labelLarge?.copyWith(
          color: AppColors.black,
          fontSize: Dimens.font_14,
          fontWeight: FontWeight.bold),
    ));

    return elements.toList();
  }

  String getEarningSectionText(Transfer transfer) {
    if (transfer.statusReason == "INVALID_BENEFICIARY_DETAILS") {
      return ' has failed due to invalid bank details. Please update your bank details now!';
    }
    if (transfer.statusReason == "NOT_ENOUGH_BALANCE") {
      return ' has failed due to some technical issue. Automatic retry is scheduled for';
    }
    if (transfer.statusReason == "BANK_SIDE_ISSUE") {
      return ' has failed due to the bank server issue at your end. Automatic retry is scheduled for';
    }

    return ' has failed due to some technical issue. Automatic retry is scheduled for';
  }

  _clickOnFailedCard(Transfer transfer) {
    panelController.open();
    _earningsCubit.updateEarningList(1, _earningsCubit.earningDataList[1]);
    LoggingData loggingData = LoggingData(
        action: LoggingEvents.recentFailure,
        otherProperty: {"Toggle Ids": transfer.id.toString() ?? ''});
    CaptureEventHelper.captureEvent(loggingData: loggingData);
  }

  _openOTPVerificationWidget(Transfer transfer, Beneficiary beneficiary) async {
    WidgetResult? widgetResult =
    await MRouter.pushNamed(MRouter.oTPVerificationWidget, arguments: {
      'mobile_number': _currentUser?.mobileNumber ?? '',
      'from_route': MRouter.withdrawalHistoryWidget,
      'page_type': PageType.verifyPIN
    });
    if (widgetResult != null && widgetResult.event == Event.verified) {
      showTransactionStatusBottomSheet(context, _earningsCubit.transactionStatus, _onGreatTap,isFromUpdate: true);
      _earningsCubit.updateBeneficiary(_currentUser, transfer);
    }
  }

  _onGreatTap() {
    panelController.open();
    _earningsCubit.updateEarningList(1, _earningsCubit.earningDataList[1]);
  }

  Widget buildProcessingTransactionTile(Transfer transfer) {
    return MyInkWell(
      onTap: () {
        panelController.open();
        _earningsCubit.updateEarningList(1, _earningsCubit.earningDataList[1]);
        LoggingData loggingData = LoggingData(
            action: LoggingEvents.requestedTransfer,
            otherProperty: {"Toggle Ids": transfer.id.toString() ?? ''});
        CaptureEventHelper.captureEvent(loggingData: loggingData);
      },
      child: Card(
        color: AppColors.warning100,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_8))),
        borderOnForeground: false,
        elevation: Dimens.elevation_8,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: Dimens.padding_8, horizontal: Dimens.padding_8),
          child: Row(
            children: [
              Image.asset('assets/images/ic_payment_processing.png'),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'payment_is_under_process'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        'Your payment of ${StringUtils.getIndianFormatNumber(
                            transfer.amount)} will be credited on ${(transfer
                            .expectedTransferTime != null) ? StringUtils
                            .getDateInLocalFromUtc(transfer
                            .expectedTransferTime!) : ''} by 9pm',
                        textAlign: TextAlign.start,
                        // overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              RotationTransition(
                turns: const AlwaysStoppedAnimation(180 / 360),
                child: SvgPicture.asset(
                  'assets/images/arrow_left.svg',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEarningMenu() {
    return SizedBox(
      height: Dimens.btnWidth_100,
      child: StreamBuilder<List<EarningItemData>>(
          stream: _earningsCubit.earningDataListStream,
          builder: (context, earningDataList) {
            if (earningDataList.hasData) {
              return ListView.builder(
                  itemCount: earningDataList.data!.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimens.padding_12),
                      child: Column(
                        children: [
                          MyInkWell(
                            onTap: () {
                              _earningsCubit.updateEarningList(
                                  index, earningDataList.data![index]);
                            },
                            child: CircleAvatar(
                              backgroundColor: AppColors.primary100,
                              radius: Dimens.padding_32,
                              child: SvgPicture.asset(
                                earningDataList.data![index].images!,
                                color: earningDataList.data![index].isSelected
                                    ? AppColors.primary500
                                    : AppColors.primary200,
                                height: Dimens.padding_24,
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimens.padding_8),
                          Text(earningDataList.data![index].earningItem!,
                              style: context.textTheme.bodyText2?.copyWith(
                                  color: earningDataList.data![index].isSelected
                                      ? AppColors.primary500
                                      : AppColors.primary200,
                                  fontWeight: FontWeight.w500,
                                  fontSize: Dimens.font_10)),
                        ],
                      ),
                    );
                  });
            } else {
              return AppCircularProgressIndicator();
            }
          }),
    );
  }

  Widget buildNoEarningFound() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_32),
      child: Column(
        children: [
          const SizedBox(
            height: Dimens.imageHeight_100,
          ),
          Image.asset(
            'assets/images/empty_earning.png',
            height: Dimens.imageHeight_150,
          ),
          const SizedBox(height: Dimens.padding_24),
          Text(
            'no_earnings_yet'.tr,
            textAlign: TextAlign.center,
            style: Get.context?.textTheme.labelLarge?.copyWith(
                color: AppColors.black,
                fontSize: Dimens.font_18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: Dimens.padding_12,
          ),
          Text(
            'Start_working_and_keep_a_track_of_your_earnings_here'.tr,
            textAlign: TextAlign.center,
            style: Get.context?.textTheme.labelLarge?.copyWith(
                color: AppColors.backgroundGrey900,
                fontSize: Dimens.font_16,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: Dimens.padding_24),
          RaisedRectButton(
            width: Dimens.btnWidth_150,
            text: 'login'.tr,
            onPressed: () {
              MRouter.pushNamed(MRouter.phoneVerificationWidget);
            },
          )
        ],
      ),
    );
  }

  Widget buildWithdrawleEarning(
      WorkforcePayoutResponse workforcePayoutResponse) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('withdrawable_earnings'.tr,
            style: context.textTheme.bodyText2?.copyWith(
                color: AppColors.backgroundGrey900,
                fontWeight: FontWeight.w500,
                fontSize: Dimens.font_16)),
        Text(
            StringUtils.getIndianFormatNumber(
                workforcePayoutResponse.redeemable),
            style: context.textTheme.headline7Bold.copyWith(
                color: AppColors.backgroundGrey900,
                fontSize: Dimens.font_16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget buildUpcomingEarning(WorkforcePayoutResponse workforcePayoutResponse,
      bool? isEnabled, CalculateDeductionResponse? calculateDeductionResponse) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FlutterSwitch(
                activeColor: AppColors.success400,
                inactiveColor: AppColors.backgroundGrey500,
                value: _setToggleValue(isEnabled, workforcePayoutResponse,
                    calculateDeductionResponse),
                height: Dimens.font_20,
                width: Dimens.padding_48,
                onToggle: (value) {
                  if (workforcePayoutResponse.approved > 0 &&
                      (workforcePayoutResponse.instantPaymentEligible ??
                          false)) {
                    if (isToggleOn != null) {
                      isToggleOn = value;
                    }
                    _earningsCubit.changeIsUpcomingEarningEnabled(value);
                    _earningsCubit.calculateWithDrawAmountOnToggle(
                        value,
                        workforcePayoutResponse.redeemable,
                        workforcePayoutResponse.approved,
                        calculateDeductionResponse!.deductions![1].amount!,
                        calculateDeductionResponse!.deductions![0].amount!);

                    LoggingData loggingData = LoggingData(
                        action: LoggingEvents.upcomingEarningsToggle,
                        otherProperty: {"Toggle value": value.toString()});
                    CaptureEventHelper.captureEvent(loggingData: loggingData);
                  } else {
                    showNoUpComingBottomSheet(context);
                    null;
                  }
                }),
            const SizedBox(width: Dimens.padding_8),
            MyInkWell(
              onTap: () {
                if (workforcePayoutResponse.instantPaymentEligible!) {
                  showUpcomingEarningBottomSheet(context);
                } else {
                  showCurrentlyUnavailableBottomSheet(context);
                }
                LoggingData loggingData = LoggingData(
                  action: LoggingEvents.upcomingEarnings,
                );
                CaptureEventHelper.captureEvent(loggingData: loggingData);
              },
              child: Text('upcoming_earnings'.tr,
                  style: context.textTheme.headline7Bold.copyWith(
                      color: isEnabled ?? false
                          ? AppColors.primaryMain
                          : AppColors.backgroundGrey600,
                      fontSize: Dimens.font_16,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        Text(
            StringUtils.getIndianFormatNumber(workforcePayoutResponse.approved),
            style: context.textTheme.headline7Bold.copyWith(
                color: isEnabled ?? false
                    ? AppColors.backgroundGrey900
                    : AppColors.backgroundGrey600,
                fontSize: Dimens.font_16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  bool _setToggleValue(bool? isEnabled,
      WorkforcePayoutResponse workforcePayoutResponse,
      CalculateDeductionResponse? calculateDeductionResponse) {
    bool toggleValue = false;
    toggleValue = (isEnabled != null) ? isEnabled : (workforcePayoutResponse
        .instantPaymentEligible! && workforcePayoutResponse.approved > 0)
        ? true
        : false;
    if (isToggleOn != null) {
      isToggleOn = toggleValue;
    }
    _earningsCubit.changeIsUpcomingEarningEnabled(toggleValue);
    _earningsCubit.calculateWithDrawAmountOnToggle(
        toggleValue,
        workforcePayoutResponse.redeemable,
        workforcePayoutResponse.approved,
        calculateDeductionResponse?.deductions?[1].amount ?? 0,
        calculateDeductionResponse?.deductions?[0].amount ?? 0);
    return toggleValue;
  }

  Widget buildTotalWithdraw(WorkforcePayoutResponse workforcePayoutResponse,
      bool? isEnabled, CalculateDeductionResponse? calculateDeductionResponse) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('total_withdraw'.tr,
                  style: context.textTheme.bodyText2?.copyWith(
                      color: AppColors.backgroundGrey900,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: Dimens.padding_8),
              Visibility(
                visible: isEnabled ?? false,
                child: MyInkWell(
                  onTap: () {
                    showEarningDeductionBottomSheet(
                        context, calculateDeductionResponse);
                    LoggingData loggingData = LoggingData(
                      action: LoggingEvents.deductionsApplicable,
                    );
                    CaptureEventHelper.captureEvent(loggingData: loggingData);
                  },
                  child: Text('deductions_applicable'.tr,
                      style: context.textTheme.bodyText2?.copyWith(
                          color: AppColors.primaryMain,
                          fontWeight: FontWeight.w400,
                          fontSize: Dimens.font_10)),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Image.asset(
              "assets/images/coin.png",
              height: Dimens.font_20,
            ),
            const SizedBox(width: Dimens.padding_4),
            StreamBuilder<double>(
                stream: _earningsCubit.totalWithdrawAfterCalculationStream,
                builder: (context, withdrawEarningAfterCalc) {
                  String totalValue;
                  if (isToggleOn != null && !isToggleOn!) {
                    totalValue = '0';
                  } else {
                    totalValue = StringUtils.getIndianFormatNumber(
                        withdrawEarningAfterCalc.hasData
                            ? withdrawEarningAfterCalc.data
                            : workforcePayoutResponse.redeemable);
                  }
                  return Text(totalValue,
                      style: context.textTheme.headline7Bold.copyWith(
                          color: AppColors.backgroundBlack,
                          fontSize: Dimens.font_18,
                          fontWeight: FontWeight.w700));
                }),
          ],
        )
      ],
    );
  }

  Widget buildProceedSlotButton(WorkforcePayoutResponse workforcePayoutResponse,
      CalculateDeductionResponse? calculateDeductionResponse) {
    return StreamBuilder<KycDetails>(
        stream: _earningsCubit.kycDetails,
        builder: (context, kycDetails) {
          return StreamBuilder<BeneficiaryResponse>(
              stream: _earningsCubit.beneficiaryResponse,
              builder: (context, beneficiaryResponse) {
                String text = 'verify_to_withdraw_with_arrow'.tr;
                bool isBeneficiaryFound = false;
                if (kycDetails.hasData &&
                    kycDetails.data != null &&
                    kycDetails.data!.panVerificationStatus ==
                        PanStatus.verified &&
                    beneficiaryResponse.hasData &&
                    beneficiaryResponse.data != null &&
                    !beneficiaryResponse.data!.beneficiaries.isNullOrEmpty) {
                  text = 'proceed'.tr;
                  isBeneficiaryFound = true;
                }
                if (widget.fromRouteMap?['is_from_deep_link'] == true
                    && widget.fromRouteMap?['action'] == 'open_confirm_amount'
                    && deeplinkCount < 3
                    && workforcePayoutResponse.instantPaymentEligible == true) {
                  deeplinkCount++;
                  Future.delayed(
                      const Duration(seconds: 2))
                      .then((value) {
                    _onClickedCashFreeWithdrawal(
                        workforcePayoutResponse,
                        kycDetails.data,
                        isBeneficiaryFound,
                        calculateDeductionResponse);
                  });
                }
                return RaisedRectButton(
                    buttonStatus: _earningsCubit.buttonStatus,
                    text: text,
                    height: Dimens.btnHeight_40,
                    backgroundColor: AppColors.success400,
                    onPressed: () async {
                      _onClickedCashFreeWithdrawal(
                          workforcePayoutResponse,
                          kycDetails.data,
                          isBeneficiaryFound,
                          calculateDeductionResponse);
                    });
              });
        });
  }

  Widget buildDragHandle() {
    return MyInkWell(
      onTap: () {
        panelController.isPanelOpen
            ? panelController.close()
            : panelController.open();
      },
      child: Center(
        child: Container(
          width: Dimens.padding_48,
          height: Dimens.padding_4,
          decoration: const BoxDecoration(
              color: AppColors.primary200,
              borderRadius:
              BorderRadius.all(Radius.circular(Dimens.radius_16))),
        ),
      ),
    );
  }

  _onClickedCashFreeWithdrawal(WorkforcePayoutResponse workforcePayoutResponse,
      KycDetails? kycDetails,
      bool isBeneficiaryFound,
      CalculateDeductionResponse? calculateDeductionResponse) async {
    if (!RemoteConfigHelper
        .instance()
        .isEarningSectionDisabled) {
      if (kycDetails != null &&
          kycDetails.panVerificationStatus != PanStatus.verified ||
          !isBeneficiaryFound) {
        LoggingData loggingData = LoggingData(
            action: LoggingActions.verifyToWithdraw,
            pageName: LoggingPageNames.earnings);
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        bool? isRefreshed =
        await MRouter.pushNamed(MRouter.withdrawalVerificationWidget);
        if (isRefreshed != null && isRefreshed) {
          _pinVerifiedShowEarningDetails();
        }
      } else if (!_earningsCubit.isWithdrawaleOrNot()) {
        showNonWithdrawalBottomSheet(context);
      } else {
        EarningData earningData = EarningData(
            isToggleOn: _earningsCubit.isUpcomingEarningEnabledValue,
            workforcePayoutResponse: workforcePayoutResponse);
        if (calculateDeductionResponse != null) {
          earningData = EarningData(
              isToggleOn: _earningsCubit.isUpcomingEarningEnabledValue,
              workforcePayoutResponse: workforcePayoutResponse,
              calculateDeductionResponse: calculateDeductionResponse);
        }
        Map? map = await MRouter.pushNamedWithResult(context,
            ConfirmAmountWidget(earningData), MRouter.confirmAmountWidget);
        WidgetResult? widgetResult = map?[Constants.success];
        WithdrawlData? withdrawlData = widgetResult?.data as WithdrawlData?;
        isToggleOn = withdrawlData?.isEarlyWithdrawalIncluded!;
        _earningsCubit.changeIsUpcomingEarningEnabled(isToggleOn ?? false);
        if (widgetResult != null && withdrawlData != null) {
          showTransactionStatusBottomSheet(context, _earningsCubit.transactionStatus, _onGreatTap);
          _earningsCubit.withdrawRequest(withdrawlData);
        }
      }
    }
  }

  Widget buildEmptyEarningCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        padding: const EdgeInsets.all(Dimens.padding_16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('withdrawable_earnings'.tr,
                    style: context.textTheme.bodyText2?.copyWith(
                        color: AppColors.backgroundGrey900,
                        fontWeight: FontWeight.w500,
                        fontSize: Dimens.font_16)),
                Text('0',
                    style: context.textTheme.bodyText2?.copyWith(
                        color: AppColors.backgroundGrey800,
                        fontWeight: FontWeight.w500,
                        fontSize: Dimens.font_16)),
              ],
            ),
            const SizedBox(height: Dimens.padding_16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/images/earning_rocket.png"),
                RaisedRectButton(
                  borderColor: AppColors.primaryMain,
                  height: Dimens.margin_40,
                  textColor: AppColors.primaryMain,
                  backgroundColor: AppColors.backgroundWhite,
                  rightIcon: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.primaryMain,
                    size: Dimens.font_16,
                  ),
                  width: Dimens.btnWidth_180,
                  text: 'find_more_work'.tr,
                  onPressed: () {
                    MRouter.pushNamedAndRemoveUntil(
                        MRouter.categoryListingWidget);
                  },
                )
              ],
            ),
            buildFailedAndProcessingPaymentCard()
          ],
        ),
      ),
    );
  }
}
