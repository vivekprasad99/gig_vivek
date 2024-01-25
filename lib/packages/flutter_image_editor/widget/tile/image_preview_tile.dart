import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/core/widget/image_loader/network_image_loader.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class ImagePreviewTile extends StatelessWidget {
  final ImageDetails imageDetails;
  const ImagePreviewTile(this.imageDetails, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: imageDetails.rotationAngle ?? 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_16)),
        child: imageDetails.getFile() != null
            ? Image.file(
                imageDetails.getFile()!,
                fit: BoxFit.fitWidth,
              )
            : NetworkImageLoader(
                url: imageDetails.url!,
                filterQuality: FilterQuality.high,
                fit: BoxFit.fitWidth,
              ),
      ),
    );
  }
}
