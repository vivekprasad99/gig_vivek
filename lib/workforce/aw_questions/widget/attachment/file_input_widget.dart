import 'dart:io';

import 'package:awign/workforce/aw_questions/data/model/configuration/attachment/file_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/helper/file_picker_helper.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/browser_helper.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_linear_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import '../../../core/di/app_injection_container.dart';
import '../../../file_storage_remote/data/model/aws_upload_result.dart';

class FileInputWidget extends StatefulWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;
  late final FileConfiguration _fileConfiguration;

  FileInputWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key) {
    _fileConfiguration = question.configuration as FileConfiguration;
  }

  @override
  State<FileInputWidget> createState() => _FileInputWidgetState();
}

class _FileInputWidgetState extends State<FileInputWidget> {
  String? fileName;
  Stream? uploadPercentageStream;
  bool isUploading = false;
  File? file;
  int totalFileSize = 0;
  // final RemoteStorageRepository _remoteStorageRepository =
  //     RemoteStorageRepository();

  @override
  Widget build(BuildContext context) {
    return buildSelectOptionOrAnswerWidget(context);
  }

  Widget buildSelectOptionOrAnswerWidget(BuildContext context) {
    if (widget.question.answerUnit?.hasAnswered() ?? false) {
      return buildAnswerWidget(context);
    }
    if (fileName != null) {
      return buildAnswerWidget(context);
    } else {
      return buildSelectOptionWidget(context);
    }
  }

  Widget buildSelectOptionWidget(BuildContext context) {
    String hint = 'select_file'.tr;
    switch (widget.question.inputType?.getValue2()) {
      case SubType.image:
        hint = 'select_image'.tr;
        break;
      case SubType.audio:
        hint = 'select_audio'.tr;
        break;
      case SubType.video:
        hint = 'select_video'.tr;
        break;
      case SubType.pdf:
        hint = 'select_pdf'.tr;
        break;
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
              SvgPicture.asset('assets/images/ic_file_upload.svg'),
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

  Widget buildAnswerWidget(BuildContext context) {
    String answerValue = '';
    if (widget.question.answerUnit?.stringValue != null) {
      answerValue = FileUtils.getFileNameFromFilePath(
          widget.question.answerUnit!.stringValue!);
    } else if (fileName != null) {
      answerValue = fileName!;
    }
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.inputBoxBackgroundColor,
        border: Border.all(color: Get.theme.inputBoxBorderColor),
        borderRadius: const BorderRadius.all(
          Radius.circular(Dimens.radius_8),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Column(
        children: [
          const SizedBox(height: Dimens.padding_12),
          Row(
            children: [
              SvgPicture.asset('assets/images/ic_file_upload.svg'),
              const SizedBox(width: Dimens.padding_12),
              Flexible(
                  child: Text(answerValue, style: Get.textTheme.bodyText1)),
            ],
          ),
          buildProgressOrButtonsWidget(),
        ],
      ),
    );
  }

  Widget buildProgressOrButtonsWidget() {
    if (isUploading) {
      return buildProgressWidget();
    } else if (!isUploading &&
        (widget.question.answerUnit?.hasAnswered() ?? false)) {
      return Row(
        children: [
          buildChangeButton(),
          buildViewButton(),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildProgressWidget() {
    return StreamBuilder<dynamic>(
        stream: sl<RemoteStorageRepository>().getUploadPercentageStream(),
        builder: (context, snapshot) {
          int percentValue = snapshot.hasData ? (snapshot.data as int) : 0;
          double value = snapshot.hasData
              ? ((snapshot.data as int).toDouble() / 100)
              : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimens.padding_12),
            child: Column(
              children: [
                AppLinearProgressIndicator(
                    value: value,
                    backgroundColor: AppColors.backgroundGrey600,
                    valueColor: AppColors.success300),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$percentValue%',
                      style: Get.textTheme.bodyText2
                          ?.copyWith(color: context.theme.hintColor),
                    ),
                    buildFileSizeText(percentValue),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Widget buildFileSizeText(int uploadPercentage) {
    Tuple2<String, String> tuple2 = FileUtils.getFileUploadedSizeAndTotalSize(
        file!.path, totalFileSize, uploadPercentage);
    return Text(
      '${tuple2.item1}/${tuple2.item2}',
      style: Get.textTheme.bodyText2?.copyWith(color: context.theme.hintColor),
    );
  }

  Widget buildChangeButton() {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.transparent,
      ),
      onPressed: () {
        _pickMedia();
      },
      child: Text(
        'change'.tr,
        style: Get.textTheme.bodyText2?.copyWith(
            color: Get.theme.iconColorHighlighted, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildViewButton() {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.transparent,
      ),
      onPressed: () {
        if (widget.question.answerUnit?.stringValue != null) {
          BrowserHelper.customTab(
              context, widget.question.answerUnit!.stringValue!);
        }
      },
      child: Text(
        'view'.tr,
        style: Get.textTheme.bodyText2?.copyWith(
            color: Get.theme.iconColorHighlighted, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _pickMedia() {
    if ((widget.question.configuration?.isEditable ?? true)) {
      FilePickerHelper.pickMedia(
          widget.question.inputType?.getValue2(), widget.question.dataType,
          (result) async {
        File file = File(result.files.single.path ?? '');
        AppLog.i('File : ${file.path}');
        AppLog.i('Name : ${result.names[0]}');
        setState(() {
          this.file = file;
          fileName = result.names[0];
          isUploading = true;
        });
        FileUtils.getFileSizeInBytes(file.path, 2).then((fileSize) {
          setState(() {
            totalFileSize = fileSize;
          });
        });
        String? updatedFileName, s3FolderPath;
        updatedFileName = file.name?.cleanForUrl();
        s3FolderPath =
            widget.question.parentReference?.getUploadPath(fileName!);
        if (updatedFileName != null && s3FolderPath != null) {
          AWSUploadResult? uploadResult = await sl<RemoteStorageRepository>()
              .uploadFile(file, updatedFileName, s3FolderPath);
          setState(() {
            isUploading = false;
          });
          widget.question.answerUnit?.stringValue = uploadResult?.url;
          widget.onAnswerUpdate(widget.question);
        }
      });
    }
  }
}
