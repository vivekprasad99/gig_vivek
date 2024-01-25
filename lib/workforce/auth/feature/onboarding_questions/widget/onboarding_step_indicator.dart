import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class OnboardingStepIndicator extends StatelessWidget {
  final int screenCount;
  final int screenOrder;
  const OnboardingStepIndicator(this.screenCount, this.screenOrder, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> steps = [];
    for (int i = 1; i <= screenCount; i++) {
      steps.add(buildStepWidget(i));
    }
    return buildSteps(steps);
  }

  Widget buildSteps(List<Widget> steps) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
      child: Row(
        children: steps,
      ),
    );
  }

  Widget buildStepWidget(int index) {
    return Expanded(
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(
                Dimens.padding_8, 0, Dimens.padding_8, 0),
            height: 8,
            decoration: BoxDecoration(
              color: index < screenOrder - 1
                  ? AppColors.success400
                  : AppColors.backgroundGrey300,
              borderRadius: const BorderRadius.all(
                Radius.circular(Dimens.radius_8),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(Dimens.padding_8, 0,
                index == screenOrder ? Dimens.padding_24 : Dimens.padding_8, 0),
            height: 8,
            decoration: BoxDecoration(
              color: index <= screenOrder
                  ? AppColors.success400
                  : AppColors.backgroundGrey300,
              borderRadius: const BorderRadius.all(
                Radius.circular(Dimens.radius_8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
