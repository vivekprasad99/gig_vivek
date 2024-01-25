import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class TakeATourWidget extends StatelessWidget {
  final Widget child;
  final GlobalKey globalKey;
  final Widget buildShowContainer;
  final double width;
  final double height;

  const TakeATourWidget({
    Key? key,
    required this.child,
    required this.globalKey,
    required this.buildShowContainer,
    this.width = 380,
    this.height = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Showcase.withWidget(
      key: globalKey,
      container: buildShowContainer,
      disableMovingAnimation: true,
      height: height,
      width: Get.width,
      child: child,
    );
  }
}
