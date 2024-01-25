import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DesktopComingSoonWidget extends StatelessWidget {
  const DesktopComingSoonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCircularProgressIndicator(),
            Text(
              'Coming Soon...',
              style: Get.context?.textTheme.bodyText1,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
