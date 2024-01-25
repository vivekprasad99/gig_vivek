import 'dart:io';

import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/attachment/file_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/data/image_sync_state.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/helper/file_picker_helper.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../core/data/local/database/boxes.dart';
import '../../../../../core/widget/bottom_sheet/select_camera_or_gallery_bottom_sheet/widget/select_camera_or_gallery_bottom_sheet.dart';
import '../../../../../file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';
import '../../../../../onboarding/data/model/application_question/application_question_response.dart';
import '../../../../cubit/upload_or_sync_process_cubit/upload_or_sync_process_cubit.dart';
import '../../../../data/model/data_type.dart';
import '../cubit/async_image_input_cubit.dart';

class AsyncImageInputWidget extends StatefulWidget {
  Question question;
  Function(Question question, {WidgetResult? widgetResult}) onAnswerUpdate;
  late FileConfiguration fileConfiguration;

  AsyncImageInputWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key) {
    fileConfiguration = question.configuration as FileConfiguration;
  }

  @override
  State<AsyncImageInputWidget> createState() => _AsyncImageInputWidgetState();
}

class _AsyncImageInputWidgetState extends State<AsyncImageInputWidget> {
  Stream? uploadPercentageStream;
  bool isUploading = false;
  final _asyncImageInputCubit = sl<AsyncImageInputCubit>();

  @override
  void initState() {
    super.initState();
    if (widget.question.answerUnit?.hasAnswered() ?? false) {
      if (widget.question.answerUnit?.imageDetails == null) {
        ImageDetails imageDetails = ImageDetails(
            url: widget.question.answerUnit?.stringValue,
            uploadLater: widget.fileConfiguration.uploadLater,
            dataType: widget.question.dataType ?? DataType.single,
            isAsync: widget.question.configuration?.isAsync ?? false);
        widget.question.answerUnit?.imageDetails = imageDetails;
      }
      _asyncImageInputCubit.changeImageSyncStatus(ImageSyncStatus(
          imageSyncState: ImageSyncState.answered,
          data: widget.question.answerUnit?.imageDetails));
    } else if (widget.question.answerUnit?.imageDetails != null) {
      _updateImageDetails();
    }
    Boxes.getUploadEntityBox().listenable().addListener(() {
      _asyncImageInputCubit.checkDBAndUpdateQuestionList(widget.question);
    });
  }

  _updateImageDetails() {
    _asyncImageInputCubit.changeImageSyncStatus(ImageSyncStatus(
        imageSyncState: ImageSyncState.get(
            widget.question.answerUnit?.imageDetails?.uploadStatus),
        data: widget.question.answerUnit?.imageDetails));
    _asyncImageInputCubit
        .calculateTotalFileSized(widget.question.answerUnit!.imageDetails!);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ImageSyncStatus>(
      stream: _asyncImageInputCubit.imageSyncStatus,
      builder: (context, imageSyncStatus) {
        if (imageSyncStatus.hasData) {
          if (imageSyncStatus.data!.data is ImageDetails) {
            (imageSyncStatus.data!.data as ImageDetails).question = widget.question;
          }
          switch (imageSyncStatus.data!.imageSyncState) {
            case ImageSyncState.unAnswered:
              return buildSelectOptionWidget(context);
            case ImageSyncState.uploading:
              return buildUploadingWidget(
                  context,
                  imageSyncStatus.data!.imageSyncState,
                  imageSyncStatus.data!.data);
            case ImageSyncState.paused:
              return buildPausedOrUploadedWidget(
                  context,
                  imageSyncStatus.data!.imageSyncState,
                  imageSyncStatus.data!.data,
                  true);
            case ImageSyncState.answered:
            case ImageSyncState.uploaded:
              if (imageSyncStatus.data!.imageSyncState ==
                      ImageSyncState.uploaded &&
                  !widget.question.hasAnswered()) {
                widget.question.answerUnit?.stringValue =
                    (imageSyncStatus.data!.data as ImageDetails).url;
                widget.onAnswerUpdate(widget.question,
                    widgetResult:
                        WidgetResult(data: imageSyncStatus.data!.data));
              }
              return buildPausedOrUploadedWidget(
                  context,
                  imageSyncStatus.data!.imageSyncState,
                  imageSyncStatus.data!.data,
                  false);
            case ImageSyncState.syncing:
              return buildPausedOrUploadedWidget(
                  context,
                  imageSyncStatus.data!.imageSyncState,
                  imageSyncStatus.data!.data,
                  false);
            case ImageSyncState.queued:
              return buildPausedOrUploadedWidget(
                  context,
                  imageSyncStatus.data!.imageSyncState,
                  imageSyncStatus.data!.data,
                  false);
            case ImageSyncState.failed:
              return buildPausedOrUploadedWidget(
                  context,
                  imageSyncStatus.data!.imageSyncState,
                  imageSyncStatus.data!.data,
                  false);
          }
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
                        buildPausedOrUploadedText(
                            imageSyncState, imageDetails, isPaused),
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
        child: imageDetails.url != null
            ? NetworkImageLoader(
                url: imageDetails.url!,
                filterQuality: FilterQuality.high,
                fit: BoxFit.fitWidth,
                width: Dimens.imageWidth_56,
                height: Dimens.imageHeight_56,
              )
            : (imageDetails.getFile() != null
                ? Image.file(
                    imageDetails.getFile()!,
                    width: Dimens.imageWidth_56,
                    height: Dimens.imageHeight_56,
                    fit: BoxFit.fitWidth,
                  )
                : const SizedBox()),
      ),
    );
  }

  Widget buildFileNameWidget(ImageDetails imageDetails) {
    return Text(imageDetails.getFileName() ?? '',
        overflow: TextOverflow.ellipsis,
        style: Get.textTheme.bodyText2SemiBold);
  }

  Widget buildPausedOrUploadedText(
      ImageSyncState imageSyncState, ImageDetails imageDetails, bool isPaused) {
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
      IconData iconData = Icons.check_circle;
      String statusName = 'Uploaded';
      Color iconColor = AppColors.pine;
      switch(imageSyncState) {
        case ImageSyncState.syncing:
          iconData = Icons.schedule;
          statusName = 'Syncing';
          iconColor = AppColors.orange;
          break;
        case ImageSyncState.queued:
          iconData = Icons.schedule;
          statusName = 'Queued';
          iconColor = AppColors.orange;
          break;
        case ImageSyncState.failed:
          iconData = Icons.warning;
          statusName = 'Failed';
          iconColor = AppColors.googleRed;
          break;
        default:
          iconData = Icons.check_circle;
          statusName = 'Uploaded';
          iconColor = AppColors.pine;
          break;
      }
      return Row(
        children: [
          Icon(iconData,
              color: iconColor, size: Dimens.iconSize_16),
          const SizedBox(width: Dimens.padding_8),
          Text(statusName,
              overflow: TextOverflow.ellipsis,
              style: Get.textTheme.bodyText2SemiBold
                  ?.copyWith(color: iconColor)),
        ],
      );
    }
  }

