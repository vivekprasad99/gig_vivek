import 'package:awign/workforce/aw_questions/data/model/configuration/audio/audio_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/widget/audio/cubit/sound_recorder_cubit.dart';
import 'package:awign/workforce/aw_questions/widget/audio/helper/recorder_state.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/utils/browser_helper.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_linear_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

class AudioRecordingInputWidget extends StatefulWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;
  late final AudioConfiguration _audioConfiguration;

  AudioRecordingInputWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key) {
    _audioConfiguration = question.configuration as AudioConfiguration;
  }

  @override
  State<AudioRecordingInputWidget> createState() => _AudioRecordingInputWidgetState();
}

class _AudioRecordingInputWidgetState extends State<AudioRecordingInputWidget> {
  final _soundRecorderCubit = sl<SoundRecorderCubit>();
  bool isUploading = false;

  @override
  void dispose() {
    _soundRecorderCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildSelectOptionOrAnswerWidget(context);
  }

  Widget buildSelectOptionOrAnswerWidget(BuildContext context) {
    return buildUnAnsweredWidget();
  }

  Widget buildUnAnsweredWidget() {
    return StreamBuilder<RecorderStatus>(
      stream: _soundRecorderCubit.recorderStatus,
      builder: (context, recorderStatus) {
        if (recorderStatus.hasData &&
            recorderStatus.data!.recorderState ==
                RecorderState.noneInitialized) {
          return buildRecordAudioIconWidget();
        } else if (recorderStatus.hasData &&
            (recorderStatus.data!.recorderState == RecorderState.initialized ||
                recorderStatus.data!.recorderState ==
                    RecorderState.recording)) {
          return buildRecordingWidgets(recorderStatus.data!);
        } else if (recorderStatus.hasData &&
            (recorderStatus.data!.recorderState == RecorderState.recorded ||
                recorderStatus.data!.recorderState == RecorderState.playing ||
                recorderStatus.data!.recorderState == RecorderState.paused ||
                recorderStatus.data!.recorderState == RecorderState.uploaded)) {
          return buildRecordedWidgets(recorderStatus.data!);
        } else if (recorderStatus.hasData &&
            recorderStatus.data!.recorderState == RecorderState.uploading) {
          return buildUploadingWidgets();
        } else if (recorderStatus.hasData &&
            recorderStatus.data!.recorderState ==
                RecorderState.failedUploading) {
          return buildUploadingFailedWidgets();
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildRecordAudioIconWidget() {
    return MyInkWell(
      onTap: () async {
        _soundRecorderCubit.initRecorder();
      },
      child: Container(
        // height: Dimens.etHeight_48,
        decoration: BoxDecoration(
          color: Get.theme.inputBoxBackgroundColor,
          border: Border.all(color: Get.theme.inputBoxBorderColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimens.radius_8),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(Dimens.padding_12, Dimens.padding_16,
            Dimens.padding_12, Dimens.padding_16),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.success300),
                padding: const EdgeInsets.all(Dimens.padding_8),
                child: const Icon(Icons.mic,
                    size: Dimens.iconSize_32, color: AppColors.backgroundWhite),
              ),
              const SizedBox(height: Dimens.padding_12),
              Text(
                'record_your_audio'.tr,
                style: Get.textTheme.bodyText1
                    ?.copyWith(color: context.theme.hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRecordingWidgets(RecorderStatus recorderStatus) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.inputBoxBackgroundColor,
        border: Border.all(color: Get.theme.inputBoxBorderColor),
        borderRadius: const BorderRadius.all(
          Radius.circular(Dimens.radius_8),
        ),
      ),
      padding: const EdgeInsets.all(Dimens.padding_16),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildRecordingTimeText(),
            buildStartStopRecordingButton(recorderStatus),
          ],
        ),
      ),
    );
  }

  Widget buildRecordingTimeText() {
    return StreamBuilder<RecordingDisposition>(
        stream: _soundRecorderCubit.recorderProgress,
        builder: (context, recorderProgress) {
          if (recorderProgress.hasData) {
            return Text(
                '${recorderProgress.data?.duration.toString().substring(2, 7)}',
                style: Get.textTheme.headline2);
          } else {
            return Text('00:00', style: Get.textTheme.headline2);
          }
        });
  }

  Widget buildStartStopRecordingButton(RecorderStatus recorderStatus) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
          Dimens.padding_16, Dimens.padding_4),
      child: RaisedRectButton(
        height: Dimens.btnHeight_40,
        backgroundColor:
            recorderStatus.recorderState == RecorderState.initialized
                ? AppColors.success300
                : AppColors.error400,
        fontSize: Dimens.font_14,
        icon: Icon(
            recorderStatus.recorderState == RecorderState.initialized
                ? Icons.mic
                : Icons.stop,
            color: AppColors.backgroundWhite,
            size: Dimens.iconSize_20),
        text: recorderStatus.recorderState == RecorderState.initialized
            ? 'start_recording'.tr
            : 'stop_recording'.tr,
        textColor: AppColors.backgroundWhite,
        onPressed: () {
          _soundRecorderCubit.toggleRecording();
        },
      ),
    );
  }

  Widget buildRecordedWidgets(RecorderStatus recorderStatus) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.inputBoxBackgroundColor,
        border: Border.all(color: Get.theme.inputBoxBorderColor),
        borderRadius: const BorderRadius.all(
          Radius.circular(Dimens.radius_8),
        ),
      ),
      padding: const EdgeInsets.all(Dimens.padding_16),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPlayPauseButton(recorderStatus),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildFileNameText(Dimens.padding_16),
                      buildPlayingSeekProgressBar(recorderStatus),
                    ],
                  ),
                ),
              ],
            ),
            buildSaveButton(recorderStatus),
            buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget buildPlayPauseButton(RecorderStatus recorderStatus) {
    return MyInkWell(
      onTap: () {
        _soundRecorderCubit.togglePlay();
      },
      child: Container(
        padding: const EdgeInsets.all(Dimens.padding_8),
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey400,
          border: Border.all(color: AppColors.backgroundGrey400),
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimens.radius_8),
          ),
        ),
        child: Icon(
            recorderStatus.recorderState == RecorderState.playing
                ? Icons.pause
                : Icons.play_arrow,
            size: Dimens.iconSize_32),
      ),
    );
  }

  Widget buildFileNameText(double padding) {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Text(_soundRecorderCubit.getFileName(),
            overflow: TextOverflow.ellipsis, style: Get.textTheme.bodyText2),
      ),
    );
  }

  Widget buildPlayingSeekProgressBar(RecorderStatus recorderStatus) {
    if (recorderStatus.recorderState == RecorderState.playing) {
      return StreamBuilder<Duration>(
          stream: _soundRecorderCubit.duration,
          builder: (context, duration) {
            if (duration.hasData) {
              return StreamBuilder<Duration>(
                  stream: _soundRecorderCubit.position,
                  builder: (context, position) {
                    if (position.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Slider(
                              min: 0,
                              max: duration.data!.inSeconds.toDouble(),
                              value: position.data!.inSeconds.toDouble(),
                              onChanged: (v) {
                                _soundRecorderCubit
                                    .seekTo(Duration(seconds: v.toInt()));
                              }),
                          buildPlayingDurationText(position.data!),
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  });
            } else {
              return const SizedBox();
            }
          });
    } else {
      return const SizedBox();
    }
  }

  Widget buildPlayingDurationText(Duration position) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text(position.toString().substring(2, 7),
          overflow: TextOverflow.ellipsis,
          style: Get.textTheme.bodyText2?.copyWith(fontSize: Dimens.font_12)),
    );
  }

  Widget buildSaveButton(RecorderStatus recorderStatus) {
    if (recorderStatus.recorderState != RecorderState.uploaded &&
        !_soundRecorderCubit.isUploaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, Dimens.padding_32, 0, 0),
        child: RaisedRectButton(
          height: Dimens.btnHeight_40,
          backgroundColor: AppColors.success300,
          fontSize: Dimens.font_14,
          text: 'save'.tr,
          textColor: AppColors.backgroundWhite,
          elevation: 0,
          onPressed: () {
            _soundRecorderCubit.upload(widget.question, widget.onAnswerUpdate);
          },
        ),
      );
    } else {
      return const SizedBox(height: Dimens.padding_16);
    }
  }

  Widget buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.margin_16, 0, 0),
      child: CustomTextButton(
        height: Dimens.btnHeight_40,
        text: 'record_again'.tr,
        fontSize: Dimens.font_14,
        backgroundColor: AppColors.transparent,
        borderColor: AppColors.backgroundGrey800,
        textColor: AppColors.backgroundGrey800,
        onPressed: () {
          _soundRecorderCubit.recordAgain();
        },
      ),
    );
  }

  Widget buildUploadingWidgets() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.inputBoxBackgroundColor,
        border: Border.all(color: Get.theme.inputBoxBorderColor),
        borderRadius: const BorderRadius.all(
          Radius.circular(Dimens.radius_8),
        ),
      ),
      padding: const EdgeInsets.all(Dimens.padding_16),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildFileNameText(0),
            buildUploadProgressWidget(AppColors.backgroundGrey600),
            buildUploadCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget buildUploadProgressWidget(Color backgroundColor) {
    return StreamBuilder<dynamic>(
        stream: sl<RemoteStorageRepository>().getUploadPercentageStream(),
        builder: (context, snapshot) {
          int percentValue = snapshot.hasData ? (snapshot.data as int) : 0;
          double value = snapshot.hasData
              ? ((snapshot.data as int).toDouble() / 100)
              : 0.0;
          return Padding(
            padding: const EdgeInsets.only(top: Dimens.padding_16),
            child: Column(
              children: [
                AppLinearProgressIndicator(
                    value: value,
                    backgroundColor: backgroundColor,
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
        _soundRecorderCubit.pathToSaveAudio!,
        _soundRecorderCubit.totalFileSize,
        uploadPercentage);
    return Text(
      '${tuple2.item1}/${tuple2.item2}',
      style: Get.textTheme.bodyText2?.copyWith(color: context.theme.hintColor),
    );
  }

  Widget buildUploadCancelButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.margin_16, 0, 0),
      child: CustomTextButton(
        height: Dimens.btnHeight_40,
        text: 'cancel'.tr,
        fontSize: Dimens.font_14,
        backgroundColor: AppColors.transparent,
        borderColor: AppColors.backgroundGrey800,
        textColor: AppColors.backgroundGrey800,
        onPressed: () {
          _soundRecorderCubit.cancelUploading();
        },
      ),
    );
  }

  Widget buildUploadingFailedWidgets() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.inputBoxBackgroundColor,
        border: Border.all(color: Get.theme.inputBoxBorderColor),
        borderRadius: const BorderRadius.all(
          Radius.circular(Dimens.radius_8),
        ),
      ),
      padding: const EdgeInsets.all(Dimens.padding_16),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildFileNameText(0),
            buildUploadProgressWidget(AppColors.error400),
            Row(
              children: [
                Expanded(child: buildRetryButton()),
                const SizedBox(width: Dimens.padding_16),
                Expanded(child: buildUploadCancelButton()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRetryButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.margin_16, 0, 0),
      child: CustomTextButton(
        height: Dimens.btnHeight_40,
        text: 'retry'.tr,
        fontSize: Dimens.font_14,
        backgroundColor: AppColors.transparent,
        borderColor: AppColors.backgroundGrey800,
        textColor: AppColors.backgroundGrey800,
        onPressed: () {
          _soundRecorderCubit.upload(widget.question, widget.onAnswerUpdate);
        },
      ),
    );
  }

  Widget buildChangeButton() {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.transparent,
      ),
      onPressed: () {},
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
}
