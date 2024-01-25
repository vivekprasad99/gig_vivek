import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/browser_helper.dart';
import '../../../../../core/widget/buttons/my_ink_well.dart';
import '../../../../../core/widget/theme/theme_manager.dart';
import '../../../../data/model/resource.dart';

class ResourceTile extends StatefulWidget {
  final Resource resources;

  const ResourceTile(this.resources, {Key? key}) : super(key: key);

  @override
  State<ResourceTile> createState() => _ResourcesTileState();
}

class _ResourcesTileState extends State<ResourceTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.resources.material!.isNotEmpty,
          child: Text(
            'resources'.tr,
            style: Get.context?.textTheme.titleLarge
                ?.copyWith(color: AppColors.black),
          ),
        ),
        const SizedBox(height: Dimens.margin_12),
        Visibility(
          visible: widget.resources.material!.isNotEmpty,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimens.radius_8),
            ),
            child: Container(
              padding: const EdgeInsets.all(Dimens.padding_16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.resources.stepName ?? '',
                    style: Get.context?.textTheme.titleLarge
                        ?.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: Dimens.margin_24),
                  buildMaterialList()
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMaterialList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 0),
      itemBuilder: (_, i) {
        var material = widget.resources.material![i];
        String url = getFileType(material.fileType!)["url"]!;
        String viewType = getFileType(material.fileType!)["viewType"]!;
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 0),
          leading: Container(
              padding: const EdgeInsets.all(Dimens.padding_4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.radius_8),
                color: AppColors.backgroundGrey400,
              ),
              child: SvgPicture.asset(url)),
          title: Text(
            material.title ?? '',
            style: Get.context?.textTheme.bodyText2
                ?.copyWith(color: AppColors.black),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: Dimens.padding_8),
            child: MyInkWell(
              onTap: () {
                BrowserHelper.customTab(context, material.filePath!);
              },
              child: Text(
                viewType,
                style: Get.context?.textTheme.bodyText2
                    ?.copyWith(color: AppColors.primaryMain),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: Dimens.margin_24);
      },
      itemCount: widget.resources.material!.length,
    );
  }

  Map<String, String> getFileType(String filetype) {
    switch (filetype) {
      case "image":
        return {"url": "assets/images/image.svg", "viewType": "View image"};
      case "file":
        return {"url": "assets/images/file.svg", "viewType": "View file"};
      case "pdf":
        return {"url": "assets/images/pdf.svg", "viewType": "View pdf"};
      case "audio":
        return {
          "url": "assets/images/microphone.svg",
          "viewType": "Play audio"
        };
      case "video":
        return {"url": "assets/images/video.svg", "viewType": "Play video"};
      case "youtube":
        return {"url": "assets/images/video.svg", "viewType": "View file"};
      case "google_drive":
        return {"url": "assets/images/video.svg", "viewType": "View file"};
      default:
        return {"url": "assets/images/image.svg", "viewType": "View image"};
    }
  }
}
