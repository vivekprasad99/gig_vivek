import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/custom_dialog.dart';
import 'package:awign/workforce/core/widget/dialog/select_stream_dialog/widget/stream_tile.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

void showSelectStreamDialog(BuildContext context, Function(String?, bool) onStreamTap) {
  showDialog<bool>(
    context: context,
    builder: (_) => CustomDialog(
      child: SelectStreamDialog(onStreamTap),
    ),
  );
}

class SelectStreamDialog extends StatelessWidget {
  Function(String?, bool) onStreamTap;
  var streamList = [
    'engineering'.tr,
    'management_and_business_administration'.tr,
    'arts'.tr,
    'science'.tr,
    'commerce'.tr,
    'humanities'.tr,
    'social_science'.tr,
    'information_technology'.tr,
    'computer_applications'.tr,
    'architecture'.tr,
    'fashion_and_design'.tr,
    'mass_communication'.tr,
    'media'.tr,
    'journalism'.tr,
    'design'.tr,
    'animation'.tr,
    'hotel_management'.tr,
    'hospitality'.tr,
    'travel_and_tourism'.tr,
    'teaching_or_educational'.tr,
    'performing_arts'.tr,
    'banking'.tr,
    'agriculture'.tr,
    'aviation'.tr,
    'law'.tr,
    'medical'.tr,
    'dental'.tr,
    'pharmacy'.tr,
    'nursing'.tr,
    'paramedical'.tr,
    'veterinary_sciences'.tr,
    'dance'.tr,
    'music'.tr,
    'acting_or_drama'.tr,
    'sports'.tr,
    'distance_education'.tr,
    'polytechnic_or_diploma'.tr,
    'iti'.tr,
    'vocational_training'.tr,
    'others'.tr,
  ];

  SelectStreamDialog(this.onStreamTap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_32)),
      ),
      child: InternetSensitive(
        child: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimens.padding_8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildTitle(context),
              buildCloseIcon(),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: streamList.length,
              itemBuilder: (_, i) {
                return StreamTile(
                  index: i,
                  stream: streamList[i],
                  onStreamTap: (index, stream) {
                    if(index == streamList.length - 1) {
                      onStreamTap(stream, true);
                    } else {
                      onStreamTap(stream, false);
                    }
                    MRouter.pop(null);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Dimens.padding_16),
      child: Text('select_degree'.tr, style: Get.textTheme.headline7Bold),
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: const Padding(
          padding: EdgeInsets.all(Dimens.padding_16),
          child: Icon(Icons.close),
        ),
      ),
    );
  }
}
