import 'dart:io';

import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final double? leftPadding;
  final double? topPadding;
  final double? rightPadding;
  final double? bottomPadding;

  const AppScaffold({
    Key? key,
    required this.body,
    this.floatingActionButton,
    this.backgroundColor,
    this.leftPadding,
    this.topPadding,
    this.rightPadding,
    this.bottomPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: InkWell(
        focusColor: backgroundColor,
        splashColor: backgroundColor,
        highlightColor: backgroundColor,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: buildPaddingAccordingToPlatform(body),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget buildPaddingAccordingToPlatform(Widget body) {
    if (kIsWeb) {
      return body;
    } else if (Platform.isIOS) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
            leftPadding ?? 0,
            topPadding ?? Dimens.padding_16,
            rightPadding ?? 0,
            bottomPadding ?? Dimens.padding_16),
        child: body,
      );
    } else {
      return body;
    }
  }
}
