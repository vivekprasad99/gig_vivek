import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../core/widget/buttons/my_ink_well.dart';

class DemoVideosTile extends StatelessWidget {
  Map<String,dynamic> demoVideos;
  DemoVideosTile({Key? key,required this.demoVideos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: const EdgeInsets.only(left: 0),
      visualDensity: const VisualDensity(
        horizontal: -4,
      ),
      leading: Container(
          padding:  const EdgeInsets.all(Dimens.padding_16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.radius_8),
            color: AppColors.backgroundGrey400,
          ),
          child: SvgPicture.asset('assets/images/yt_video.svg',width: 20,)),
      title: Text(
        demoVideos["video_title"],
        style: Get.context?.textTheme.bodyMedium
            ?.copyWith(color: AppColors.backgroundGrey800),
      ),
    );
  }
}
