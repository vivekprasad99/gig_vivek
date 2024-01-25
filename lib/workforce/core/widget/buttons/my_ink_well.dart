import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class MyInkWell extends StatelessWidget {
  final Function onTap;
  final Widget child;
  final double borderRadius;
  final bool excludeFromSemantics;

  const MyInkWell({
    required this.onTap,
    required this.child,
    this.borderRadius = Dimens.radius_8,this.excludeFromSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: () {
                onTap();
              },
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: AppColors.secondary.withOpacity(0.5),
              excludeFromSemantics: excludeFromSemantics,
            ),
          ),
        ),
      ],
    );
  }
}
