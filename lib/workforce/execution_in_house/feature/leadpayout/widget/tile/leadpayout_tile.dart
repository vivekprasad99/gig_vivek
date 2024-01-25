import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/earning_breakup_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class LeadPayoutTile extends StatelessWidget {
  final EarningBreakupEntity earningBreakupEntity;
  const LeadPayoutTile({Key? key,required this.earningBreakupEntity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String url = getFileType(earningBreakupEntity.status!);
    return Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.padding_16, 0, Dimens.padding_16, Dimens.padding_8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radius_8),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  earningBreakupEntity.name ?? "",
                  style: Get.context?.textTheme.labelLarge?.copyWith(
                      color: AppColors.black,
                      fontSize: Dimens.font_16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Dimens.padding_8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(url),
                        const SizedBox(width: Dimens.padding_8),
                        Text(
                          earningBreakupEntity.status!.toCapitalized() ?? "",
                          style: Get.context?.textTheme.labelLarge?.copyWith(
                              color: AppColors.black,
                              fontSize: Dimens.font_14,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "${Constants.rs} ${earningBreakupEntity.total ?? ""}",
                          style: Get.context?.textTheme.labelLarge?.copyWith(
                              color: AppColors.black,
                              fontSize: Dimens.font_14,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: Dimens.padding_8),
                        const Icon(Icons.chevron_right,
                            color: AppColors.backgroundGrey800)
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    );
  }

  String getFileType(String filetype) {
    switch (filetype) {
      case "processing":
        return "assets/images/rectangle_orange.svg";
      case "redeemed":
        return "assets/images/rectangle_green.svg";
      case "withdrawable":
        return "assets/images/rectangle_blue.svg";
      case "partiallyredeemed":
        return "assets/images/rectangle_green_white.svg";
      case "partiallywithdrawable":
        return "assets/images/rectangle_blue_white.svg";
      default:
        return "assets/images/image.svg";
    }
  }
}
