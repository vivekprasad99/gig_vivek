import 'package:awign/packages/flutter_image_editor/cubit/image_editor_widget_cubit.dart';
import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/packages/flutter_image_editor/widget/tile/image_preview_tile.dart';
import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_page_names.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../workforce/core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../workforce/core/data/local/repository/logging_event/helper/logging_events.dart';

class ImageEditorWidgetNew extends StatefulWidget {
  final ImageDetails imageDetails;

  const ImageEditorWidgetNew(this.imageDetails, {Key? key}) : super(key: key);

  @override
  State<ImageEditorWidgetNew> createState() => _ImageEditorWidgetNewState();
}

class _ImageEditorWidgetNewState extends State<ImageEditorWidgetNew> {
  final _imageEditorWidgetCubit = sl<ImageEditorWidgetCubit>();
  PageController? pageController;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    if (widget.imageDetails.dataType == DataType.array &&
        widget.imageDetails.imageDetailsList != null) {
      _imageEditorWidgetCubit
          .changeImageDetailsList(widget.imageDetails.imageDetailsList!);
      _imageEditorWidgetCubit.changeSelectedImageQuality(
          widget.imageDetails.imageDetailsList![0].fileQuality);
    } else {
      List<ImageDetails> imageDetailsList = [];
      imageDetailsList.add(widget.imageDetails);
      _imageEditorWidgetCubit.changeImageDetailsList(imageDetailsList);
      _imageEditorWidgetCubit
          .changeSelectedImageQuality(widget.imageDetails.fileQuality);
    }
    _imageEditorWidgetCubit.changeRotationValue();
    _imageEditorWidgetCubit.compressImage();
  }

  void subscribeUIStatus() {
    _imageEditorWidgetCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.success:
            ImageDetails? imageDetails = uiStatus.data as ImageDetails?;
            WidgetResult widgetResult;
            List<ImageDetails>? imageDetailsList =
                _imageEditorWidgetCubit.getImageDetailsList();
            if (widget.imageDetails.isAsync && imageDetailsList != null) {
              widgetResult =
                  WidgetResult(event: Event.selected, data: imageDetailsList);
            } else {
              widgetResult =
                  WidgetResult(event: Event.selected, data: imageDetails);
            }
            MRouter.pop(widgetResult);
            break;
          case Event.deleted:
            MRouter.pop(null);
            break;
          case Event.none:
            break;
        }
      },
    );
    _imageEditorWidgetCubit.selectedImageIndexStream
        .listen((selectedImageIndex) {
      pageController?.animateToPage(selectedImageIndex,
          duration: const Duration(microseconds: 500), curve: Curves.easeIn);
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
      bottomPadding: 0,
      topPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
              isCollapsable: true,
              title: 'preview'.tr,
            ),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: Column(
          children: [
            buildImageIndexIndicatorWidget(),
            Expanded(child: buildImageWidget()),
            buildBottomWidgetsContainer(),
          ],
        ),
      ),
    );
  }

  Widget buildImageIndexIndicatorWidget() {
    if (widget.imageDetails.dataType == DataType.array) {
      return StreamBuilder<int>(
          stream: _imageEditorWidgetCubit.selectedImageIndexStream,
          builder: (context, selectedImageIndexStream) {
            if (selectedImageIndexStream.hasData) {
              int currentIndex = (selectedImageIndexStream.data! + 1);
              return Padding(
                padding: const EdgeInsets.only(top: Dimens.padding_16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    currentIndex == 1
                        ? const SizedBox(width: 40)
                        : const SizedBox(
                            width: 40,
                            child: Icon(Icons.navigate_before,
                                color: AppColors.black),
                          ),
                    SizedBox(
                      width: 40,
                      child: Text(
                          '${(selectedImageIndexStream.data ?? 0 + 1)}/${widget.imageDetails.imageDetailsList!.length}',
                          style: Get.textTheme.headline6),
                    ),
                    currentIndex == widget.imageDetails.imageDetailsList!.length
                        ? const SizedBox(width: 40)
                        : const SizedBox(
                            width: 40,
                            child: Icon(Icons.navigate_next,
                                color: AppColors.black),
                          ),
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          });
    } else {
      return const SizedBox();
    }
  }

  Widget buildImageWidget() {
    return Padding(
      padding: const EdgeInsets.all(Dimens.padding_16),
      child: StreamBuilder<UIStatus>(
        stream: _imageEditorWidgetCubit.uiStatus,
        builder: (context, uiStatus) {
          if (uiStatus.hasData && uiStatus.data!.isOnScreenLoading) {
            return AppCircularProgressIndicator();
          } else {
            return StreamBuilder<List<ImageDetails>>(
              stream: _imageEditorWidgetCubit.imageDetailsListStream,
              builder: (context, imageDetailsListStream) {
                if (imageDetailsListStream.hasData) {
                  pageController = PageController(
                      initialPage:
                          _imageEditorWidgetCubit.selectedImageIndexValue);
                  return SizedBox(
                    width: double.infinity,
                    child: PageView.builder(
                        itemCount: imageDetailsListStream.data!.length,
                        controller: pageController,
                        onPageChanged: (index) {
                          _imageEditorWidgetCubit
                              .changeSelectedImageIndex(index);
                          _imageEditorWidgetCubit.changeSelectedImageQuality(
                              widget.imageDetails.imageDetailsList![index]
                                  .fileQuality);
                          _imageEditorWidgetCubit.changeRotationValue();
                          _imageEditorWidgetCubit.compressImage();
                        },
                        itemBuilder: (context, i) {
                          return ImagePreviewTile(
                              imageDetailsListStream.data![i]);
                        }),
                  );
                } else {
                  return const SizedBox();
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget buildBottomWidgetsContainer() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.abyssalAnchorfishBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: Dimens.padding_16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PopupMenuButton<FileQuality>(
                  itemBuilder: (context) => [
                        PopupMenuItem<FileQuality>(
                          value: FileQuality.low,
                          child: Text('low_quality'.tr,
                              style: Get.textTheme.bodyText2SemiBold),
                        ),
                        PopupMenuItem<FileQuality>(
                          value: FileQuality.high,
                          child: Text('high_quality'.tr,
                              style: Get.textTheme.bodyText2SemiBold),
                        ),
                      ],
                  onSelected: (item) => selectedItem(item),
                  child: buildEditOptionButton('quality'.tr, Icons.hd)),
              MyInkWell(
                onTap: () {
                  _imageEditorWidgetCubit.rotateImage();
                },
                child: buildEditOptionButton('rotate'.tr, Icons.rotate_right),
              ),
              MyInkWell(
                onTap: () {
                  if (widget.imageDetails.fromRoute ==
                          MRouter.inAppCameraWidget &&
                      widget.imageDetails.dataType == DataType.single) {
                    MRouter.pop(null);
                  } else {
                    _captureImage();
                  }
                  LoggingData loggingData = LoggingData(
                      event: LoggingEvents.retakeSelfieClicked,
                      action: LoggingActions.clicked,pageName: LoggingPageNames.uploadSelfie);
                  CaptureEventHelper.captureEvent(loggingData: loggingData);
                },
                child: buildEditOptionButton('retake'.tr, Icons.camera_alt),
              ),
              MyInkWell(
                onTap: () {
                  _onDeleteImageTapped();
                },
                child: buildEditOptionButton('delete'.tr, Icons.delete),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
            child: HDivider(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
            child: Row(
              children: [
                buildUploadLaterButton(),
                SizedBox(
                    width:
                        widget.imageDetails.uploadLater ? Dimens.padding_4 : 0),
                Expanded(child: buildConfirmAndUploadButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void selectedItem(item) {
    switch (item) {
      case FileQuality.low:
        _imageEditorWidgetCubit.changeSelectedImageQuality(FileQuality.low);
        Helper.showInfoToast('low_quality_image_selected'.tr);
        break;
      case FileQuality.high:
        _imageEditorWidgetCubit.changeSelectedImageQuality(FileQuality.high);
        Helper.showInfoToast('high_quality_image_selected'.tr);
        break;
    }
  }

  Widget buildEditOptionButton(String text, IconData iconData) {
    return Column(
      children: [
        Icon(iconData, color: AppColors.backgroundWhite),
        const SizedBox(height: Dimens.padding_4),
        Text(text,
            style: context.textTheme.bodyText2SemiBold
                ?.copyWith(color: AppColors.backgroundWhite)),
      ],
    );
  }

  Widget buildUploadLaterButton() {
    if (widget.imageDetails.uploadLater) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimens.padding_16),
          child: CustomTextButton(
            text: 'upload_later'.tr,
            backgroundColor: AppColors.transparent,
            borderColor: AppColors.pine,
            textColor: AppColors.pine,
            onPressed: () {
              if (widget.imageDetails.isAsync) {
                _imageEditorWidgetCubit.goToNextImageOrInsertImages(true);
              } else {
                _imageEditorWidgetCubit.goBackWithImage();
              }
            },
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildConfirmAndUploadButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.padding_16),
      child: RaisedRectButton(
        text: 'confirm_and_upload'.tr,
        backgroundColor: AppColors.pine,
        elevation: 0,
        onPressed: () {
          if (widget.imageDetails.isAsync) {
            _imageEditorWidgetCubit.goToNextImageOrInsertImages(false);
          } else {
            _imageEditorWidgetCubit.goBackWithImage();
          }
          LoggingData loggingData = LoggingData(
              event: LoggingEvents.submitProceedSelfieClicked,
              action: LoggingActions.clicked,pageName: LoggingPageNames.uploadSelfie);
          CaptureEventHelper.captureEvent(loggingData: loggingData);
        },
      ),
    );
  }

  void _captureImage() async {
    ImageDetails imageDetails = ImageDetails(
        uploadLater: widget.imageDetails.uploadLater,
        dataType: DataType.single,
        isOpenImageEditor: false,
        question: widget.imageDetails.question);
    WidgetResult? cameraWidgetResult = await MRouter.pushNamed(
        MRouter.inAppCameraWidget,
        arguments: imageDetails);
    if (cameraWidgetResult != null &&
        cameraWidgetResult.event == Event.selected &&
        cameraWidgetResult.data is ImageDetails) {
      _imageEditorWidgetCubit.updateImageDetailsList(cameraWidgetResult.data,
          isRetake: true);
    }
  }

  _onDeleteImageTapped() async {
    ConfirmAction? confirmAction = await Helper.asyncConfirmDialog(
        context, 'are_you_sure_want_to_delete_this_image'.tr,
        heading: 'delete_image'.tr,
        textOKBtn: 'yes'.tr,
        textCancelBtn: 'no'.tr);
    if (confirmAction == ConfirmAction.OK) {
      _imageEditorWidgetCubit.deleteImage();
    }
  }
}
