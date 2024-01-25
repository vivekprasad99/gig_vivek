import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showProvideAvailabilityBottomSheet(
    BuildContext context, Map<String, dynamic> availabilityCleverTapEvent) {
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
        return AvailabilityWidgetBottomSheet(availabilityCleverTapEvent);
      }).whenComplete(() async {
    await MRouter.pop(null);
    ClevertapHelper.instance().addCleverTapEvent(
        ClevertapHelper.provideAvailabilityClose, availabilityCleverTapEvent);
  });
}

class AvailabilityWidgetBottomSheet extends StatefulWidget {
  final Map<String, dynamic> availabilityCleverTapEvent;
  const AvailabilityWidgetBottomSheet(this.availabilityCleverTapEvent,
      {Key? key})
      : super(key: key);

  @override
  State<AvailabilityWidgetBottomSheet> createState() =>
      _AvailabilityWidgetBottomSheetState();
}

class _AvailabilityWidgetBottomSheetState
    extends State<AvailabilityWidgetBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_20, Dimens.margin_32,
          Dimens.padding_20, Dimens.padding_16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.yellow,
            child: SvgPicture.asset(
              'assets/images/ic_calendar.svg',
            ),
          ),
          const SizedBox(height: Dimens.margin_12),
          Text('provide_availability'.tr,
              style: Get.context?.textTheme.titleLarge),
          const SizedBox(height: Dimens.margin_12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
            child: Text(
              'availability_description'.tr,
              textAlign: TextAlign.center,
              style: Get.context?.textTheme.labelLarge?.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: Dimens.font_14),
            ),
          ),
          const SizedBox(height: Dimens.margin_32),
          RaisedRectButton(
              text: 'select_time_slot'.tr,
              onPressed: () async {
                MRouter.pushNamed(MRouter.provideAvailabilityWidget,
                    arguments: widget.availabilityCleverTapEvent);
              },
              backgroundColor: AppColors.primaryMain),
          const SizedBox(height: Dimens.margin_16),
        ],
      ),
    );
  }
}
