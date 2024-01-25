import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkImageLoader extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final FilterQuality? filterQuality;
  final BoxFit? fit;

  NetworkImageLoader({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.filterQuality,
    this.fit,
  }) : super(key: key) {}

  @override
  Widget build(BuildContext context) {
    return url.contains('.svg')
        ? SvgPicture.network(
            url,
            width: Dimens.imageWidth_48,
            height: Dimens.imageHeight_48,
            placeholderBuilder: (BuildContext context) =>
                Container(color: AppColors.backgroundGrey600),
            fit: BoxFit.cover,
          )
        : CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            filterQuality: FilterQuality.high,
            fit: fit,
            errorWidget: (context, url, error) =>
                Container(color: AppColors.backgroundGrey600),
          );
  }
}
