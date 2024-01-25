import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/cubit/internet_cubit.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class InternetSensitive extends StatelessWidget {
  final Widget? child;

  InternetSensitive({this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetCubit, InternetState>(
      builder: (internetCubitBuilderContext, state) {
        if (kIsWeb) {
          return child ?? const SizedBox();
        } else if (state is InternetConnected) {
          return child ?? const SizedBox();
        } else if (state is InternetDisconnected) {
          return buildNoInternetUI(context);
        }
        return AppCircularProgressIndicator();
      },
    );
  }

  Widget buildNoInternetUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('No Internet Connection!', style: context.textTheme.subtitle2),
          SizedBox(height: Dimens.margin_4),
          Text('Please try to connect with internet.',
              style: context.textTheme.bodyText1)
        ],
      ),
    );
  }
}
