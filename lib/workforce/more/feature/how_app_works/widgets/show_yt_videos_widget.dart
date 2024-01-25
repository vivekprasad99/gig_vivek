import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ShowYtVideosWidget extends StatefulWidget {
  final Map<String, dynamic> demoVideos;
  const ShowYtVideosWidget(this.demoVideos, {Key? key}) : super(key: key);

  @override
  State<ShowYtVideosWidget> createState() => _ShowYtVideosWidgetState();
}

class _ShowYtVideosWidgetState extends State<ShowYtVideosWidget> {
  late YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController(
      initialVideoId:
          YoutubePlayer.convertUrlToId(widget.demoVideos["video_url"]) ?? "",
      flags: const YoutubePlayerFlags(
        autoPlay: true,
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    controller.pause();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(context),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI(BuildContext context) {
    return YoutubePlayerBuilder(
      builder: (BuildContext, player) {
        return AppScaffold(
            backgroundColor: AppColors.primaryMain,
            bottomPadding: 0,
            topPadding: 0,
            body: Scaffold(
              appBar: AppBar(
                iconTheme: const IconThemeData(
                  color: AppColors.black,
                ),
                backgroundColor: AppColors.backgroundWhite,
                title: Text(
                  widget.demoVideos["video_title"],
                  style: Get.context?.textTheme.bodyText1
                      ?.copyWith(color: AppColors.black),
                ),
              ),
              body: buildBody(context, player),
            ));
      },
      player: YoutubePlayer(
        controller: controller,
      ),
    );
  }

  Widget buildBody(BuildContext context, Widget player) {
    return InternetSensitive(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16,
          Dimens.padding_24,
          Dimens.padding_16,
          Dimens.padding_16,
        ),
        child: Column(
          children: [
            player,
            const SizedBox(height: Dimens.margin_12),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimens.padding_48),
              child: Text(
                widget.demoVideos["video_description"],
                textAlign: TextAlign.center,
                style: Get.context?.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.backgroundGrey900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
