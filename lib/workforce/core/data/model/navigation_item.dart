import 'package:flutter/material.dart';

class NavigationItem {
  final IconData? iconData;
  final String? iconUrl;
  final String? text;
  final String? navigateTo;
  final double? padding;
  final String? gifUrl;

  NavigationItem({
    this.iconData,
    this.iconUrl,
    this.padding = 0,
    this.text,
    this.navigateTo,
    this.gifUrl,
  });
}
