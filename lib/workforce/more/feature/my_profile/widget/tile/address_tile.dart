import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class AddressTile extends StatelessWidget {
  final int index;
  final Address address;

  const AddressTile({Key? key, required this.index, required this.address})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimens.margin_16),
      decoration: BoxDecoration(
          color: context.theme.textFieldBackgroundColor,
          border: Border.all(
            color: context.theme.textFieldBackgroundColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_8))),
      padding: const EdgeInsets.all(Dimens.padding_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${'address'.tr} ${index + 1}', style: context.textTheme.bodyText1),
          const SizedBox(height: Dimens.margin_16),
          TextFieldLabel(label: '${address.area}, ${address.city}, ${address.state}'),
        ],
      ),
    );
  }
}
