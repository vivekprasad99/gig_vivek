import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../packages/flutter_image_editor/model/image_details.dart';
import '../../../core/router/router.dart';
import '../../../core/widget/buttons/my_ink_well.dart';
import '../../../core/widget/image_loader/network_image_loader.dart';
import '../../../core/widget/theme/theme_manager.dart';

class ImageDetailsWidget extends StatelessWidget {
  final ImageDetails imageDetails;
  const ImageDetailsWidget(this.imageDetails, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColors.black,
        body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: Dimens.padding_32),
          buildCloseIcon(),
          const SizedBox(height: Dimens.padding_16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildImageWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
          child: SvgPicture.asset('assets/images/ic_close_circle.svg'),
        ),
      ),
    );
  }

  Widget buildImageWidget() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.padding_8, 0, Dimens.padding_8, Dimens.padding_8),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_12)),
          child: imageDetails.url != null
              ? NetworkImageLoader(
            url: imageDetails.url!,
            filterQuality: FilterQuality.high,
            fit: BoxFit.fitWidth,
            // width: Dimens.imageWidth_56,
            // height: Dimens.imageHeight_56,
          )
              : (imageDetails.getFile() != null
              ? Image.file(
            imageDetails.getFile()!,
            // width: Dimens.imageWidth_56,
            // height: Dimens.imageHeight_56,
            fit: BoxFit.fitWidth,
          )
              : const SizedBox()),
        ),
      ),
    );
  }
}
