import 'package:awign/workforce/core/widget/divider/v_divider.dart';
import 'package:awign/workforce/core/widget/shimmer/shimmer_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class CategoryApplicationShimmerTile extends StatelessWidget {
  const CategoryApplicationShimmerTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_8),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, Dimens.padding_16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                              width: Dimens.padding_60, height: Dimens.font_12),
                          Container(
                            height: 14,
                            margin: const EdgeInsets.symmetric(
                                horizontal: Dimens.margin_8),
                            child: VDivider(),
                          ),
                          const ShimmerWidget.rectangular(
                              width: Dimens.padding_80, height: Dimens.font_12),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Dimens.margin_16),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                        Dimens.padding_16,
                        Dimens.padding_12,
                        Dimens.padding_16,
                        Dimens.padding_12),
                    margin: const EdgeInsets.fromLTRB(
                        Dimens.margin_24, Dimens.margin_20, Dimens.margin_8, 0),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.backgroundGrey300),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(Dimens.radius_8))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerWidget.rectangular(height: Dimens.font_16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              0, Dimens.padding_8, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              ShimmerWidget.rectangular(
                                  height: Dimens.font_16, width: Dimens.padding_60),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                        Dimens.padding_16,
                        Dimens.padding_12,
                        Dimens.padding_16,
                        Dimens.padding_16),
                    margin: const EdgeInsets.fromLTRB(
                        Dimens.margin_8, Dimens.margin_20, Dimens.margin_24, 0),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.backgroundGrey300),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(Dimens.radius_8))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerWidget.rectangular(height: Dimens.font_16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              0, Dimens.padding_8, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              ShimmerWidget.rectangular(
                                  height: Dimens.font_16, width: Dimens.padding_60),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            buildViewJobsButton()
          ]),
        ),
      ),
    );
  }

  Widget buildViewJobsButton() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(Dimens.margin_24, Dimens.margin_24,
          Dimens.margin_24, 0),
      child: ShimmerWidget.rectangular(height: Dimens.padding_40),
    );
  }

  Widget buildCategoryIcon() {
    return const ShimmerWidget.rectangular(
        width: Dimens.imageWidth_48, height: Dimens.imageHeight_48);
  }
}
