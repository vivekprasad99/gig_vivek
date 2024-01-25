import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_file/internet_file.dart';
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../../more/data/model/user_certificate_response.dart';
import '../../../../utils/file_utils.dart';

void showCertificationBottomSheet(
    BuildContext context, UserCertificateResponse userCertificate, int? rank) {
  showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return CertificateBottomSheet(userCertificate, rank);
      });
}

class CertificateBottomSheet extends StatefulWidget {
  final UserCertificateResponse userCertificate;
  final int? rank;
  const CertificateBottomSheet(this.userCertificate, this.rank, {Key? key})
      : super(key: key);

  @override
  State<CertificateBottomSheet> createState() => _CertificateBottomSheetState();
}

class _CertificateBottomSheetState extends State<CertificateBottomSheet> {
  late PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openData(
          InternetFile.get(widget.userCertificate.urls!.pdfUrl! ?? '')),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_48,
        Dimens.padding_16,
        Dimens.padding_40,
      ),
      color: widget.userCertificate.performance == Constants.excellent
          ? AppColors.warning100
          : AppColors.backgroundWhite,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: MyInkWell(
                  onTap: () {
                    MRouter.pop(null);
                  },
                  child: const Icon(
                    Icons.close,
                    color: AppColors.backgroundBlack,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: Dimens.margin_36),
              Text(
                'congratulations'.tr,
                style: Get.context?.textTheme.titleLarge?.copyWith(
                    color: AppColors.black,
                    fontSize: Dimens.font_24,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: Dimens.margin_24),
              RichText(
                  text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: 'congratulation_first_part'.tr,
                  style: Get.context?.textTheme.titleLarge?.copyWith(
                      color: AppColors.backgroundGrey800,
                      fontSize: Dimens.font_18,
                      fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text:
                      widget.userCertificate.performance == Constants.excellent
                          ? 'congratulation_fourth_part'.tr
                          : 'congratulation_second_part'.tr,
                  style: Get.context?.textTheme.titleLarge?.copyWith(
                      color: AppColors.backgroundBlack,
                      fontSize: Dimens.font_18,
                      fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      widget.userCertificate.performance == Constants.excellent
                          ? 'congratulation_fifth_part'.tr
                          : 'congratulation_third_part'.tr,
                  style: Get.context?.textTheme.titleLarge?.copyWith(
                      color: AppColors.backgroundGrey800,
                      fontSize: Dimens.font_18,
                      fontWeight: FontWeight.w500),
                ),
                TextSpan(
                    text: widget.userCertificate.performance ==
                            Constants.excellent
                        ? getRankInWords(widget.rank!)
                        : ' ${DateFormat('MMMM').format(DateTime(0, widget.userCertificate.month!))} ${widget.userCertificate.year}',
                    style: Get.context?.textTheme.titleLarge?.copyWith(
                        color: AppColors.backgroundGrey800,
                        fontSize: Dimens.font_18,
                        fontWeight: FontWeight.w500)),
                TextSpan(
                  text:
                      widget.userCertificate.performance == Constants.excellent
                          ? 'congratulation_sixth_part'.tr
                          : '',
                  style: Get.context?.textTheme.titleLarge?.copyWith(
                      color: AppColors.backgroundGrey800,
                      fontSize: Dimens.font_18,
                      fontWeight: FontWeight.w500),
                ),
              ])),
              const SizedBox(height: Dimens.margin_12),
              Text(
                'congratulation_second_desc'.tr,
                style: Get.context?.textTheme.titleLarge?.copyWith(
                    color: AppColors.backgroundGrey800,
                    fontSize: Dimens.font_16,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: Dimens.margin_56),
              buildPDFWidget(),
              const Spacer(),
              RaisedRectButton(
                text: 'share_certificate'.tr,
                backgroundColor: AppColors.primaryMain,
                textColor: AppColors.backgroundWhite,
                onPressed: () async {
                  await FileUtils.shareImages(
                      widget.userCertificate.urls!.imageUrl!);
                },
                icon: const Icon(
                  Icons.share,
                  color: AppColors.backgroundWhite,
                ),
              ),
            ],
          ),
          Visibility(
            visible: widget.userCertificate.performance == Constants.excellent,
            child: Align(
              alignment: Alignment.topRight,
              child: Image.asset(
                'assets/images/confetti_colorful.png',
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildPDFWidget() {
    return Container(
      height: Dimens.btnWidth_250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.padding_16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimens.padding_8),
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

  String getRankInWords(int rank) {
    switch (rank) {
      case 1:
        return "first";
      case 2:
        return "second";
      case 3:
        return "third";
      case 4:
        return "fourth";
      case 5:
        return "fifth";
      default:
        return "fifth";
    }
  }
}
