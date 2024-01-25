import 'package:awign/workforce/core/widget/shimmer/shimmer_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class ExecutionShimmerTile extends StatelessWidget {
  const ExecutionShimmerTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_16),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  buildIcon(),
                  buildMarkAndText(),
                  const SizedBox(width: Dimens.padding_16),
                ],
              ),
              buildProjectName(),
              buildProjectDescription(),
              buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIcon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: ShimmerWidget.rectangular(
          width: Dimens.imageWidth_48, height: Dimens.imageHeight_48),
    );
  }

  Widget buildMarkAndText() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          ShimmerWidget.circular(
              width: Dimens.margin_12, height: Dimens.margin_12),
          SizedBox(width: Dimens.padding_8),
          ShimmerWidget.rectangular(
              width: Dimens.margin_80, height: Dimens.margin_16),
        ],
      ),
    );
  }

  Widget buildProjectName() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: ShimmerWidget.rectangular(height: Dimens.padding_16, width: double.infinity),
    );
  }

  Widget buildProjectDescription() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
      child: ShimmerWidget.rectangular(width: double.infinity, height: Dimens.padding_12),
    );
  }

  Widget buildButton() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_24,
          Dimens.margin_16, Dimens.margin_16),
      child: ShimmerWidget.rectangular(width: double.infinity, height: Dimens.padding_48),
    );
  }
}
