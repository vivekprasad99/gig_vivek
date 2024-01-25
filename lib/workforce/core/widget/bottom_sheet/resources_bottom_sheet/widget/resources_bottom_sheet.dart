import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../execution_in_house/feature/application_section_details/widget/application_section/attachment_section_resource_tile.dart';

void showResourcesBottomSheet(BuildContext context, AttachmentSection? attachmentSection, Function() onExitTap) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return ResourcesBottomSheetWidget(attachmentSection,onExitTap);
    },
  );
}

class ResourcesBottomSheetWidget extends StatelessWidget {
  final Function() onExitTap;
  final AttachmentSection? attachmentSection;

  const ResourcesBottomSheetWidget(this.attachmentSection,this.onExitTap, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0,
        0.0, MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeaderWidget(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Please study the file and continue the test',style: Get.textTheme.headline7
            .copyWith(color: AppColors.black),textAlign: TextAlign.start,),
          ),
          buildAttachmentTile(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedRectButton(text: 'Continue',onPressed: () {
              MRouter.pop(null);
            },),
          )
        ],
      ),
    );
  }

  Widget buildHeaderWidget() {
    return Hero(
      tag: 'ResourcesBottomSheet',
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: Container(
          padding: const EdgeInsets.all(Dimens.padding_16),
          decoration: const BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.radius_16),
              topRight: Radius.circular(Dimens.radius_16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb, color: AppColors.yellow, size: Dimens.iconSize_16),
                        const SizedBox(width: Dimens.padding_8),
                        Text(
                          'not_able_to_answer'.tr,
                          textAlign: TextAlign.center,
                          style: Get.textTheme.headline5?.copyWith(color: AppColors.backgroundWhite),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_drop_up, color: AppColors.backgroundWhite),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: Dimens.padding_24),
                child: Text(
                  'view_material'.tr,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodyText2?.copyWith(color: AppColors.backgroundWhite),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAttachmentTile() {
    if(attachmentSection?.attachments != null && attachmentSection!.attachments!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child:  ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attachmentSection!.attachments!.length,
            itemBuilder: (context, index) {
              return AttachmentSectionResourceTile(
                  attachment: attachmentSection!.attachments![index]);
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: Dimens.padding_20);
            },
          ),
        ),
      );
    } else {
      return Container(
        width: MediaQuery.of(Get.context!).size.width,
        height: 150,
        padding: const EdgeInsets.all(Dimens.padding_8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radius_8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimens.padding_16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/no_resources.svg',
                ),
                const SizedBox(height: Dimens.margin_8,),
                Text('no_resource'.tr)
              ],
            ),
          ),
        ),
      );
    }
  }
}
