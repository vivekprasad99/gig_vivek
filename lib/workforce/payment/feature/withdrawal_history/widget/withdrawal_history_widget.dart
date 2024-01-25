import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/auth/feature/otp_verification/widget/otp_verification_widget.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/common/data_not_found.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_listing/widget/tile/category_shimmer_tile.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:awign/workforce/payment/data/model/transfer_history_response.dart';
import 'package:awign/workforce/payment/feature/withdrawal_history/cubit/withdrawal_history_cubit.dart';
import 'package:awign/workforce/payment/feature/withdrawal_history/widget/bottom_sheet/widget/transfer_details_bottom_sheet.dart';
import 'package:awign/workforce/payment/feature/withdrawal_history/widget/tile/widget/transfer_history_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WithdrawalHistoryWidget extends StatefulWidget {
  final ScrollController? controller;
  final Function()? earningSectionRefresh;
  const WithdrawalHistoryWidget({
    Key? key,
    this.controller,
    this.earningSectionRefresh,
  }) : super(key: key);

  @override
  _WithdrawalHistoryWidgetState createState() =>
      _WithdrawalHistoryWidgetState();
}

class _WithdrawalHistoryWidgetState extends State<WithdrawalHistoryWidget> {
  final WithdrawalHistoryCubit _withdrawalHistoryCubit =
      sl<WithdrawalHistoryCubit>();
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();
  UserData? _currentUser;
  SPUtil? spUtil;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void subscribeUIStatus() {
    _withdrawalHistoryCubit.uiStatus.listen(
      (uiStatus) async {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.success:
            await Future.delayed(const Duration(seconds: 1));
            _paginationKey.currentState?.refresh();
            if(widget.earningSectionRefresh != null) {
              widget.earningSectionRefresh!();
            }
            break;
        }
      },
    );
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (_currentUser != null) {
      _withdrawalHistoryCubit.changeCurrentUser(_currentUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildTitle(),
        buildWithdrawalHistoryList(),
      ],
    );
  }

  Widget buildTitle() {
    return Text(
      'withdrawal_history'.tr,
      style: Get.textTheme.headline7SemiBold,
    );
  }

  Widget buildWithdrawalHistoryList() {
    return StreamBuilder<UserData>(
        stream: _withdrawalHistoryCubit.currentUser,
        builder: (context, currentUser) {
          if (currentUser.hasData) {
            return Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
                child: PaginationView<Transfer>(
                  key: _paginationKey,
                  scrollController: widget.controller,
                  itemBuilder:
                      (BuildContext context, Transfer transfer, int index) =>
                          TransferHistoryTile(
                    index: index,
                    transfer: transfer,
                    onContactSupportTap: _onContactSupportTap,
                    onRetryTap: _onRetryTapped,
                  ),
                  paginationViewType: PaginationViewType.listView,
                  pageIndex: 1,
                  pageFetch: _withdrawalHistoryCubit.getWithdrawalHistory,
                  onError: (dynamic error) => Center(
                    child: DataNotFound(),
                  ),
                  onEmpty: DataNotFound(),
                  bottomLoader: AppCircularProgressIndicator(),
                  initialLoader: buildShimmerWidget(),
                ),
              ),
            );
          } else {
            return buildShimmerWidget();
          }
        });
  }

  _onContactSupportTap(selectedIndex, selectedTransfer) {
    MRouter.pushNamed(MRouter.faqAndSupportWidget, arguments: {});
  }

  _onRetryTapped(int index, Transfer transfer) async {
    Map<String, dynamic> properties =
        await UserProperty.getUserProperty(_currentUser);
    properties[CleverTapConstant.amount] =
        transfer.amount ?? 0;
    ClevertapHelper.instance()
        .addCleverTapEvent(ClevertapHelper.transferRetry, properties);
    if (transfer.status == Constants.reversed) {
      ClevertapData clevertapData = ClevertapData(
          eventName: ClevertapHelper.retryButtonClicked,
          properties: properties);
      CaptureEventHelper.captureEvent(clevertapData: clevertapData);
    }
    Beneficiary? beneficiary =
        await MRouter.pushNamed(MRouter.selectBeneficiaryWidget);
    if (beneficiary != null) {
      transfer.beneficiaryId = beneficiary.beneId;
      _openOTPVerificationWidget(index, transfer, beneficiary);
    }
  }

  _openOTPVerificationWidget(
      int index, Transfer transfer, Beneficiary beneficiary) async {
    WidgetResult? widgetResult =
        await MRouter.pushNamed(MRouter.oTPVerificationWidget, arguments: {
      'mobile_number': _currentUser?.mobileNumber ?? '',
      'from_route': MRouter.withdrawalHistoryWidget,
      'page_type': PageType.verifyPIN,
    });
    if (widgetResult != null && widgetResult.event == Event.verified) {
      _withdrawalHistoryCubit.retryWithdraw(index, transfer);
    }
  }

  Widget buildShimmerWidget() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.only(top: 0),
        children: const [
          CategoryShimmerTile(),
          CategoryShimmerTile(),
          CategoryShimmerTile(),
          CategoryShimmerTile(),
          CategoryShimmerTile(),
        ],
      ),
    );
  }
}
