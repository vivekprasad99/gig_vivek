import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../../auth/data/model/pan_details_entity.dart';
import '../../../../../../core/router/router.dart';
import '../../../../../../core/utils/string_utils.dart';
import '../../../../../../core/widget/buttons/my_ink_well.dart';

void showPANDetailsBottomSheet(BuildContext context, DocumentDetailsData? documentDetailsData) {
  showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return PANDetailsBottomSheet(documentDetailsData);
      });
}

class PANDetailsBottomSheet extends StatelessWidget {
  final DocumentDetailsData? documentDetailsData;
  const PANDetailsBottomSheet(this.documentDetailsData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String panNumber = StringUtils.maskString(documentDetailsData?.panDetails?.panNumber ?? '', 2, 2);
    String panName = documentDetailsData?.panDetails?.panName ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_32,
        Dimens.padding_16,
        Dimens.padding_16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildTitle(context),
              buildCloseIcon(),
            ],
          ),
          const SizedBox(height: Dimens.padding_24),
          buildLabelWithAnswer(context, '${'pan_number'.tr} :', panNumber),
          const SizedBox(height: Dimens.padding_16),
          buildLabelWithAnswer(context, '${'pan_name'.tr} :', panName),
          const SizedBox(height: Dimens.padding_32),
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    String title = 'pan_card_details'.tr;
    return Text(title,
        style: context.textTheme.bodyText1?.copyWith(
            color: AppColors.backgroundGrey800,
            fontWeight: FontWeight.w700,
            fontSize: Dimens.font_18));
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
              Dimens.padding_16, 0, 0, 0),
          child: SvgPicture.asset('assets/images/ic_close_circle.svg'),
        ),
      ),
    );
  }

  Widget buildLabelWithAnswer(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(label,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyText1?.copyWith(
                color: AppColors.backgroundBlack,
                fontWeight: FontWeight.w500,
                fontSize: Dimens.font_14)),
        const SizedBox(width: Dimens.padding_4),
        Text(value,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyText1?.copyWith(
                color: AppColors.backgroundBlack,
                fontWeight: FontWeight.w400,
                fontSize: Dimens.font_14)),
      ],
    );
  }
}
