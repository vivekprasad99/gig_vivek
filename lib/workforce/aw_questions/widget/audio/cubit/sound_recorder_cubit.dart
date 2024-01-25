import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:awign/workforce/aw_questions/data/model/parent_reference/application_reference.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/widget/audio/helper/recorder_state.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/di/app_injection_container.dart';
import '../../../../file_storage_remote/data/model/aws_upload_result.dart';

part 'sound_recorder_state.dart';

class SoundRecorderCubit extends Cubit<SoundRecorderState> {
  SoundRecorderCubit() : super(SoundRecorderInitial());
  String? pathToSaveAudio;
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialised = false;

  bool get isRecording => _audioRecorder!.isRecording;
  AudioPlayer? _audioPlayer;
  bool isPlaying = false;
  bool isUploaded = false;
  int totalFileSize = 0;

  final _recorderStatus =
      BehaviorSubject<RecorderStatus>.seeded(RecorderStatus());

  Stream<RecorderStatus> get recorderStatus => _recorderStatus.stream;

  Function(RecorderStatus) get changeRecorderStatus => _recorderStatus.sink.add;

  final _recorderProgress = BehaviorSubject<RecordingDisposition>();

  Stream<RecordingDisposition>? get recorderProgress =>
      _audioRecorder?.onProgress;

  final _duration = BehaviorSubject<Duration>.seeded(Duration.zero);

  Stream<Duration>? get duration => _duration.stream;

  final _position = BehaviorSubject<Duration>.seeded(Duration.zero);

  Stream<Duration>? get position => _position.stream;

  Future initRecorder() async {
    _audioRecorder = FlutterSoundRecorder();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      Helper.showInfoToast('Microphone permission required.');
      return;
    }

    TargetPlatform? platform = Theme.of(Get.context!).platform;
    final storagePermissionStatus =
        await FileUtils.checkStoragePermission(platform);
    if (!storagePermissionStatus) {
      Helper.showInfoToast('Storage permission required.');
      return;
    }

    /*pathToSaveAudio = await FileUtils.getAudioFilePath(Get.context!);*/

    await _audioRecorder?.openAudioSession();
    _audioRecorder?.setSubscriptionDuration(const Duration(milliseconds: 500));

    initAudioPlayer();

    _isRecorderInitialised = true;
    changeRecorderStatus(
        RecorderStatus(recorderState: RecorderState.initialized));
  }

  void initAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _audioPlayer?.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        isPlaying = true;
        changeRecorderStatus(
            RecorderStatus(recorderState: RecorderState.playing));
      } else if (event == PlayerState.paused) {
        isPlaying = false;
        changeRecorderStatus(
            RecorderStatus(recorderState: RecorderState.paused));
      }
    });
    _audioPlayer?.onDurationChanged.listen((newDuration) {
      if (!_duration.isClosed) {
        _duration.sink.add(newDuration);
      }
    });
    _audioPlayer?.onPositionChanged.listen((newPosition) {
      if (!_position.isClosed) {
        _position.sink.add(newPosition);
        if (_position.value.inSeconds == _duration.value.inSeconds) {
          isPlaying = false;
          changeRecorderStatus(
              RecorderStatus(recorderState: RecorderState.paused));
        }
      }
    });
  }

  @override
  Future<void> close() {
    if (_isRecorderInitialised) {
      _audioRecorder?.closeAudioSession();
      _audioRecorder = null;
      _isRecorderInitialised = false;
      _audioPlayer?.dispose();
      changeRecorderStatus(
          RecorderStatus(recorderState: RecorderState.noneInitialized));
    }
    return super.close();
  }

  Future _record() async {
    if (!_isRecorderInitialised) return;
    pathToSaveAudio = await FileUtils.getAudioFilePath(Get.context!);
    changeRecorderStatus(
        RecorderStatus(recorderState: RecorderState.recording));
    await _audioRecorder?.startRecorder(toFile: pathToSaveAudio);
  }

  Future _stop() async {
    if (!_isRecorderInitialised) return;
    await _audioRecorder?.stopRecorder();
    setAudio();
    changeRecorderStatus(RecorderStatus(recorderState: RecorderState.recorded));
  }

  Future toggleRecording() async {
    if (_audioRecorder!.isStopped) {
      await _record();
    } else {
      await _stop();
    }
  }

  Future setAudio() async {
    await _audioPlayer?.setSourceDeviceFile(pathToSaveAudio!);
    await _audioPlayer?.stop();
    FileUtils.getFileSizeInBytes(pathToSaveAudio!, 2).then((fileSize) {
      totalFileSize = fileSize;
    });
  }

  Future playAudio() async {
    if (!isPlaying) {
      isPlaying = true;
      await _audioPlayer?.resume();
      changeRecorderStatus(RecorderStatus(recorderState: RecorderState.paused));
    }
  }

  Future pauseAudio() async {
    if (isPlaying) {
      isPlaying = false;
      await _audioPlayer?.pause();
      changeRecorderStatus(
          RecorderStatus(recorderState: RecorderState.playing));
    }
  }

  Future togglePlay() async {
    if (isPlaying) {
      pauseAudio();
    } else {
      playAudio();
    }
  }

  Future seekTo(Duration position) async {
    await _audioPlayer?.seek(position);
    await _audioPlayer?.resume();
  }

  Future recordAgain() async {
    isPlaying = false;
    isUploaded = false;
    changeRecorderStatus(
        RecorderStatus(recorderState: RecorderState.initialized));
  }

  Future upload(
      Question question, Function(Question question) onAnswerUpdate) async {
    changeRecorderStatus(
        RecorderStatus(recorderState: RecorderState.uploading));
    pauseAudio();
    ApplicationReference applicationReference =
        question.parentReference as ApplicationReference;
    String updatedFileName = applicationReference
        .getUploadPath(FileUtils.getFileNameFromFilePath(pathToSaveAudio!))
        .split('/')
        .last;
    String s3FolderPath = applicationReference
        .getUploadPath(FileUtils.getFileNameFromFilePath(pathToSaveAudio!));
    AppLog.e('s3FolderPath--$s3FolderPath updatedFileName--$updatedFileName');
    AWSUploadResult? uploadResult = await sl<RemoteStorageRepository>()
        .uploadFile(File(pathToSaveAudio!), updatedFileName, s3FolderPath);
    question.answerUnit?.stringValue = uploadResult?.url;
    onAnswerUpdate(question);
    isUploaded = true;
    changeRecorderStatus(RecorderStatus(recorderState: RecorderState.uploaded));
  }

  Future cancelUploading() async {
    changeRecorderStatus(RecorderStatus(recorderState: RecorderState.uploaded));
  }

  String getFileName() {
    return FileUtils.getFileNameFromFilePath(pathToSaveAudio!);
  }
}
