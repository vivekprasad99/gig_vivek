import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataNotFound extends StatelessWidget {
  final String? error;

  DataNotFound({this.error});

  @override
  Widget build(BuildContext context) {
    return buildDataNotFoundUI();
  }

  Widget buildDataNotFoundUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            error ?? "Data not available",
            style: Get.context?.textTheme.bodyText1,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
