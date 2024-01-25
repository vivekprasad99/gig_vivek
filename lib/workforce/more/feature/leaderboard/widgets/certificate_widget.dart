import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/data/model/user_certificate_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/remote/capture_event/capture_event_helper.dart';
import '../../../../core/data/remote/capture_event/logging_data.dart';
import '../../../../core/utils/constants.dart';
import '../../../data/model/user_earning_response.dart';

class CertificateWidget extends StatefulWidget {
  Function() onViewTap;
  UserCertificateResponse? userCertificate;
  String? blankPdf;
  UserEarningResponse userEarningResponse;
  String navItemSelectedValue;

  CertificateWidget(this.userEarningResponse, this.navItemSelectedValue,
      this.onViewTap, {Key? key, this.userCertificate, this.blankPdf})
      : super(key: key);

  @override
  State<CertificateWidget> createState() => _CertificateWidgetState();
}

class _CertificateWidgetState extends State<CertificateWidget> {
  late PdfController _pdfController;

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
            // buildPDFWidget(Dimens.btnWidth_250,double.infinity,Dimens.padding_24,Dimens.padding_20),
            buildCertificateImage(),
            buildViewWidget(),
          ],
        ),
        const SizedBox(height: Dimens.margin_16),
        buildShareCertificateWidget(),
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

  Widget buildCertificateImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimens.padding_4),
          child: Image.network(widget.userCertificate!.urls!.imageUrl!)),
    );
  }

  Widget buildViewWidget() {
    return MyInkWell(
      onTap: () {
        _logEvents();
        widget.blankPdf!.isNotEmpty ? null : widget.onViewTap();
      },
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.overlay,
            borderRadius: BorderRadius.circular(Dimens.radius_32)),
        padding: const EdgeInsets.symmetric(
            horizontal: Dimens.font_20, vertical: Dimens.font_16),
        child: buildViewText(),
      ),
    );
  }

  Widget buildShareCertificateWidget() {
    return MyInkWell(
      onTap: () async {
        _logEvents();
        widget.blankPdf!.isNotEmpty
            ? null
            : await FileUtils.shareImages(
                widget.userCertificate!.urls!.imageUrl!);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildShareCertificateText(),
          const Icon(
            Icons.share,
            color: AppColors.backgroundGrey900,
          )
        ],
      ),
    );
  }

  void _logEvents() {
    switch (widget.navItemSelectedValue) {
      case Constants.earning:
        if (widget.userEarningResponse.performance == Constants.good) {
          CaptureEventHelper.captureEvent(
              loggingData: LoggingData(
                  event: LoggingEvents.certificateViewGoodEarnings,
                  action: LoggingActions.click,
                  pageName: "Leaderboard",
                  sectionName: "Profile")
          );
        } else if (widget.userEarningResponse.performance == Constants.excellent) {
          CaptureEventHelper.captureEvent(
              loggingData: LoggingData(
                  event: LoggingEvents.certificateViewExcellentEarnings,
                  action: LoggingActions.click,
                  pageName: "Leaderboard",
                  sectionName: "Profile")
          );
        }
        break;
      case Constants.taskCompleted:
        if (widget.userEarningResponse.performance == Constants.good) {
          CaptureEventHelper.captureEvent(
              loggingData: LoggingData(
                  event: LoggingEvents.certificateViewGoodTasks,
                  action: LoggingActions.click,
                  pageName: "Leaderboard",
                  sectionName: "Profile")
          );
        } else if (widget.userEarningResponse.performance == Constants.excellent) {
          CaptureEventHelper.captureEvent(
              loggingData: LoggingData(
                  event: LoggingEvents.certificateViewExcellentTasks,
                  action: LoggingActions.click,
                  pageName: "Leaderboard",
                  sectionName: "Profile")
          );
        }
        break;
    }
  }

// Widget buildPDFWidget(double height,double width,double containerRadius,double clipRadius) {
//   _pdfController = PdfController(
//     document: PdfDocument.openData(InternetFile.get(widget.userCertificate!.urls!.pdfUrl!)),
//   );
//   return Container(
//     height: height,
//     width: width,
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(containerRadius),
//     ),
//     child: ClipRRect(
//       borderRadius: BorderRadius.circular(clipRadius),
//       child: PdfView(
//         controller: _pdfController,
//         scrollDirection: Axis.vertical,
//         builders: PdfViewBuilders<DefaultBuilderOptions>(
//           options: const DefaultBuilderOptions(
//             loaderSwitchDuration: Duration(seconds: 1),
//           ),
//           documentLoaderBuilder: (_) =>
//               Center(child: AppCircularProgressIndicator()),
//           pageLoaderBuilder: (_) =>
//               Center(child: AppCircularProgressIndicator()),
//           errorBuilder: (_, error) => Center(
//               child: Text(error.toString(), style: Get.textTheme.bodyText1)),
//         ),
//       ),
//     ),
//   );
// }
}