  Widget buildExpandedCollapseWidget() {
    return StreamBuilder<bool>(
      stream: _asyncImageInputCubit.isOptionsExpanded,
      builder: (context, isOptionsExpanded) {
        return Padding(
          padding: const EdgeInsets.only(top: Dimens.padding_12),
          child: MyInkWell(
            onTap: () {
              _asyncImageInputCubit
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
      stream: _asyncImageInputCubit.isOptionsExpanded,
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
          _asyncImageInputCubit.resumeUploading(widget.question);
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
        _asyncImageInputCubit.deleteImage(
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
          _asyncImageInputCubit.totalFileSize,
          uploadPercentage);
      AppLog.e('Percent: ${tuple2.item1}/${tuple2.item2}');
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
        imageSyncState == ImageSyncState.answered ||
        imageSyncState == ImageSyncState.paused) {
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
      ImageDetails imageDetails = ImageDetails(
          uploadLater: widget.fileConfiguration.uploadLater,
          dataType: widget.question.dataType ?? DataType.single,
          isAsync: widget.question.configuration?.isAsync ?? false,
          question: widget.question);
      WidgetResult? cameraWidgetResult = await MRouter.pushNamed(
          MRouter.inAppCameraWidget,
          arguments: imageDetails);
      if (cameraWidgetResult != null &&
          cameraWidgetResult.event == Event.selected &&
          cameraWidgetResult.data is List<ImageDetails>) {
        if (widget.question.dataType == DataType.single) {
          widget.question.answerUnit?.imageDetails = cameraWidgetResult.data[0];
          await _asyncImageInputCubit.insertImageAndStartUploading(cameraWidgetResult.data[0]);
          widget.onAnswerUpdate(widget.question, widgetResult: WidgetResult(data: cameraWidgetResult.data[0]));
        }
      } else if (cameraWidgetResult != null &&
          cameraWidgetResult.event == Event.selected &&
          cameraWidgetResult.data is ImageDetails) {
        widget.question.answerUnit?.imageDetails = cameraWidgetResult.data;
        _asyncImageInputCubit.insertImageAndStartUploading(cameraWidgetResult.data);
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
          ImageDetails imageDetailsResult = ImageDetails(
              originalFileName: result.names[0],
              originalFilePath: file.path,
              fileQuality: FileQuality.high,
              question: widget.question,
              isAsync: widget.question.configuration?.isAsync ?? false);
          if (widget.question.dataType == DataType.single) {
            widget.question.answerUnit?.imageDetails = imageDetailsResult;
            await _asyncImageInputCubit
                .insertImageAndStartUploading(imageDetailsResult);
            widget.onAnswerUpdate(widget.question,
                widgetResult: WidgetResult(data: imageDetailsResult));
          } else {
            widget.question.answerUnit?.imageDetails = imageDetailsResult;
            _asyncImageInputCubit
                .insertImageAndStartUploading(imageDetailsResult);
          }
        },
      );
    }
  }

  launchImageEditorWidget(ImageDetails imageDetails) async {
    WidgetResult? widgetResult = await MRouter.pushNamed(
        MRouter.imageEditorWidgetNew,
        arguments: imageDetails);
    if (widgetResult?.event == Event.selected &&
        (widgetResult?.data is List<ImageDetails> || widgetResult?.data is ImageDetails)) {
      if (widgetResult?.data is List<ImageDetails>) {
        List<ImageDetails> imageDetailsList = widgetResult!.data!;
        if (imageDetailsList.length == 1) {
          widget.question.answerUnit!.imageDetails = imageDetailsList[0];
          if ((widget.question.configuration?.isAsync ?? false) &&
              widget.question.dataType == DataType.single) {
            sl<UploadOrSyncProcessCubit>().start();
          }
          widget.onAnswerUpdate(widget.question,
              widgetResult: WidgetResult(data: imageDetailsList[0]));
        }
      } else if (widgetResult?.data is ImageDetails){
        ImageDetails imageDetails = widgetResult!.data!;
          widget.question.answerUnit!.imageDetails = imageDetails;
          widget.onAnswerUpdate(widget.question,
              widgetResult: WidgetResult(data: imageDetails));
      }
    }
  }
}
