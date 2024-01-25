import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/common/data_not_found.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/earning_breakup_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_payout_amount.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_payout_entity.dart';
import 'package:awign/workforce/execution_in_house/feature/leadpayout/cubit/leadpayout_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/leadpayout/widget/bottom_sheet/leadpayout_widget_bottomsheet.dart';
import 'package:awign/workforce/execution_in_house/feature/leadpayout/widget/tile/leadpayout_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class LeadPayoutScreenWidget extends StatefulWidget {
  final EarningBreakupParams earningBreakupParams;
  const LeadPayoutScreenWidget(this.earningBreakupParams, {Key? key})
      : super(key: key);

  @override
  State<LeadPayoutScreenWidget> createState() => _LeadPayoutScreenWidgetState();
}

class _LeadPayoutScreenWidgetState extends State<LeadPayoutScreenWidget> {
  final LeadpayoutCubit _leadpayoutCubit = sl<LeadpayoutCubit>();
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();

  @override
  void initState() {
    super.initState();
    _leadpayoutCubit.changeEarningBreakupParams(widget.earningBreakupParams);
    if (widget.earningBreakupParams.execution == null) {
      _leadpayoutCubit
          .getLeadPayoutAmount(widget.earningBreakupParams.executionID ?? '');
    }
    subscribeUIStatus();
  }

  void subscribeUIStatus() {
    _leadpayoutCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      topPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
                isCollapsable: true,
                title: 'Earning Breakup'.tr,
                leadingURL: widget.earningBreakupParams.execution?.projectIcon),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Get.context?.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<UIStatus>(
            stream: _leadpayoutCubit.uiStatus,
            builder: (context, uiStatus) {
              if (uiStatus.hasData &&
                  (uiStatus.data?.isOnScreenLoading ?? false)) {
                return AppCircularProgressIndicator();
              } else {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0, Dimens.padding_16, 0, Dimens.padding_16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildTotalEarning(),
                        buildLeadPayoutList(),
                      ],
                    ),
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget buildTotalEarning() {
    return StreamBuilder<LeadPayoutAmount>(
        stream: _leadpayoutCubit.leadPayoutAmount,
        builder: (context, leadPayoutAmount) {
          num amount = 0;
          if (widget.earningBreakupParams.amount != null &&
              widget.earningBreakupParams.amount! > 0) {
            amount = widget.earningBreakupParams.amount!;
          } else if (leadPayoutAmount.hasData &&
              leadPayoutAmount.data != null &&
              leadPayoutAmount.data!.totalAmount > 0) {
            amount = leadPayoutAmount.data!.totalAmount;
          }
          if (amount > 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Dimens.padding_32),
              child: Card(
                margin: const EdgeInsets.fromLTRB(
                    Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(Dimens.radius_16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.padding_16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.success300,
                                border: Border.all(color: AppColors.success300),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(Dimens.radius_8))),
                            child: Padding(
                              padding: const EdgeInsets.all(Dimens.padding_8),
                              child: SvgPicture.asset(
                                  'assets/images/ic_wallet.svg'),
                            ),
                          ),
                          const SizedBox(width: Dimens.padding_16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('total_earnings'.tr,
                                  style: Get.context?.textTheme.caption),
                              const SizedBox(height: Dimens.padding_4),
                              Text('${Constants.rs} $amount'.tr,
                                  style: Get.context?.textTheme.headline5),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildLeadPayoutList() {
    String executionID = '';
    if (widget.earningBreakupParams.execution != null) {
      executionID = widget.earningBreakupParams.execution?.id ?? '';
    } else if (widget.earningBreakupParams.executionID != null) {
      executionID = widget.earningBreakupParams.executionID ?? '';
    }
    return PaginationView<EarningBreakupEntity>(
        key: _paginationKey,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        paginationViewType: PaginationViewType.listView,
        itemBuilder: (BuildContext context,
            EarningBreakupEntity earningBreakupEntity, int index) {
          return MyInkWell(
              onTap: () {
                showLeadPayoutBottomSheet(
                    context, earningBreakupEntity.id!, executionID);
              },
              child: LeadPayoutTile(
                earningBreakupEntity: earningBreakupEntity,
              ));
        },
        pageFetch: _leadpayoutCubit.getEarningsBreakup,
        onEmpty: buildEmptyEarning(),
        onError: (dynamic error) => Center(
              child: DataNotFound(),
            ),
        pageIndex: 1);
  }

  Widget buildEmptyEarning() {
    return Padding(
      padding: const EdgeInsets.all(Dimens.padding_16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: Dimens.pbWidth_72,
          ),
          Center(
            child: Image.asset(
              'assets/images/empty_earning.png',
              height: Dimens.imageHeight_150,
            ),
          ),
          const SizedBox(height: Dimens.padding_16),
          Text(
            'no_earnings'.tr,
            textAlign: TextAlign.start,
            style: Get.context?.textTheme.labelLarge?.copyWith(
                color: AppColors.black,
                fontSize: Dimens.font_18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Dimens.padding_16),
          Text(
            'you_ve_not_earned_anything_yet_start_working_to_earn'.tr,
            textAlign: TextAlign.center,
            style: Get.context?.textTheme.labelLarge?.copyWith(
                color: AppColors.backgroundGrey900,
                fontSize: Dimens.font_16,
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}
