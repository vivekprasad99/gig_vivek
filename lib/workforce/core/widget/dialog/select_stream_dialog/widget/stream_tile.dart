import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/model/language.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StreamTile extends StatelessWidget {
  final int index;
  final String stream;
  final Function(int index, String stream) onStreamTap;

  const StreamTile(
      {Key? key,
      required this.index,
      required this.stream,
      required this.onStreamTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16, vertical: Dimens.padding_8),
      child: MyInkWell(
        onTap: () {
          onStreamTap(index, stream);
        },
        child: Text(stream, style: context.textTheme.bodyText1),
      ),
    );
  }
}
