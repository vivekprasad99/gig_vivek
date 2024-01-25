import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaddingUtils {
  /// Returns a dynamic padding that scales depending on the size of the screen
  static double getPadding(BuildContext context, {double padding = 16.0}) => context.width * padding / 375;
}
