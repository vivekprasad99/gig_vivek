import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/padding/padding_utils.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ClickableImage extends StatelessWidget {
  final String url;
  final double size;
  final Function onTap;
  final double borderRadius;

  const ClickableImage({
    required this.url,
    required this.size,
    required this.onTap,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return MyInkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: RoundedImage(
        size: size,
        url: url,
        borderRadius: borderRadius,
      ),
    );
  }
}

class RoundedImage extends StatelessWidget {
  final String url;
  final double size;
  final bool dynamicallySized;
  final double borderRadius;
  final bool onlyTopBorderRadius;

  const RoundedImage({
    required this.size,
    required this.url,
    this.dynamicallySized = false,
    this.borderRadius = 8.0,
    this.onlyTopBorderRadius = false,
  });

  @override
  Widget build(BuildContext context) {
    final newSize = dynamicallySized
        ? PaddingUtils.getPadding(context, padding: size)
        : size;
    return ClipRRect(
      borderRadius: onlyTopBorderRadius
          ? BorderRadius.vertical(top: Radius.circular(borderRadius))
          : BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        filterQuality: FilterQuality.high,
        height: newSize,
        width: newSize,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) =>
            Container(color: AppColors.backgroundGrey600),
      ),
    );
  }
}
