import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSelectSignatureBottomSheet(
    BuildContext context, String name, Function(String?) onSubmitTap) {
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
      return SelectSignatureWidget(name, onSubmitTap);
    },
  );
}

class SelectSignatureWidget extends StatefulWidget {
  final String name;
  final Function(String?) onSubmitTap;
  static const arizonia = "arizonia";
  static const rochester = "rochester";
  static const markScript = "mark-script";

  const SelectSignatureWidget(this.name, this.onSubmitTap, {Key? key})
      : super(key: key);

  @override
  _SelectSignatureWidgetState createState() => _SelectSignatureWidgetState();
}

class _SelectSignatureWidgetState extends State<SelectSignatureWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: Dimens.padding_24),
                    child: Text(
                      'please_select_signature_you_want_to_add'.tr,
                      textAlign: TextAlign.center,
                      style: Get.textTheme.headline7Bold,
                    ),
                  ),
                ),
                buildCloseIcon(),
              ],
            ),
            const SizedBox(height: Dimens.margin_16),
            buildSignatureList(controller),
          ],
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
        child: const Padding(
          padding: EdgeInsets.all(Dimens.padding_16),
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildSignatureList(ScrollController scrollController) {
    return Expanded(
      child: ListView(
        controller: scrollController,
        children: [
          MyInkWell(
            onTap: () {
              widget.onSubmitTap(SelectSignatureWidget.arizonia);
              MRouter.pop(null);
            },
            child: buildSignatureItem(
              widget.name,
              Get.textTheme.bodyText1
                  ?.copyWith(fontFamily: SelectSignatureWidget.arizonia, fontSize: Dimens.font_36),
            ),
          ),
          MyInkWell(
            onTap: () {
              widget.onSubmitTap(SelectSignatureWidget.rochester);
              MRouter.pop(null);
            },
            child: buildSignatureItem(
              widget.name,
              Get.textTheme.bodyText1
                  ?.copyWith(fontFamily: SelectSignatureWidget.rochester, fontSize: Dimens.font_36),
            ),
          ),
          MyInkWell(
            onTap: () {
              widget.onSubmitTap(SelectSignatureWidget.markScript);
              MRouter.pop(null);
            },
            child: buildSignatureItem(
              widget.name,
              Get.textTheme.bodyText1
                  ?.copyWith(fontFamily: SelectSignatureWidget.markScript, fontSize: Dimens.font_36),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSignatureItem(String name, TextStyle? textStyle) {
    return Container(
      width: double.infinity,
      height: Dimens.margin_80,
      margin: const EdgeInsets.fromLTRB(
          Dimens.margin_16, 0, Dimens.margin_16, Dimens.margin_16),
      decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border.all(color: AppColors.backgroundGrey700)),
      child: Center(child: Text(name, style: textStyle)),
    );
  }
}
