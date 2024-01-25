import 'dart:io';

import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/attachment/file_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/data/image_sync_state.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/helper/file_picker_helper.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_linear_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/image_loader/network_image_loader.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import '../../../../../core/data/model/ui_status.dart';
import '../../../../../core/data/model/widget_result.dart';
import '../../../../../core/widget/bottom_sheet/select_camera_or_gallery_bottom_sheet/widget/select_camera_or_gallery_bottom_sheet.dart';
import '../../../../../onboarding/data/model/application_question/application_question_response.dart';
import '../cubit/sync_image_input_cubit.dart';

class SyncImageInputWidget extends StatefulWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;
  late final FileConfiguration fileConfiguration;

  SyncImageInputWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key) {
    fileConfiguration = question.configuration as FileConfiguration;
  }

  @override
  State<SyncImageInputWidget> createState() => _SyncImageInputWidgetState();
}

class _SyncImageInputWidgetState extends State<SyncImageInputWidget> {
  Stream? uploadPercentageStream;
  bool isUploading = false;
  final _syncImageInputCubit = sl<SyncImageInputCubit>();

  @override
  void initState() {
    super.initState();
    if (widget.question.answerUnit?.hasAnswered() ?? false) {
      if (widget.question.answerUnit?.imageDetails == null) {
        ImageDetails imageDetails = ImageDetails(
            url: widget.question.answerUnit?.stringValue,
            uploadLater: widget.fileConfiguration.uploadLater);
        widget.question.answerUnit?.imageDetails = imageDetails;
      }
      _syncImageInputCubit.changeImageSyncStatus(ImageSyncStatus(
          imageSyncState: ImageSyncState.answered,
          data: widget.question.answerUnit?.imageDetails));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ImageSyncStatus>(
      stream: _syncImageInputCubit.imageSyncStatus,
      builder: (context, imageSyncStatus) {
        if (imageSyncStatus.hasData &&
            imageSyncStatus.data!.imageSyncState == ImageSyncState.unAnswered) {
          return buildSelectOptionWidget(context);
        } else if (imageSyncStatus.hasData &&
            imageSyncStatus.data!.imageSyncState == ImageSyncState.uploading) {
          return buildUploadingWidget(context,
              imageSyncStatus.data!.imageSyncState, imageSyncStatus.data!.data);
        } else if (imageSyncStatus.hasData &&
            imageSyncStatus.data!.imageSyncState == ImageSyncState.paused) {
          return buildPausedOrUploadedWidget(
              context,
              imageSyncStatus.data!.imageSyncState,
              imageSyncStatus.data!.data,
              true);
        } else if (imageSyncStatus.hasData &&
            (imageSyncStatus.data!.imageSyncState == ImageSyncState.uploaded ||
                imageSyncStatus.data!.imageSyncState ==
                    ImageSyncState.answered)) {
          return buildPausedOrUploadedWidget(
              context,
              imageSyncStatus.data!.imageSyncState,
              imageSyncStatus.data!.data,
              false);
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildSelectOptionWidget(BuildContext context) {
    if (widget.question.answerUnit?.inputType?.getValue2() == SubType.image) {
      switch (widget.question.configuration?.uploadFrom) {
        case UploadFromOption.camera:
          return widget.question.currentRoute == MRouter.arrayQuestionWidget
              ? Column(
                  children: [
                    buildSelectFromCameraWidget(context),
                  ],
                )
              : buildSelectFromCameraWidget(context);
        case UploadFromOption.gallery:
          return widget.question.currentRoute == MRouter.arrayQuestionWidget
              ? Column(
                  children: [
                    buildSelectFromGalleryWidget(context),
                  ],
                )
              : buildSelectFromGalleryWidget(context);
        case UploadFromOption.cameraAndGallery:
          return Row(
            children: [
              Expanded(child: buildSelectFromCameraWidget(context)),
              const SizedBox(width: Dimens.padding_16),
              Expanded(child: buildSelectFromGalleryWidget(context))
            ],
          );
        default:
          return widget.question.currentRoute == MRouter.arrayQuestionWidget
              ? Column(
                  children: [
                    buildImageText(),
                    buildSelectFromGalleryWidget(context),
                  ],
                )
              : buildSelectFromGalleryWidget(context);
      }
    } else {
      return widget.question.currentRoute == MRouter.arrayQuestionWidget
          ? Column(
              children: [
                buildImageText(),
                buildSelectFromGalleryWidget(context),
              ],
            )
          : buildSelectFromGalleryWidget(context);
    }
  }

  Widget buildImageText() {
    return Text(
      'image'.tr,
      style: Get.textTheme.bodyText2SemiBold,
    );
  }

  Widget buildSelectFromCameraWidget(BuildContext context) {
    return MyInkWell(
      onTap: () async {
        _captureImage();
      },
      child: Container(
        height: Dimens.etHeight_48,
        decoration: BoxDecoration(
          color: Get.theme.inputBoxBackgroundColor,
          border: Border.all(color: Get.theme.inputBoxBorderColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimens.radius_8),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Icon(Icons.camera_alt,
                  color: AppColors.backgroundGrey600, size: Dimens.iconSize_20),
              const SizedBox(width: Dimens.padding_12),
              Text(
                'camera'.tr,
                style: Get.textTheme.bodyText1
                    ?.copyWith(color: context.theme.hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSelectFromGalleryWidget(BuildContext context) {
    String hint = 'gallery'.tr;
    if (widget.question.answerUnit?.inputType?.getValue2() != SubType.image) {
      hint = 'select_file'.tr;
    }
    return MyInkWell(
      onTap: () async {
        _pickMedia();
      },
      child: Container(
        height: Dimens.etHeight_48,
        decoration: BoxDecoration(
          color: Get.theme.inputBoxBackgroundColor,
          border: Border.all(color: Get.theme.inputBoxBorderColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimens.radius_8),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(
                  widget.question.answerUnit?.inputType?.getValue2() ==
                          SubType.image
                      ? Icons.photo_library
                      : Icons.attachment,
                  color: AppColors.backgroundGrey600,
                  size: Dimens.iconSize_20),
              const SizedBox(width: Dimens.padding_12),
              Text(
                hint,
                style: Get.textTheme.bodyText1
                    ?.copyWith(color: context.theme.hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUploadingWidget(BuildContext context,
      ImageSyncState imageSyncState, ImageDetails imageDetails) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.textFieldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_16)),
      ),
      padding: const EdgeInsets.all(Dimens.padding_12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildThumbnailWidget(imageDetails),
              const SizedBox(width: Dimens.padding_12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildFileNameWidget(imageDetails),
                    buildProgressWidget(imageDetails),
                  ],
                ),
              ),
              buildExpandedCollapseWidget(),
            ],
          ),
          buildExpandedWidgets(imageSyncState, imageDetails, false),
        ],
      ),
    );
  }

  Widget buildPausedOrUploadedWidget(BuildContext context,
      ImageSyncState imageSyncState, ImageDetails imageDetails, bool isPaused) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.theme.textFieldBackgroundColor,
            borderRadius:
                const BorderRadius.all(Radius.circular(Dimens.radius_16)),
          ),
          padding: const EdgeInsets.all(Dimens.padding_12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildThumbnailWidget(imageDetails),
                  const SizedBox(width: Dimens.padding_12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildFileNameWidget(imageDetails),
                        const SizedBox(height: Dimens.padding_8),
                        buildPausedOrUploadedText(imageDetails, isPaused),
                      ],
                    ),
                  ),
                  buildExpandedCollapseWidget(),
                ],
              ),
              buildExpandedWidgets(imageSyncState, imageDetails, isPaused),
            ],
          ),
        ),
        // const SizedBox(height: Dimens.padding_16),
        // buildChangeWidget(imageSyncState),
      ],
    );
  }

  Widget buildThumbnailWidget(ImageDetails imageDetails) {
    return MyInkWell(
      onTap: () {
        MRouter.pushNamed(MRouter.imageDetailsWidget, arguments: imageDetails);
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_12)),
        child: imageDetails.getFile() != null
            ? Image.file(
                imageDetails.getFile()!,
                width: Dimens.imageWidth_56,
                height: Dimens.imageHeight_56,
                fit: BoxFit.fitWidth,
              )
            : NetworkImageLoader(
                url: imageDetails.url!,
                filterQuality: FilterQuality.high,
                width: Dimens.imageWidth_56,
                height: Dimens.imageHeight_56,
                fit: BoxFit.fitWidth,
              ),
      ),
    );
  }

  Widget buildFileNameWidget(ImageDetails imageDetails) {
    return Text(imageDetails.getFileName() ?? '',
        overflow: TextOverflow.ellipsis,
        style: Get.textTheme.bodyText2SemiBold);
  }

  Widget buildPausedOrUploadedText(ImageDetails imageDetails, bool isPaused) {
    if (isPaused) {
      return Row(
        children: [
          const Icon(Icons.pause,
              color: AppColors.orange, size: Dimens.iconSize_16),
          const SizedBox(width: Dimens.padding_8),
          Text('Paused',
              overflow: TextOverflow.ellipsis,
              style: Get.textTheme.bodyText2SemiBold
                  ?.copyWith(color: AppColors.orange)),
        ],
      );
    } else {
      return Row(
        children: [
          const Icon(Icons.check_circle,
              color: AppColors.pine, size: Dimens.iconSize_16),
          const SizedBox(width: Dimens.padding_8),
          Text('Uploaded',
              overflow: TextOverflow.ellipsis,
              style: Get.textTheme.bodyText2SemiBold
                  ?.copyWith(color: AppColors.pine)),
        ],
      );
    }
  }

  Widget buildExpandedCollapseWidget() {
    return StreamBuilder<bool>(
      stream: _syncImageInputCubit.isOptionsExpanded,
      builder: (context, isOptionsExpanded) {
        return Padding(
          padding: const EdgeInsets.only(top: Dimens.padding_12),
          child: MyInkWell(
            onTap: () {
              _syncImageInputCubit
                  .changeIsOptionsExpanded(!isOptionsExpanded.data!);
            },
            child: Icon(
                isOptionsExpanded.data ?? false
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.backgroundGrey900,
                size: Dimens.iconSize_32),
          ),
        );
      },
    );
  }

  Widget buildExpandedWidgets(
      ImageSyncState imageSyncState, ImageDetails imageDetails, bool isPaused) {
    return StreamBuilder<bool>(
      stream: _syncImageInputCubit.isOptionsExpanded,
      builder: (context, isOptionsExpanded) {
        if (isOptionsExpanded.hasData && isOptionsExpanded.data!) {
          return Column(
            children: [
              const SizedBox(height: Dimens.padding_8),
              HDivider(),
              buildResumeWidget(imageDetails, isPaused),
              buildEditWidget(imageSyncState, imageDetails),
              buildDeleteWidget(imageSyncState, imageDetails),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildResumeWidget(ImageDetails imageDetails, bool isPaused) {
    if (isPaused) {
      return MyInkWell(
        onTap: () {
          imageDetails.isUploadLaterSelected = false;
          _syncImageInputCubit.upload(
              widget.question, imageDetails, widget.onAnswerUpdate);
        },
        child: Row(
          children: [
            const Icon(Icons.play_arrow,
                color: AppColors.backgroundGrey900, size: Dimens.iconSize_32),
            const SizedBox(width: Dimens.padding_8),
            Text('Resume',
                overflow: TextOverflow.ellipsis,
                style: Get.textTheme.bodyText2SemiBold
                    ?.copyWith(color: AppColors.backgroundGrey900)),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildEditWidget(
      ImageSyncState imageSyncState, ImageDetails imageDetails) {
    return MyInkWell(
      onTap: () {
        if (imageSyncState != ImageSyncState.uploading) {
          launchImageEditorWidget(imageDetails);
        }
      },
      child: Row(
        children: [
          const SizedBox(
            width: Dimens.iconSize_32,
            height: Dimens.iconSize_32,
            child: Icon(Icons.edit,
                color: AppColors.backgroundGrey900, size: Dimens.iconSize_20),
          ),
          const SizedBox(width: Dimens.padding_8),
          Text('Edit',
              overflow: TextOverflow.ellipsis,
              style: Get.textTheme.bodyText2SemiBold
                  ?.copyWith(color: AppColors.backgroundGrey900)),
        ],
      ),
    );
  }

  Widget buildDeleteWidget(
      ImageSyncState imageSyncState, ImageDetails imageDetails) {
    return MyInkWell(
      onTap: () {
        if (imageSyncState != ImageSyncState.uploading) {
          _onDeleteTapped();
        }
      },
      child: Row(
        children: [
          const SizedBox(
            width: Dimens.iconSize_32,
            height: Dimens.iconSize_32,
            child: Icon(Icons.delete,
                color: AppColors.backgroundGrey900, size: Dimens.iconSize_20),
          ),
          const SizedBox(width: Dimens.padding_8),
          Text('Delete',
              overflow: TextOverflow.ellipsis,
              style: Get.textTheme.bodyText2SemiBold
                  ?.copyWith(color: AppColors.backgroundGrey900)),
        ],
      ),
    );
  }

  _onDeleteTapped() {
    Future<ConfirmAction?> deleteTap = Helper.asyncConfirmDialog(
        context, 'are_you_sure_want_to_delete_this_image'.tr,
        heading: 'delete_image'.tr,
        textOKBtn: 'yes'.tr,
        textCancelBtn: 'no'.tr);
    deleteTap.then((value) {
      if (value == ConfirmAction.OK) {
        _syncImageInputCubit.deleteImage(
            widget.question, widget.onAnswerUpdate);
      }
    });
  }

  Widget buildProgressWidget(ImageDetails imageDetails) {
    return StreamBuilder<dynamic>(
      stream: sl<RemoteStorageRepository>().getUploadPercentageStream(),
      builder: (context, snapshot) {
        int percentValue = snapshot.hasData ? (snapshot.data as int) : 0;
        double value =
            snapshot.hasData ? ((snapshot.data as int).toDouble() / 100) : 0.0;
        return Padding(
          padding: const EdgeInsets.only(top: Dimens.padding_12),
          child: Column(
            children: [
              AppLinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.backgroundGrey600,
                  valueColor: AppColors.success300),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.question.currentRoute == MRouter.arrayQuestionWidget
                      ? Expanded(
                          child: Text(
                            '$percentValue%',
                            style: Get.textTheme.bodyText2
                                ?.copyWith(color: context.theme.hintColor),
                          ),
                        )
                      : Text(
                          '$percentValue%',
                          style: Get.textTheme.bodyText2
                              ?.copyWith(color: context.theme.hintColor),
                        ),
                  buildFileSizeText(imageDetails, percentValue),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildFileSizeText(ImageDetails imageDetails, int uploadPercentage) {
    if (imageDetails.getFile() != null) {
      Tuple2<String, String> tuple2 = FileUtils.getFileUploadedSizeAndTotalSize(
          imageDetails.getFile()!.path,
          _syncImageInputCubit.totalFileSize,
          uploadPercentage);
      return widget.question.currentRoute == MRouter.arrayQuestionWidget
          ? Expanded(
              child: Text(
                '${tuple2.item1}/${tuple2.item2}',
                style: Get.textTheme.bodyText2
                    ?.copyWith(color: context.theme.hintColor),
              ),
            )
          : Text(
              '${tuple2.item1}/${tuple2.item2}',
              style: Get.textTheme.bodyText2
                  ?.copyWith(color: context.theme.hintColor),
            );
    } else {
      return Text(
        '0/0',
        style:
            Get.textTheme.bodyText2?.copyWith(color: context.theme.hintColor),
      );
    }
  }

  Widget buildChangeWidget(ImageSyncState imageSyncState) {
    if (imageSyncState == ImageSyncState.uploaded ||
        imageSyncState == ImageSyncState.answered) {
      return MyInkWell(
        onTap: () {
          _changeImage();
        },
        child: Text('change'.tr,
            style: Get.textTheme.bodyText1
                ?.copyWith(color: AppColors.primaryMain)),
      );
    } else {
      return const SizedBox();
    }
  }

  _changeImage() {
    if (!(widget.question.configuration?.isEditable ?? true)) {
      return;
    }
    switch (widget.question.configuration?.uploadFrom) {
      case UploadFromOption.camera:
        _captureImage();
        break;
      case UploadFromOption.gallery:
        _pickMedia();
        break;
      case UploadFromOption.cameraAndGallery:
        _showSelectCameraOrGalleryBottomSheet();
        break;
      default:
        _showSelectCameraOrGalleryBottomSheet();
        break;
    }
  }

  _showSelectCameraOrGalleryBottomSheet() {
    showSelectCameraOrGalleryBottomSheet(Get.context!, (onSelectOption) {
      if (onSelectOption == UploadFromOptionEntity.camera) {
        _captureImage();
      } else if (onSelectOption == UploadFromOptionEntity.gallery) {
        _pickMedia();
      }
    });
  }

  void _captureImage() async {
    if ((widget.question.configuration?.isEditable ?? true)) {
      ImageDetails imageDetails =
          ImageDetails(
              uploadLater: widget.fileConfiguration.uploadLater,
            question: widget.question
          );
      WidgetResult? cameraWidgetResult = await MRouter.pushNamed(
          MRouter.inAppCameraWidget,
          arguments: imageDetails);
      if (cameraWidgetResult != null &&
          cameraWidgetResult.event == Event.selected &&
          cameraWidgetResult.data is ImageDetails) {
        _syncImageInputCubit.upload(
            widget.question, cameraWidgetResult.data, widget.onAnswerUpdate);
      }
    }
  }

  void _pickMedia() {
    if ((widget.question.configuration?.isEditable ?? true)) {
      FilePickerHelper.pickMedia(
        widget.question.inputType?.getValue2(),
        widget.question.dataType,
        (result) async {
          File file = File(result.files.single.path ?? '');
          AppLog.i('File : ${file.path}');
          AppLog.i('Name : ${result.names[0]}');
          ImageDetails imageDetailsResult = ImageDetails(
              originalFileName: result.names[0],
              originalFilePath: file.path,
              fileQuality: FileQuality.high);
          _syncImageInputCubit.upload(
              widget.question, imageDetailsResult, widget.onAnswerUpdate);
        },
      );
    }
  }

  launchImageEditorWidget(ImageDetails imageDetails) async {
    WidgetResult? cameraImageResult = await MRouter.pushNamed(
        MRouter.imageEditorWidgetNew,
        arguments: imageDetails);
    if (cameraImageResult != null && cameraImageResult.data is ImageDetails) {
      _syncImageInputCubit.upload(
          widget.question, cameraImageResult.data, widget.onAnswerUpdate);
    }
  }
}
