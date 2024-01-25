import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    Key? key,
    required this.child,
    this.showPadding = false,
  }) : super(key: key);

  final Widget child;
  final bool showPadding;

  @override
  Widget build(BuildContext context) {
    var _child = child;

    if (showPadding) {
      _child = Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Dimens.padding_24, horizontal: Dimens.padding_16),
        child: child,
      );
    } else {
      _child = child;
    }

    return Dialog(
      elevation: Dimens.elevation_8,
      insetAnimationCurve: Curves.easeInOut,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      insetPadding: const EdgeInsets.all(Dimens.padding_20),
      child: _child,
    );
  }
}

class CloseIcon extends StatelessWidget {
  const CloseIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: GestureDetector(
        child: Padding(
          padding: const EdgeInsets.only(
              top: Dimens.padding_16, right: Dimens.padding_16),
          child: Icon(
            Icons.close,
            size: Dimens.iconSize_16,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        onTap: () => MRouter.pop(null),
      ),
    );
  }
}
