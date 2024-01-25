import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class MobileOnDesktopWidget extends StatelessWidget {
  final Widget mobileWidget;
  const MobileOnDesktopWidget(this.mobileWidget, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: SizedBox(
          width: Dimens.mobileWidth,
          height: Dimens.mobileHeight,
          child: mobileWidget,
        ),
      ),
    );
  }
}
