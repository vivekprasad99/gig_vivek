import 'dart:io';

import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:internet_file/internet_file.dart';
import 'package:rxdart/rxdart.dart';

import '../../../workforce/core/data/local/repository/upload_entry/upload_entry_local_repository.dart';

part 'image_editor_widget_state.dart';

class ImageEditorWidgetCubit extends Cubit<ImageEditorWidgetState> {
  final UploadEntryLocalRepository _uploadEntryLocalRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _imageDetailsList = BehaviorSubject<List<ImageDetails>>();

  Stream<List<ImageDetails>> get imageDetailsListStream =>
      _imageDetailsList.stream;

  Function(List<ImageDetails>) get changeImageDetailsList =>
      _imageDetailsList.sink.add;

  final _rotationValue = BehaviorSubject<int>.seeded(0);

  Stream<int> get rotationValueStream => _rotationValue.stream;

  final _selectedImageQuality =
      BehaviorSubject<FileQuality>.seeded(FileQuality.low);

  Stream<FileQuality> get selectedImageQuality => _selectedImageQuality.stream;

  final _selectedImageIndex = BehaviorSubject<int>.seeded(0);

  Stream<int> get selectedImageIndexStream => _selectedImageIndex.stream;

  int get selectedImageIndexValue => _selectedImageIndex.value;

  Function(int) get changeSelectedImageIndex => _selectedImageIndex.sink.add;

  ImageEditorWidgetCubit(this._uploadEntryLocalRepository)
      : super(ImageEditorWidgetInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _imageDetailsList.close();
    _rotationValue.close();
    _selectedImageQuality.close();
    _selectedImageIndex.close();
    return super.close();
  }

  ImageDetails? getSelectedImageDetails() {
    if (!_imageDetailsList.isClosed && _imageDetailsList.hasValue) {
      List<ImageDetails> imageDetailsList = _imageDetailsList.value;
      ImageDetails imageDetails = imageDetailsList[_selectedImageIndex.value];
      return imageDetails;
    } else {
      return null;
    }
  }

  List<ImageDetails>? getImageDetailsList() {
    if (!_imageDetailsList.isClosed && _imageDetailsList.hasValue) {
      List<ImageDetails> imageDetailsList = _imageDetailsList.value;
      return imageDetailsList;
    } else {
      return null;
    }
  }

  void updateImageDetailsList(ImageDetails? imageDetails,
      {bool isRetake = false}) {
    if (imageDetails != null &&
        !_imageDetailsList.isClosed &&
        _imageDetailsList.hasValue) {
      List<ImageDetails> imageDetailsList = _imageDetailsList.value;
      if (isRetake) {
        ImageDetails imageDetails = imageDetailsList[_selectedImageIndex.value];
        imageDetails.deleteFile();
      }
      imageDetailsList[_selectedImageIndex.value] = imageDetails;
      changeImageDetailsList(imageDetailsList);
    }
  }

  void changeSelectedImageQuality(FileQuality fileQuality) {
    if (!_selectedImageQuality.isClosed &&
        !_imageDetailsList.isClosed &&
        _imageDetailsList.hasValue) {
      _selectedImageQuality.sink.add(fileQuality);
      ImageDetails? imageDetails = getSelectedImageDetails();
      imageDetails?.fileQuality = fileQuality;
      updateImageDetailsList(imageDetails);
    }
  }

  void rotateImage() {
    if (!_rotationValue.isClosed) {
      int value = _rotationValue.value;
      if (value < 3) {
        value = value + 1;
      } else {
        value = 0;
      }
      ImageDetails? imageDetails = getSelectedImageDetails();
      imageDetails?.rotationAngle = value;
      updateImageDetailsList(imageDetails);
      _rotationValue.sink.add(value);
    }
  }

  void compressImage() async {
    changeUIStatus(UIStatus(isOnScreenLoading: true));
    ImageDetails? imageDetails = getSelectedImageDetails();
    if (imageDetails != null && !_rotationValue.isClosed) {
      if (imageDetails.originalFilePath == null &&
          imageDetails.lowQualityFilePath == null &&
          imageDetails.url != null) {
        downloadAndSaveFile(imageDetails);
        return;
      }
      if (imageDetails.lowQualityFilePath != null) {
        changeUIStatus(UIStatus(isOnScreenLoading: false));
        return;
      }
      int rotateValue = _rotationValue.value;
      AppLog.i('Rotate value: $rotateValue');
      int rotateAngle = getRotationAngle(rotateValue);
      AppLog.i('Rotate angle: $rotateAngle');
      if (imageDetails.lowQualityFilePath == null) {
        String? targetPath = await FileUtils.getImageFilePath(Get.context!);
        imageDetails.lowQualityFilePath = targetPath;
      }
      try {
        var result = await FlutterImageCompress.compressAndGetFile(
          imageDetails.originalFilePath!,
          imageDetails.lowQualityFilePath!,
          quality: 50,
          rotate: rotateAngle,
        );
      } catch (e, stacktrace) {
        AppLog.e('compressImage : ${e.toString()} \n${stacktrace.toString()}');
      }
      imageDetails.fileQuality = FileQuality.low;
      changeSelectedImageQuality(FileQuality.low);
      updateImageDetailsList(imageDetails);
    }
    changeUIStatus(UIStatus(isOnScreenLoading: false));
  }

