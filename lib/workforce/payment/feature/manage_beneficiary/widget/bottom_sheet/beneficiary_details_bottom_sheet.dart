import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/beneficiary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showBeneficiaryDetailsBottomSheet(
    BuildContext context, Beneficiary beneficiary) {
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
      return BeneficiaryDetailsBottomSheetWidget(beneficiary);
    },
  );
}

class BeneficiaryDetailsBottomSheetWidget extends StatefulWidget {
  final Beneficiary beneficiary;

  const BeneficiaryDetailsBottomSheetWidget(this.beneficiary, {Key? key})
      : super(key: key);

  @override
  State<BeneficiaryDetailsBottomSheetWidget> createState() =>
      BeneficiaryDetailsBottomSheetWidgetState();
}

class BeneficiaryDetailsBottomSheetWidgetState
    extends State<BeneficiaryDetailsBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.radius_16),
              topRight: Radius.circular(Dimens.radius_16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'beneficiary_details'.tr,
                      textAlign: TextAlign.center,
                      style: Get.textTheme.headline7Bold,
                    ),
                    buildCloseIcon(),
                  ],
                ),
              ),
              buildLabelValueWidgets(
                  'bank_name'.tr, widget.beneficiary.bankName ?? ''),
              const SizedBox(height: Dimens.padding_16),
              buildLabelValueWidgets(
                  'beneficiary_name'.tr, widget.beneficiary.name ?? ''),
              const SizedBox(height: Dimens.padding_16),
              buildLabelValueWidgets(
                  'account_number'.tr, widget.beneficiary.bankAccount ?? ''),
              const SizedBox(height: Dimens.padding_16),
              buildLabelValueWidgets(
                  'ifsc_code'.tr, widget.beneficiary.ifsc ?? ''),
              const SizedBox(height: Dimens.padding_16),
            ],
          ),
        );
      },
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: const Icon(Icons.close),
      ),
    );
  }

  Widget buildLabelValueWidgets(String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Get.textTheme.bodyText1)),
          Expanded(child: Text(value, style: Get.textTheme.bodyText1)),
        ],
      ),
    );
  }
}
