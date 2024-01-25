import 'package:awign/workforce/core/widget/padding/padding_utils.dart';
import 'package:flutter/material.dart';

class DynamicallySizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const DynamicallySizedBox({this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width == null ? null : PaddingUtils.getPadding(context, padding: width!),
      height: height == null ? null : PaddingUtils.getPadding(context, padding: height!),
      child: child,
    );
  }
}
