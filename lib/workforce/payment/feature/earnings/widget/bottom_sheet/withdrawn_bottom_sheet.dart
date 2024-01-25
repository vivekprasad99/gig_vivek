import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/browser_helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/constants.dart';

void showWithdrawnBottomSheet(BuildContext context,double? amount) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return  WithdrawnBottomSheetWidget(amount: amount);
    },
  );
}

class WithdrawnBottomSheetWidget extends StatefulWidget {
  final double? amount;
  const WithdrawnBottomSheetWidget({Key? key,required this.amount}) : super(key: key);

  @override
  State<WithdrawnBottomSheetWidget> createState() =>
      WithdrawnBottomSheetWidgetState();
}

class WithdrawnBottomSheetWidgetState
    extends State<WithdrawnBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: Dimens.padding_48,
        top: Dimens.padding_24,
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/loader.gif",height: Dimens.padding_88,),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
              child: Text(
                'withdrawal_request_initiated'.tr,
                textAlign: TextAlign.center,
                style: Get.textTheme.headline7Bold,
              ),
            ),
            const SizedBox(
              height: Dimens.padding_16,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimens.padding_24, Dimens.padding_8, Dimens.padding_24, 0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'withdrawl_initiated'.tr,
                      style: Get.textTheme.bodyText1
                          ?.copyWith(color: AppColors.backgroundBlack)
                    ),
                    TextSpan(
                        text: ' ${StringUtils.getIndianFormatNumber(widget.amount)}',
                        style: Get.textTheme.bodyText1
                            ?.copyWith(color: AppColors.backgroundBlack)
                    ),
                    TextSpan(
                      text: 'it_usually_takes'.tr,
                      style: Get.textTheme.bodyText1
                          ?.copyWith(color: AppColors.backgroundBlack)
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: Dimens.padding_8,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
              child: MyInkWell(
                onTap:
                    () {
                      BrowserHelper.customTab(
                          context, "https://www.awign.com/terms_and_conditions");
                    },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'terms_and_condition_applied'.tr,
                        style: Get.context!.textTheme.bodyText2?.copyWith(color: AppColors.primaryMain, fontWeight: FontWeight.w400, fontSize: Dimens.font_10)),
                    const Icon(Icons.arrow_forward,color: AppColors.primaryMain,size: 12,),
                  ],
                ),
              ),
            ),
            buildOKButton(),
          ],
      ),
    );
  }

  Widget buildOKButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_32, Dimens.padding_24, Dimens.padding_32, 0),
      child: RaisedRectButton(
        text: 'okay'.tr,
        onPressed: () {
          MRouter.pop(null);
        },
      ),
    );
  }
}
