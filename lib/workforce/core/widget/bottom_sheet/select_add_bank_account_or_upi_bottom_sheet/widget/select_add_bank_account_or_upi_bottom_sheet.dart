import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AddBeneficiaryOption<String> extends Enum1<String> {
  const AddBeneficiaryOption(String val) : super(val);

  static const AddBeneficiaryOption bankAccount =
      AddBeneficiaryOption('bank_account');
  static const AddBeneficiaryOption upi = AddBeneficiaryOption('upi');
}

void showSelectAddBankAccountOrUPIBottomSheet(
    BuildContext context, Function(AddBeneficiaryOption) onSelectOption) {
  showModalBottomSheet(
    context: context,
    // isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return SelectAddBankAccountOrUPIWidget(onSelectOption);
          },
        ),
      );
    },
  );
}

class SelectAddBankAccountOrUPIWidget extends StatefulWidget {
  final Function(AddBeneficiaryOption) onSelectOption;

  const SelectAddBankAccountOrUPIWidget(this.onSelectOption, {Key? key})
      : super(key: key);

  @override
  State<SelectAddBankAccountOrUPIWidget> createState() =>
      SelectAddBankAccountOrUPIWidgetState();
}

class SelectAddBankAccountOrUPIWidgetState
    extends State<SelectAddBankAccountOrUPIWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildCloseIcon(),
          buildAddBankAccountWidget(),
          Padding(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            child: HDivider(dividerColor: AppColors.backgroundGrey300),
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
        child: const Padding(
          padding: EdgeInsets.all(Dimens.padding_16),
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildAddBankAccountWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
          widget.onSelectOption(AddBeneficiaryOption.bankAccount);
        },
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/ic_bank.svg',
                  ),
                  const SizedBox(width: Dimens.padding_12),
                  Text('add_bank_account'.tr,
                      style: Get.textTheme.bodyText1Medium
                          ?.copyWith(color: AppColors.backgroundBlack)),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/images/ic_arrow_right.svg',
            ),
          ],
        ),
      ),
    );
  }
}
