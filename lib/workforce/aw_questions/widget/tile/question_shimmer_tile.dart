import 'package:awign/workforce/core/widget/shimmer/shimmer_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class QuestionShimmerTile extends StatelessWidget {
  const QuestionShimmerTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_8),
        ),
        child: Container(
          padding: const EdgeInsets.all(Dimens.padding_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const ShimmerWidget.circular(
                      width: Dimens.radius_20, height: Dimens.radius_20),
                  const SizedBox(width: Dimens.margin_16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerWidget.rectangular(height: Dimens.padding_20),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimens.margin_16),
                  const ShimmerWidget.circular(
                      width: Dimens.radius_8, height: Dimens.radius_8),
                ],
              ),
              const SizedBox(height: Dimens.margin_16),
              const ShimmerWidget.rectangular(height: Dimens.etHeight_48),
            ],
          ),
        ),
      ),
    );
  }
}
