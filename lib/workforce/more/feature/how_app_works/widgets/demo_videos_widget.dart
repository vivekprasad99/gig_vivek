import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/how_app_works/cubit/how_app_works_cubit.dart';
import 'package:awign/workforce/more/feature/how_app_works/widgets/tile/demo_videos_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class DemoVideosWidget extends StatefulWidget {
  const DemoVideosWidget({Key? key}) : super(key: key);

  @override
  State<DemoVideosWidget> createState() => _DemoVideosWidgetState();
}

class _DemoVideosWidgetState extends State<DemoVideosWidget> {
  final HowAppWorksCubit _howAppWorksCubit =
  sl<HowAppWorksCubit>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _howAppWorksCubit.setRemoteConfig();
    subscribeUIStatus();
  }

  void subscribeUIStatus() {
    _howAppWorksCubit.uiStatus.listen(
          (uiStatus) {
        if (uiStatus.isOnScreenLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isOnScreenLoading) {
          Helper.hideLoadingDialog();
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
      mobile: buildMobileUI(context),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI(BuildContext context)
  {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      topPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
              isCollapsable: true,
              title: 'demo_videos'.tr,
            ),
          ];
        },
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context)
  {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: Padding(
  padding: const EdgeInsets.fromLTRB(
    Dimens.padding_16,
    Dimens.padding_16,
    Dimens.padding_16,
  Dimens.padding_16,
  ),
  child:
      Column(
        children: [
          Expanded(
            child: StreamBuilder<List>(
              stream: _howAppWorksCubit.firebaseRemoteConfig,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, i) {
                        return MyInkWell(
                            onTap: () {
                              MRouter.pushNamed(MRouter.showYtVideosWidget,
                                  arguments: snapshot.data![i]);
                            },
                            child: DemoVideosTile(
                              demoVideos: snapshot.data![i],));
                      }
                  );
                }else {
                  return const SizedBox();
                }
              }
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimens.padding_16),
            child: MyInkWell(
              onTap: (){
                MRouter.pushNamed(MRouter.faqAndSupportWidget, arguments: {});
              },
              child: RichText(
                text: TextSpan(
                  style: context.textTheme.bodyText1
                      ?.copyWith(color: AppColors.backgroundGrey800),
                  children: <TextSpan>[
                    const TextSpan(
                      text:
                      'Still have an ',
                    ),
                    TextSpan(
                      text: 'Unresolved Issue ?',
                      style: context.textTheme.bodyText1
                          ?.copyWith(color: AppColors.primaryMain),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      ),
      )
    );
  }
}
