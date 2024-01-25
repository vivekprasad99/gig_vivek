import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/common/data_not_found.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/campus_ambassador/cubit/campus_ambassador_cubit.dart';
import 'package:awign/workforce/more/feature/campus_ambassador/widget/tile/campus_ambassador_task_tile.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_data.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_entity.dart';
import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_response.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widget/buttons/my_ink_well.dart';

class OpenCaTaskWidget extends StatefulWidget {
  const OpenCaTaskWidget({Key? key}) : super(key: key);

  @override
  _OpenCaTaskWidgetState createState() => _OpenCaTaskWidgetState();
}

class _OpenCaTaskWidgetState extends State<OpenCaTaskWidget> {
  final _campusAmbassadorCubit = sl<CampusAmbassadorCubit>();
  UserData? _user;
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();
  String referralCode = "";

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void subscribeUIStatus() {
    _campusAmbassadorCubit.uiStatus.listen(
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

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _user = spUtil?.getUserData();
    _campusAmbassadorCubit.getCampusAmbassador(_user!.id!);
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
                isCollapsable: true, title: 'become_campus_ambassador'.tr),
          ];
        },
        body: buildBody(),
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
          stream: _campusAmbassadorCubit.uiStatus,
          builder: (context, uiStatus) {
            if (uiStatus.hasData && uiStatus.data!.isOnScreenLoading) {
              return AppCircularProgressIndicator();
            } else {
              return InternetSensitive(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Dimens.padding_16,
                        Dimens.padding_36,
                        Dimens.padding_16,
                        Dimens.padding_16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'referral'.tr,
                          style: Get.context?.textTheme.labelSmall?.copyWith(
                              color: AppColors.backgroundGrey700,
                              fontSize: Dimens.font_16,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: Dimens.margin_24),
                        buildReferralContainerCard(),
                        const SizedBox(height: Dimens.margin_24),
                        Text(
                          'my_task'.tr,
                          style: Get.context?.textTheme.labelSmall?.copyWith(
                              color: AppColors.backgroundGrey700,
                              fontSize: Dimens.font_16,
                              fontWeight: FontWeight.w500),
                        ),
                        buildTaskList(),
                      ],
                    ),
                  ),
                ),
              );
            }
          }),
    );
  }

  Widget buildTaskList() {
    return PaginationView(
      key: _paginationKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context,
              CampusAmbassadorTasks campusAmbassadorTasks, int index) =>
          CampusAmbassadorTaskTile(
        campusAmbassadorTasks: campusAmbassadorTasks,
        onViewTaskTap: (CampusAmbassadorTasks campusAmbassadorTasks) {
          CampusAmbassadorData campusAmbassadorData = CampusAmbassadorData(
            referralCode: referralCode,
            campusAmbassadorTasks: campusAmbassadorTasks,
          );
          MRouter.pushNamed(MRouter.caDashboardWidget,
              arguments: campusAmbassadorData);
        },
      ),
      paginationViewType: PaginationViewType.listView,
      pageIndex: 1,
      pageFetch: _campusAmbassadorCubit.getCATask,
      onError: (dynamic error) => Center(
        child: DataNotFound(),
      ),
      onEmpty: Align(
        child: Text(
          "no_task".tr,
          style: Get.context?.textTheme.labelLarge?.copyWith(
              color: AppColors.black,
              fontSize: Dimens.font_18,
              fontWeight: FontWeight.w800),
        ),
      ),
      bottomLoader: AppCircularProgressIndicator(),
    );
  }

  Widget buildReferralContainerCard() {
    return Card(
      child: Column(
        children: [
          buildReferralBanner(),
          const SizedBox(height: Dimens.margin_24),
          buildDashedBorder(
              Icons.copy_rounded, MainAxisAlignment.spaceBetween, [6, 2]),
          buildDashedBorder(Icons.share, MainAxisAlignment.center, [6, 0],
              name: "Share"),
        ],
      ),
    );
  }

  Widget buildDashedBorder(
      IconData icon, MainAxisAlignment space, List<double> dashPattern,
      {String? name}) {
    return StreamBuilder<CampusAmbassadorResponse>(
        stream: _campusAmbassadorCubit.campusAmbassdorResponse,
        builder: (context, campusAmbassdorResponse) {
          if (!campusAmbassdorResponse.hasData) {
            return const SizedBox();
          } else {
            referralCode = campusAmbassdorResponse.data!.referralCode ?? '';
            return name != null
                ? MyInkWell(
                    onTap: () {
                      _onShareTap(
                          campusAmbassdorResponse.data!.referralCode ?? '');
                    },
                    child:
                        referralCodebox(icon, space, dashPattern, name: name),
                  )
                : referralCodebox(icon, space, dashPattern,
                    name: campusAmbassdorResponse.data!.referralCode ?? '');
          }
        });
  }

  Widget referralCodebox(
      IconData icon, MainAxisAlignment space, List<double> dashPattern,
      {String? name}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_20, 0, Dimens.padding_20, Dimens.padding_16),
      child: DottedBorder(
        color: AppColors.success300,
        strokeWidth: 2,
        dashPattern: dashPattern,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            child: Row(
              mainAxisAlignment: space,
              children: name == "Share"
                  ? [
                      buildIcon(icon, AppColors.success300),
                      const SizedBox(width: Dimens.margin_12),
                      buildText(name!, AppColors.success300),
                    ]
                  : [
                      buildText(name!, AppColors.backgroundGrey700),
                      MyInkWell(
                          onTap: () {
                            final value = ClipboardData(text: name);
                            Clipboard.setData(value);
                            Helper.showInfoToast('text_copied'.tr);
                          },
                          child: buildIcon(icon, AppColors.backgroundGrey700)),
                    ],
            )),
      ),
    );
  }

  Widget buildText(String text, Color color) {
    return Text(
      text,
      style: Get.context?.textTheme.labelSmall?.copyWith(
          color: color, fontSize: Dimens.font_16, fontWeight: FontWeight.w400),
    );
  }

  Widget buildIcon(IconData icon, Color color) {
    return Icon(icon, color: color);
  }

  Widget buildReferralBanner() {
    return Image.asset('assets/images/ca_banner.png');
  }

  _onShareTap(String referralCode) async {
    try {
      var addString = "";
      addString = "Use my referral code: $referralCode";
      var sAux = 'parttime_desc'.tr;
      sAux += addString;
      sAux =
          "$sAux\n\nhttps://play.google.com/store/apps/details?id=com.awign.intern";
      await Share.share(sAux);
    } catch (e, st) {
      AppLog.e('Campus Ambassador: ${e.toString()} \n${st.toString()}');
    }
  }
}
