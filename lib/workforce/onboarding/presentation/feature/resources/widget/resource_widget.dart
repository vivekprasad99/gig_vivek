import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/resource.dart';
import 'package:awign/workforce/execution_in_house/feature/application_id_details/widget/tile/resources_tile.dart';
import 'package:awign/workforce/onboarding/presentation/feature/resources/cubit/resource_cubit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ResourceWidget extends StatefulWidget {
  final int? applicationId;
  const ResourceWidget(this.applicationId,{Key? key}) : super(key: key);

  @override
  State<ResourceWidget> createState() => _ResourceWidgetState();
}

class _ResourceWidgetState extends State<ResourceWidget> {
  final ResourceCubit _resourceCubit = sl<ResourceCubit>();
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
    _resourceCubit.fetchResources(
        _currentUser!.id!,
        widget.applicationId!);
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
              title: 'resources'.tr,
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
            stream: _resourceCubit.uiStatus,
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
                        children: [buildResourceList()]),
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget buildResourceList() {
    return StreamBuilder<ResourceResponse>(
        stream: _resourceCubit.resourceModelStream,
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
