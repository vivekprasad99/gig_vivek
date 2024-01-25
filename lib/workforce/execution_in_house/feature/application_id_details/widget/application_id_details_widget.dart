import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/application_id_details/widget/tile/application_id_details_tile.dart';
import 'package:awign/workforce/execution_in_house/feature/application_id_details/widget/tile/resources_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/local/shared_preference_utils.dart';
import '../../../../core/data/model/user_data.dart';
import '../../../../core/widget/app_bar/default_app_bar.dart';
import '../../../../core/widget/network_sensitive/internet_sensitive.dart';
import '../../../data/model/execution.dart';
import '../../../data/model/resource.dart';
import '../cubit/application_id_details_cubit.dart';

class ApplicationIdDetailsWidget extends StatefulWidget {
  final Execution _execution;

  const ApplicationIdDetailsWidget(this._execution, {Key? key})
      : super(key: key);

  @override
  State<ApplicationIdDetailsWidget> createState() =>
      _ApplicationIdDetailsWidgetState();
}

class _ApplicationIdDetailsWidgetState
    extends State<ApplicationIdDetailsWidget> {
  final ApplicationIdDetailsCubit _applicationDetailsCubit =
      sl<ApplicationIdDetailsCubit>();
  UserData? _currentUser;
  bool isSkipSaasOrgID = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (spUtil!.getSaasOrgID()!.isEmpty) {
      isSkipSaasOrgID = true;
    }
    _applicationDetailsCubit.fetchResources(
        _currentUser!.id!,
        widget._execution
            .applicationIds![widget._execution.selectedProjectRole!]);
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
              title: 'application_details'.tr,
            ),
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
      child: InternetSensitive(
        child: StreamBuilder<UIStatus>(
            stream: _applicationDetailsCubit.uiStatus,
            builder: (context, uiStatus) {
              if (uiStatus.hasData &&
                  (uiStatus.data?.isOnScreenLoading ?? false)) {
                return AppCircularProgressIndicator();
              } else {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Dimens.padding_16,
                      Dimens.padding_16,
                      Dimens.padding_16,
                      Dimens.padding_16,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ApplicationIdDetailsTile(
                              widget._execution.applicationIds![
                                  widget._execution.selectedProjectRole!].toString(),
                              widget._execution.id),
                          const SizedBox(height: Dimens.margin_12),
                          buildResourceList()
                        ]),
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget buildResourceList() {
    return StreamBuilder<ResourceResponse>(
        stream: _applicationDetailsCubit.resourceModelStream,
        builder: (context, resourceListStream) {
          if (resourceListStream.hasData && resourceListStream.data != null) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 0),
              itemCount: resourceListStream.data?.resources?.length,
              itemBuilder: (_, i) {
                return ResourceTile(resourceListStream.data!.resources![i]);
              },
            );
          } else {
            return const SizedBox();
          }
        });
  }
}
