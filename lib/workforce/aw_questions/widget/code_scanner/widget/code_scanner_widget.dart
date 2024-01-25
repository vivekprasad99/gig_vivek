import 'dart:io';

import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/helper/file_picker_helper.dart';
import 'package:awign/workforce/aw_questions/widget/code_scanner/cubit/code_scanner_cubit.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/widget/common/desktop_coming_soon_widget.dart';
import '../../../../core/widget/scaffold/app_scaffold.dart';
import '../../../../core/widget/theme/theme_manager.dart';
import '../../../data/model/configuration/configuration.dart';
import '../../../data/model/question.dart';

class CodeScannerWidget extends StatefulWidget {
  final Question question;

  const CodeScannerWidget(this.question, {Key? key}) : super(key: key);

  @override
  State<CodeScannerWidget> createState() => _CodeScannerWidgetState();
}

class _CodeScannerWidgetState extends State<CodeScannerWidget> {
  final CodeScannerCubit _codeScannerCubit = sl<CodeScannerCubit>();

  @override
  void initState() {
    super.initState();
    startDelayedText();
  }

  void startDelayedText() {
    Future.delayed(const Duration(seconds: 15), () {
      _codeScannerCubit
          .changeDelayedText('if_not_please_enter_details_manually'.tr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      body: Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(
            color: AppColors.backgroundWhite,
          ),
          backgroundColor: AppColors.primaryMain,
          centerTitle: false,
          title: Text(
            widget.question.configuration?.questionText?.toUpperCase() ?? "",
            textAlign: TextAlign.start,
            style: Get.context?.textTheme.bodyText1
                ?.copyWith(color: AppColors.backgroundWhite),
          ),
        ),
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    final isCameraSupported = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
    return Scaffold(
      body: Stack(
        children: [
          ReaderWidget(
            showToggleCamera: false,
            actionButtonsAlignment: Alignment.bottomCenter,
            showGallery: false,
            onScan: (result) async {
              if (result.isValid) {
                MRouter.pop(result.text.toString());
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: Dimens.padding_220),
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  'please_align_the_barcode_within_the_scanner'.tr,
                  style: Get.context?.textTheme.bodyText1
                      ?.copyWith(color: AppColors.secondary2300),
                )),
          ),
          buildTextAfterFifteenSecond(),
          Visibility(
              visible: widget.question.configuration?.uploadFrom ==
                      UploadFromOption.cameraAndGallery ||
                  widget.question.configuration?.uploadFrom ==
                      UploadFromOption.gallery,
              child: buildOpenGallery()),
        ],
      ),
    );
  }

  Widget buildOpenGallery() {
    return Positioned(
      right: MediaQuery.of(context).size.width * 0.3,
      bottom: 12,
      child: IconButton(
          // splashRadius: Dimens.radius_4,
          onPressed: () {
            FilePickerHelper.pickMedia(SubType.image, DataType.single,
                (result) async {
              File file = File(result.files.single.path ?? '');
              XFile xFile = XFile(file.path);
              Code? resultFromXFile = await zx.readBarcodeImagePath(xFile);
              if (resultFromXFile.isValid) {
                MRouter.pop(resultFromXFile.text.toString());
              }
            });
          },
          icon: SvgPicture.asset(
            'assets/images/gallery.svg',
            color: AppColors.backgroundWhite,
          )),
    );
  }

  Widget buildTextAfterFifteenSecond() {
    return StreamBuilder<String?>(
        stream: _codeScannerCubit.delayedText,
        builder: (context, delayedText) {
          if (delayedText.hasData) {
            return MyInkWell(
              onTap: () async {
                MRouter.pop(null);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: Dimens.margin_80, horizontal: Dimens.padding_32),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.backgroundGrey500),
                      color: AppColors.backgroundWhite,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(Dimens.radius_8)),
                    ),
                    padding: const EdgeInsets.all(Dimens.padding_16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('do_you_want_to_continue_scanning'.tr),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${delayedText.data}"),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.primaryMain,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }
}
