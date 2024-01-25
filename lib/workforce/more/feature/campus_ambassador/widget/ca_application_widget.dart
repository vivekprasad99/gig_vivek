import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/common/data_not_found.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/campus_ambassador/cubit/campus_ambassador_cubit.dart';
import 'package:awign/workforce/more/feature/campus_ambassador/widget/tile/ca_application_tile.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../onboarding/data/model/campus_ambassador/campus_ambassador_data.dart';

class CaApplicationWidget extends StatefulWidget {
  final CampusApplicationData campusApplicationData;
  const CaApplicationWidget({Key? key, required this.campusApplicationData})
      : super(key: key);

  @override
  State<CaApplicationWidget> createState() => _CaApplicationWidgetState();
}

class _CaApplicationWidgetState extends State<CaApplicationWidget> {
  final _campusAmbassadorCubit = sl<CampusAmbassadorCubit>();
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();

  @override
  void initState() {
    super.initState();
    if (widget.campusApplicationData.statusList != null) {
      _campusAmbassadorCubit.campusApplicationData =
          widget.campusApplicationData;
    }
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: 'application'.tr),
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
    return PaginationView<WorkApplicationEntity>(
        key: _paginationKey,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        paginationViewType: PaginationViewType.listView,
        itemBuilder: (BuildContext context,
            WorkApplicationEntity workApplicationEntity, int index) {
          return CaApplicationTile(
            workApplicationEntity: workApplicationEntity,
          );
        },
        pageFetch: _campusAmbassadorCubit.caApplicationSearch,
        onEmpty: Align(
          child: Text(
            "no_application".tr,
            style: Get.context?.textTheme.labelLarge?.copyWith(
                color: AppColors.black,
                fontSize: Dimens.font_18,
                fontWeight: FontWeight.w800),
          ),
        ),
        onError: (dynamic error) => Center(
              child: DataNotFound(),
            ),
        pageIndex: 1);
  }
}
