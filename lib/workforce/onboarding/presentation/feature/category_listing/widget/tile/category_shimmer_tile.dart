import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/divider/v_divider.dart';
import 'package:awign/workforce/core/widget/shimmer/shimmer_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class CategoryShimmerTile extends StatelessWidget {
  const CategoryShimmerTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_8),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              0, Dimens.padding_16, 0, Dimens.padding_8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: Dimens.margin_16),
                  buildCategoryIcon(),
                  const SizedBox(width: Dimens.margin_16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ShimmerWidget.rectangular(height: Dimens.font_16),
                        const SizedBox(height: Dimens.margin_8),
                        Row(
                          children: [
                            const ShimmerWidget.rectangular(
                                width: Dimens.padding_60,
                                height: Dimens.font_12),
                            Container(
                              height: 14,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: Dimens.margin_8),
                              child: VDivider(),
                            ),
                            const ShimmerWidget.rectangular(
                                width: Dimens.padding_80,
                                height: Dimens.font_12),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimens.margin_16),
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                    Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
                child: ShimmerWidget.rectangular(height: Dimens.font_14),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                    Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
                child: ShimmerWidget.rectangular(height: Dimens.font_14),
              ),
              const SizedBox(height: Dimens.margin_16),
              HDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  buildShareIconButton(context),
                  const SizedBox(width: Dimens.margin_16),
                  buildViewIconButton(context),
                  const SizedBox(width: Dimens.margin_16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoryIcon() {
    return const ShimmerWidget.rectangular(
        width: Dimens.imageWidth_48, height: Dimens.imageHeight_48);
  }

  Widget buildShareIconButton(BuildContext context) {
    return SizedBox(
      height: Dimens.btnHeight_40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Dimens.padding_8,
                ),
                child: ShimmerWidget.rectangular(
                    width: Dimens.padding_60, height: Dimens.padding_32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildViewIconButton(BuildContext context) {
    return SizedBox(
      height: Dimens.btnHeight_40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Dimens.padding_8,
                ),
                child: ShimmerWidget.rectangular(
                    width: Dimens.padding_60, height: Dimens.padding_32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
