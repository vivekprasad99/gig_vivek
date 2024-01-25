import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/app_config_response.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/route_widget/route_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/feature/tds_deduction_details/cubit/tds_deduction_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class TDSDeductionDetailsWidget extends StatefulWidget {
  const TDSDeductionDetailsWidget({Key? key}) : super(key: key);

  @override
  _TDSDeductionDetailsWidgetState createState() =>
      _TDSDeductionDetailsWidgetState();
}

class _TDSDeductionDetailsWidgetState extends State<TDSDeductionDetailsWidget> {
  final TdsDeductionDetailsCubit _tdsDeductionDetailsCubit =
      sl<TdsDeductionDetailsCubit>();
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();
  UserData? _currentUser;
  SPUtil? spUtil;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    AppConfigResponse? appConfigResponse = spUtil?.getLaunchConfigData();
    if (appConfigResponse?.data?.tdsRules?.withoutPan != null &&
        appConfigResponse!.data!.tdsRules!.withoutPan!.isNotEmpty) {
      _tdsDeductionDetailsCubit.changeTdsRuleListWithoutPAN(
          appConfigResponse.data!.tdsRules!.withoutPan!);
    } else {
      Helper.showErrorToast('details_not_found_please_check_after_sometime'.tr);
    }
    if (appConfigResponse?.data?.tdsRules?.withPan != null &&
        appConfigResponse!.data!.tdsRules!.withPan!.isNotEmpty) {
      _tdsDeductionDetailsCubit
          .changeTdsRuleListWithPAN(appConfigResponse.data!.tdsRules!.withPan!);
    }
    if (appConfigResponse?.data?.tdsNote != null) {
      _tdsDeductionDetailsCubit
          .changeTdsNote(appConfigResponse!.data!.tdsNote!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
                isCollapsable: true,
                title: 'tax_deduction'.tr),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildTitleOfTDSRuleListWithoutPAN(),
                buildTDSRuleListWithoutPAN(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                      Dimens.padding_16, Dimens.padding_16, 0),
                  child: HDivider(dividerColor: AppColors.backgroundGrey400),
                ),
                buildTitleOfTDSRuleListWithPAN(),
                buildTDSRuleListWithPAN(),
                buildNoteWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTitleOfTDSRuleListWithoutPAN() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_32, Dimens.padding_16, 0),
      child: Row(
        children: [
          SvgPicture.asset('assets/images/ic_fr_upload_error.svg'),
          const SizedBox(width: Dimens.padding_16),
          Text('pan_card_not_verified'.tr,
              style: Get.textTheme.bodyText1SemiBold),
        ],
      ),
    );
  }

  Widget buildTDSRuleListWithoutPAN() {
    return StreamBuilder<List<String>>(
        stream: _tdsDeductionDetailsCubit.tdsRuleListWithoutPAN,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 0),
                  itemCount: snapshot.data?.length,
                  itemBuilder: (_, i) {
                    return buildRuleItem(snapshot.data?[i] ?? '');
                  },
                ),
              ],
            );
          } else {
            return AppCircularProgressIndicator();
          }
        });
  }

  Widget buildTitleOfTDSRuleListWithPAN() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Row(
        children: [
          SvgPicture.asset('assets/images/ic_fr_uploaded.svg'),
          const SizedBox(width: Dimens.padding_16),
          Text('pan_card_verified'.tr, style: Get.textTheme.bodyText1SemiBold),
        ],
      ),
    );
  }

  Widget buildTDSRuleListWithPAN() {
    return StreamBuilder<List<String>>(
        stream: _tdsDeductionDetailsCubit.tdsRuleListWithPAN,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 0),
              itemCount: snapshot.data?.length,
              itemBuilder: (_, i) {
                return buildRuleItem(snapshot.data?[i] ?? '');
              },
            );
          } else {
            return AppCircularProgressIndicator();
          }
        });
  }

  Widget buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.fromLTRB(2, Dimens.margin_4, 0, 0),
            height: Dimens.margin_8,
            width: Dimens.margin_8,
            decoration: const BoxDecoration(
                color: AppColors.backgroundGrey500,
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_12))),
          ),
          const SizedBox(width: Dimens.padding_16),
          Flexible(
            child: Text(text, style: Get.textTheme.caption),
          ),
        ],
      ),
    );
  }

  Widget buildNoteWidget() {
    return StreamBuilder<String>(
        stream: _tdsDeductionDetailsCubit.tdsNote,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              margin: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, Dimens.padding_32, Dimens.padding_16, 0),
              padding: const EdgeInsets.all(Dimens.padding_12),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey300,
                border: Border.all(
                  color: AppColors.backgroundGrey300,
                ),
              ),
              child: Html(data: snapshot.data),
            );
          } else {
            return const SizedBox();
          }
        });
  }
}
