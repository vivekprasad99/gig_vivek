import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class AppLinearProgressIndicator extends StatelessWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;
  final double minHeight;
  const AppLinearProgressIndicator({this.value = 0, this.backgroundColor = AppColors.secondary2Default, this.valueColor = AppColors.secondary, this.minHeight = Dimens.linearCircularIndicatorHeight_8, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(valueColor),
            backgroundColor: backgroundColor,
            value: value,
            minHeight: minHeight,
          ),
          const SizedBox(height: Dimens.margin_8),
          //Text('Loading...', style: Styles.body1TextStyle)
        ],
      ),
    );
  }
}
