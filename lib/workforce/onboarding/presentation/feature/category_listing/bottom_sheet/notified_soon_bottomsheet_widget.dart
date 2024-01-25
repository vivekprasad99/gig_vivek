import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../../core/router/router.dart';
import '../../../../../core/widget/buttons/my_ink_well.dart';
import '../../../../../core/widget/theme/theme_manager.dart';

void showNotifiedSooBottomSheet(BuildContext context) {
  showModalBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return const NotifiedSoonBottomSheet();
      });
}

class NotifiedSoonBottomSheet extends StatelessWidget {
  const NotifiedSoonBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: Dimens.margin_32, horizontal: Dimens.margin_16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: MyInkWell(
                  onTap: () async {
                    MRouter.pop(null);
                  },
                  child:
                      SvgPicture.asset('assets/images/ic_close_circle.svg'))),
          SvgPicture.asset('assets/images/notified_soon.svg'),
          const SizedBox(
            height: Dimens.margin_24,
          ),
          Text(
            'you_will_be_notified_soon'.tr,
            style: const TextStyle(
                fontSize: Dimens.font_24,
                color: AppColors.primaryMain,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: Dimens.margin_16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.margin_16),
            child: Text(
              'notify_when_jobs_available'.tr,
              style: Get.textTheme.bodyText1?.copyWith(
                color: AppColors.textColor,
                fontSize: Dimens.font_14,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
