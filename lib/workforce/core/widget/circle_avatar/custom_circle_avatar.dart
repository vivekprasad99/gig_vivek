import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String? url;
  final String? name;
  final double radius;

  const CustomCircleAvatar(
      {Key? key, this.url, this.name, this.radius = Dimens.radius_32})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(url!),
        backgroundColor: Colors.transparent,
      );
    } else {
      String firstChar = name != null ? name![0] : '';
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.backgroundWhite,
        child: Text(
          firstChar,
          style: Get.context?.textTheme.headline3,
        ),
      );
    }
  }
}