  int getRotationAngle(int rotateValue) {
    int rotateAngle = 0;
    switch (rotateValue) {
      case 0:
        rotateAngle = 0;
        break;
      case 1:
        rotateAngle = 90;
        break;
      case 2:
        rotateAngle = 180;
        break;
      case 3:
        rotateAngle = 270;
        break;
    }
    return rotateAngle;
  }

  int getRotateValue(int rotationAngle) {
    int rotateValue = 0;
    switch (rotationAngle) {
      case 0:
        rotateValue = 0;
        break;
      case 90:
        rotateValue = 1;
        break;
      case 180:
        rotateValue = 2;
        break;
      case 270:
        rotateValue = 3;
        break;
    }
    return rotateValue;
  }

  void changeRotationValue() {
    if (!_rotationValue.isClosed) {
      ImageDetails? imageDetails = getSelectedImageDetails();
      int rotationAngle = imageDetails?.rotationAngle ?? 0;
      _rotationValue.sink.add(getRotateValue(rotationAngle));
    }
  }

  void goToNextImageOrInsertImages(bool isUploadLaterSelected) {
    ImageDetails? imageDetails = getSelectedImageDetails();
    imageDetails?.isUploadLaterSelected = isUploadLaterSelected;
    updateImageDetailsList(imageDetails);
    if (!_imageDetailsList.isClosed &&
        _imageDetailsList.hasValue &&
        selectedImageIndexValue < _imageDetailsList.value.length - 1) {
      changeSelectedImageIndex(selectedImageIndexValue + 1);
    } else if (!_imageDetailsList.isClosed && _imageDetailsList.hasValue) {
      insertImages();
    }
  }

  Future<void> insertImages() async {
    changeUIStatus(UIStatus(isOnScreenLoading: true));
    if (!_imageDetailsList.isClosed && _imageDetailsList.hasValue) {
      List<ImageDetails> imageDetailsList = _imageDetailsList.value;
      List<ImageDetails> tempImageDetailsList = [];
      tempImageDetailsList.addAll(imageDetailsList);
      for (int i = 0; i < imageDetailsList.length; i++) {
        ImageDetails imageDetails = imageDetailsList[i];
        int key = await _uploadEntryLocalRepository.upsertEntity(imageDetails);
        imageDetails.uploadEntityHOKey = key;
        tempImageDetailsList[i] = imageDetails;
      }
      changeImageDetailsList(tempImageDetailsList);
    }
    changeUIStatus(UIStatus(isOnScreenLoading: false, event: Event.success));
  }

  void goBackWithImage() {
    ImageDetails? imageDetails = getSelectedImageDetails();
    if (imageDetails != null) {
      imageDetails.rotationAngle = 0;
      changeUIStatus(UIStatus(event: Event.success, data: imageDetails));
    }
  }

  Future<void> deleteImage() async {
    if (!_imageDetailsList.isClosed &&
        _imageDetailsList.hasValue &&
        !_selectedImageIndex.isClosed) {
      List<ImageDetails> imageDetailsList = _imageDetailsList.value;
      ImageDetails imageDetails = imageDetailsList[_selectedImageIndex.value];
      await imageDetails.deleteFile();
      imageDetailsList.removeAt(_selectedImageIndex.value);
      changeImageDetailsList(imageDetailsList);
      changeSelectedImageIndex(_selectedImageIndex.value);
      if (imageDetailsList.isEmpty) {
        changeUIStatus(UIStatus(event: Event.deleted));
      }
    }
  }

  void downloadAndSaveFile(ImageDetails imageDetails) async {
    try {
      if (imageDetails.url == null) {
        return;
      }
      final Uint8List bytes = await InternetFile.get(
        imageDetails.url!,
        progress: (receivedLength, contentLength) {
          final percentage = receivedLength / contentLength * 100;
          print(
              'download progress: $receivedLength of $contentLength ($percentage%)');
        },
      );
      String? targetPath = await FileUtils.getImageFilePath(Get.context!);
      if (targetPath != null) {
        File file = File(targetPath);
        if (!await file.exists()) {
          file.create(recursive: true);
        }
        await file.writeAsBytes(bytes);
        imageDetails.originalFileName = file.name;
        imageDetails.originalFilePath = file.path;
        imageDetails.fileQuality = FileQuality.high;
        updateImageDetailsList(imageDetails);
        compressImage();
      }
    } catch (e, st) {
      AppLog.e('downloadAndSaveFile : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
