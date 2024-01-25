import 'package:awign/workforce/core/data/firebase/remote_config/remote_config_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_month_year_bottom_sheet/widget/select_month_year_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/earning_statement_entity.dart';
import 'package:awign/workforce/payment/feature/earning_statement/cubit/earning_statement_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/utils/file_utils.dart';
import '../../../../core/widget/buttons/raised_rect_button.dart';

class EarningStatementWidget extends StatefulWidget {
  const EarningStatementWidget({Key? key}) : super(key: key);

  @override
  _EarningStatementWidgetState createState() => _EarningStatementWidgetState();
}

class _EarningStatementWidgetState extends State<EarningStatementWidget> {
  final EarningStatementCubit _earningStatementCubit =
      sl<EarningStatementCubit>();
  UserData? _currentUser;
  SPUtil? spUtil;
  final TextEditingController _monthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() {
    _monthController.dispose();
    super.dispose();
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    // _earningStatementCubit.getBeneficiaries(_currentUser?.id ?? -1);
  }

  @override
  Widget build(BuildContext context) {
    return  buildBody();
  }

  Widget buildBody() {
    return Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildTitle(),
                const SizedBox(height: Dimens.padding_12,),
                buildDesc(),
                buildMonthSectionWidget(),
                buildPDFWidget(),
                buildDownloadPDFWidget()
              ],
            );
  }

  Widget buildTitle() {
    return Text(
      'earnings_overview'.tr,
      style: Get.textTheme.headline7SemiBold,
    );
  }

  Widget buildDesc() {
    return Text(
      'select_month_to_download_earning_statement'.tr,
      style: Get.textTheme.bodyMedium,
    );
  }

  Widget buildMonthSectionWidget() {
    return StreamBuilder<String>(
      stream: _earningStatementCubit.selectedMonth,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _monthController.text = snapshot.data!;
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            maxLines: 1,
            controller: _monthController,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: AppColors.backgroundGrey300,
              hintText: 'select_month'.tr,
              hintStyle: const TextStyle(color: AppColors.backgroundGrey600),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.backgroundGrey400),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.backgroundGrey400),
              ),
              suffixIcon: const Padding(
                padding: EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_8,
                    Dimens.margin_12, Dimens.margin_8),
                child: Icon(Icons.arrow_drop_down,
                    color: AppColors.backgroundBlack),
              ),
            ),
            onTap: () async {
              showSelectMonthYearBottomSheet(context, _onMonthYearSelected);
            },
            readOnly: true,
          ),
        );
      },
    );
  }

  _onMonthYearSelected(String selectedMonthYear) {
    _earningStatementCubit.changeSelectedMonth(selectedMonthYear);
    _earningStatementCubit.getEarningStatement(_currentUser?.id ?? -1);
  }

  Widget buildPDFWidget() {
    return StreamBuilder<List<WithdrawalStatement>>(
      stream: _earningStatementCubit.withdrawalStatementList,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          PdfController pdfController = PdfController(
            document: PdfDocument.openData(
                InternetFile.get(snapshot.data![0].documentUrl ?? '')),
          );
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
              child: PdfView(
                controller: pdfController,
                scrollDirection: Axis.vertical,
                builders: PdfViewBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(
                    loaderSwitchDuration: Duration(seconds: 1),
                  ),
                  documentLoaderBuilder: (_) =>
                      Center(child: AppCircularProgressIndicator()),
                  pageLoaderBuilder: (_) =>
                      Center(child: AppCircularProgressIndicator()),
                  errorBuilder: (_, error) => Center(
                      child: Text(error.toString(),
                          style: Get.textTheme.bodyText1)),
                ),
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data!.isEmpty) {
          return Expanded(child: AppCircularProgressIndicator());
        } else if (snapshot.hasError) {
          return buildNoEarningContainer();
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildNoEarningContainer() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CachedNetworkImage(
            width: Dimens.imageWidth_100,
            height: Dimens.imageHeight_100,
            imageUrl: Constants.noEarningsImage,
            filterQuality: FilterQuality.high,
            errorWidget: (context, url, error) =>
                Container(color: AppColors.backgroundGrey600),
          ),
          const SizedBox(height: Dimens.padding_16),
          Text(
            'no_earnings'.tr,
            style: Get.textTheme.headline7SemiBold
                .copyWith(color: AppColors.backgroundBlack),
          ),
          const SizedBox(height: Dimens.padding_16),
          Text(
            'you_have_not_earned_this_month'.tr,
            style: Get.textTheme.bodyText2
                ?.copyWith(color: AppColors.backgroundGrey800),
          ),
          const SizedBox(height: Dimens.padding_16),
          // buildAddBeneficiaryButton1(),
        ],
      ),
    );
  }

  Widget buildBottomWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
          Dimens.padding_16, Dimens.padding_32),
      child: buildNoteWidget(),
    );
  }

  Widget buildDownloadPDFWidget() {
    return StreamBuilder<List<WithdrawalStatement>>(
        stream: _earningStatementCubit.withdrawalStatementList,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            String pdfUrl = snapshot.data![0].documentUrl ?? '';
            return Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.margin_16,
                  Dimens.margin_24, Dimens.margin_16, Dimens.margin_16),
              child: RaisedRectButton(
                width: MediaQuery.of(context).size.width,
                height: Dimens.btnHeight_40,
                text: 'Download PDF',
                fontSize: Dimens.font_14,
                onPressed: () {
                  FileUtils.downloadFile(context, pdfUrl);
                },
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildNoteWidget() {
    if (!RemoteConfigHelper.instance()
        .earningStatementNoteMessage
        .isNullOrEmpty) {
      return Container(
        padding: const EdgeInsets.all(Dimens.padding_12),
        decoration: BoxDecoration(
          color: AppColors.warning100,
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_16)),
          border: Border.all(
            color: AppColors.warning200,
          ),
        ),
        child: Html(
          data: RemoteConfigHelper.instance().earningStatementNoteMessage,
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
