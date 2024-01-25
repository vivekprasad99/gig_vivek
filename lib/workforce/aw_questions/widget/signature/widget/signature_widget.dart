import 'dart:io';
import 'dart:typed_data';

import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/image_loader/network_image_loader.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:signature/signature.dart';
import '../../../../core/widget/scaffold/app_scaffold.dart';

class SignatureWidget extends StatefulWidget {
  final Question question;

  const SignatureWidget(this.question, {Key? key}) : super(key: key);

  @override
  State<SignatureWidget> createState() => _SignatureWidgetState();
}

class _SignatureWidgetState extends State<SignatureWidget> {
  SignatureController? controller;
  bool? isCheck;

  @override
  void initState() {
    super.initState();
    controller = SignatureController(penColor: AppColors.backgroundBlack);
    setState(() {
      isCheck = widget.question.answerUnit?.stringValue == null;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    {
      return AppScaffold(
        backgroundColor: AppColors.primaryMain,
        body: Scaffold(
          appBar: AppBar(
            elevation: 0,
            iconTheme: const IconThemeData(
              color: AppColors.backgroundWhite,
            ),
            backgroundColor: AppColors.primaryMain,
            title: Text(
              'signature'.tr,
              style: Get.context?.textTheme.bodyText1
                  ?.copyWith(color: AppColors.backgroundWhite),
            ),
            actions: [
              buildClear(),
              Visibility(visible: isCheck!, child: buildCheck()),
            ],
          ),
          body: buildBody(),
        ),
      );
    }
  }

  Widget buildClear() {
    return MyInkWell(
      onTap: () {
        controller!.clear();
        setState(() {
          isCheck = true;
        });
      },
      child: const Padding(
        padding: EdgeInsets.all(Dimens.padding_16),
        child: Icon(
          Icons.refresh,
          size: Dimens.padding_24,
        ),
      ),
    );
  }

  Widget buildCheck() {
    return MyInkWell(
      onTap: () async {
        if (controller!.isEmpty) {
          Helper.showInfoToast('please_sign_first'.tr);
        } else {
          final bytes = await exportSignature();
          String? targetPath = await FileUtils.getImageFilePath(Get.context!);
          if (targetPath != null) {
            File file = File(targetPath);
            if (!await file.exists()) {
              file.create(recursive: true);
            }
            await file.writeAsBytes(bytes!);
            MRouter.pop(file);
          }
        }
      },
      child: const Padding(
        padding: EdgeInsets.all(Dimens.padding_16),
        child: Icon(
          Icons.check,
          size: Dimens.padding_24,
          color: AppColors.success100,
        ),
      ),
    );
  }

  Future<Uint8List?> exportSignature() async {
    final exportController = SignatureController(
        penColor: AppColors.backgroundBlack, points: controller!.points);
    final signature = await exportController.toPngBytes();
    exportController.dispose();
    return signature;
  }

  Widget buildBody() {
    if (!isCheck!) {
      return Center(
        child: NetworkImageLoader(
          url: widget.question.answerUnit!.stringValue!,
          filterQuality: FilterQuality.high,
          fit: BoxFit.fitWidth,
        ),
      );
    } else {
      return Signature(
        controller: controller!,
        backgroundColor: AppColors.backgroundWhite,
      );
    }
  }
}
