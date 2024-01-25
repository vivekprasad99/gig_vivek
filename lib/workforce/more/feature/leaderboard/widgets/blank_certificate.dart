import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/utils/constants.dart';

class BlankCertificate extends StatefulWidget {
  const BlankCertificate({Key? key}) : super(key: key);

  @override
  State<BlankCertificate> createState() => _BlankCertificateState();
}

class _BlankCertificateState extends State<BlankCertificate> {
  late PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openData(InternetFile.get(Constants.blankPdf)),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimens.padding_16),
        child: buildShowCertificate(),
      ),
    );
  }

  Widget buildShowCertificate() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            buildPDFWidget(Dimens.btnWidth_250, double.infinity,
                Dimens.padding_24, Dimens.padding_20),
            Container(
              decoration: BoxDecoration(
                  color: AppColors.overlay,
                  borderRadius: BorderRadius.circular(Dimens.radius_32)),
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.font_20, vertical: Dimens.font_16),
              child: buildViewText(),
            )
          ],
        ),
        const SizedBox(height: Dimens.margin_16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildShareCertificateText(),
            const Icon(
              Icons.share,
              color: AppColors.backgroundGrey900,
            )
          ],
        )
      ],
    );
  }

  Widget buildViewText() {
    return Text('view'.tr,
        style: Get.context!.textTheme.bodyText1Bold?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: Dimens.font_16,
            color: AppColors.backgroundWhite));
  }

  Widget buildShareCertificateText() {
    return Text('share_certificate'.tr,
        style: Get.context!.textTheme.bodyText1Bold?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: Dimens.font_14,
            color: AppColors.primaryMain));
  }

  Widget buildPDFWidget(
      double height, double width, double containerRadius, double clipRadius) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(clipRadius),
        child: PdfView(
          controller: _pdfController,
          scrollDirection: Axis.vertical,
          builders: PdfViewBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(
              loaderSwitchDuration: Duration(seconds: 1),
            ),
            documentLoaderBuilder: (_) =>
                Center(child: AppCircularProgressIndicator()),
            pageLoaderBuilder: (_) =>
                Center(child: AppCircularProgressIndicator()),
            errorBuilder: (_, error) => Center(
                child: Text(error.toString(), style: Get.textTheme.bodyText1)),
          ),
        ),
      ),
    );
  }
}
