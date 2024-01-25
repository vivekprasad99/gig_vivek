import 'dart:developer';
import 'dart:io';

import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/trackable_data.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/helper/trackable_data_helper.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_actions.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_events.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_page_names.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuple/tuple.dart';

import '../../../../aw_questions/data/model/data_type.dart';
import '../../../../core/data/model/widget_result.dart';

class AttendanceCaptureImageWidget extends StatefulWidget {
  ImageDetails imageDetails;
  bool isResolutionDropDownVisible;
  bool isImageButtonVisible;
  bool isVideoButtonVisible;
  late final bool locationTrackable;
  late final bool timeTrackable;
  late final String? metaDataType;

  AttendanceCaptureImageWidget(this.imageDetails,
      {this.isResolutionDropDownVisible = false,
        this.isImageButtonVisible = false,
        this.isVideoButtonVisible = false,
        Key? key})
      : super(key: key) {
    Question? question = imageDetails.question;
    locationTrackable = question?.configuration?.isLocationTrackable ?? false;
    timeTrackable = question?.configuration?.isTimeTrackable ?? false;
    metaDataType = question?.configuration?.imageMetaData;
  }

  @override
  _AttendanceCaptureImageWidgetState createState() => _AttendanceCaptureImageWidgetState();
}

class _AttendanceCaptureImageWidgetState extends State<AttendanceCaptureImageWidget>
    with WidgetsBindingObserver {
  CameraController? controller;

  // VideoPlayerController? videoController;

  File? _imageFile;
  File? _videoFile;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  final resolutionPresets = ResolutionPreset.values;
  List<CameraDescription> cameras = [];

  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;
  bool isCapturing = false;

  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Fetch the available cameras before initializing the app.
      try {
        WidgetsFlutterBinding.ensureInitialized();
        cameras = await availableCameras();
      } on CameraException catch (e) {
        print('Error in fetching the cameras: $e');
      }
      // Set and initialize the new camera
      onNewCameraSelected(cameras[widget.imageDetails.isFrontCamera ? 1 : 0]);
      // refreshAlreadyCapturedImages();
    } else {
      log('Camera Permission: DENIED');
    }
  }

  refreshAlreadyCapturedImages() async {
    Tuple2<String, Directory>? subFolderPath = await FileUtils.getSubFolderPath(
        Get.context!, widget.imageDetails.subFolderName);
    if (subFolderPath != null) {
      List<FileSystemEntity> fileList =
      await subFolderPath.item2.list().toList();
      allFileList.clear();
      List<Map<int, dynamic>> fileNames = [];

      fileList.forEach((file) {
        if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
          allFileList.add(File(file.path));

          String name = file.path.split('/').last.split('.').first;
          fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
        }
      });

      if (fileNames.isNotEmpty) {
        final recentFile =
        fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
        String recentFileName = recentFile[1];
        if (recentFileName.contains('.mp4')) {
          _videoFile = File('${subFolderPath.item1}/$recentFileName');
          _imageFile = null;
          _startVideoPlayer();
        } else {
          _imageFile = File('${subFolderPath.item1}/$recentFileName');
          _videoFile = null;
        }
      } else {
        _videoFile = null;
        _imageFile = null;
      }
      setState(() {
        isCapturing = false;
      });
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    if (widget.locationTrackable || widget.metaDataType != null) {
      Position currentLocation = await _determinePosition();
      TrackableData? trackableData;
      if (widget.metaDataType != null) {
        trackableData =
            TrackableDataHelper.getTrackableMetaData(currentLocation);
      } else {
        trackableData = TrackableDataHelper.getTrackableData(
            currentLocation, widget.locationTrackable, widget.timeTrackable);
      }

      if (widget.metaDataType != null) {
        List<Placemark> address = await placemarkFromCoordinates(
            currentLocation.latitude, currentLocation.longitude);
        trackableData.address = address[0].name;
        trackableData.area = address[0].subLocality;
        trackableData.city = address[0].locality;
        trackableData.pinCode = address[0].postalCode;
        trackableData.countryName = address[0].country;
      }
      widget.imageDetails.trackableData = trackableData;
    }

    try {
      XFile file = await cameraController.takePicture();
      await controller?.setFlashMode(
        FlashMode.off,
      );
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _startVideoPlayer() async {
    // if (_videoFile != null) {
    //   videoController = VideoPlayerController.file(_videoFile!);
    //   await videoController!.initialize().then((_) {
    //     // Ensure the first frame is shown after the video is initialized,
    //     // even before the play button has been pressed.
    //     setState(() {});
    //   });
    //   await videoController!.setLooping(true);
    //   await videoController!.play();
    // }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  @override
  void initState() {
    // Hide the status bar in Android
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    getPermissionStatus();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    // videoController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('take_selfie_for_attendance'.tr,style: Get.textTheme.bodyText1?.copyWith(color: AppColors.backgroundWhite)),
        ),
        backgroundColor: Colors.black,
        body: _isCameraPermissionGranted
            ? _isCameraInitialized
            ? Column(
          children: [
            AspectRatio(
              aspectRatio: 1 / controller!.value.aspectRatio,
              child: Stack(
                children: [
                  CameraPreview(
                    controller!,
                    child: LayoutBuilder(builder:
                        (BuildContext context,
                        BoxConstraints constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) =>
                            onViewFinderTap(details, constraints),
                      );
                    }),
                  ),
                  // TODO: Uncomment to preview the overlay
                  // Center(
                  //   child: Image.asset(
                  //     'assets/camera_aim.png',
                  //     color: Colors.greenAccent,
                  //     width: 150,
                  //     height: 150,
                  //   ),
                  // ),
                  buildCaptureLoadingWidget(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16.0,
                      8.0,
                      16.0,
                      8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Resolution Drop Down
                        buildResolutionDropDown(),
                        // Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 8.0, top: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${_currentExposureOffset.toStringAsFixed(1)}x',
                                style: const TextStyle(
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              height: 30,
                              child: Slider(
                                value: _currentExposureOffset,
                                min: _minAvailableExposureOffset,
                                max: _maxAvailableExposureOffset,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    _currentExposureOffset = value;
                                  });
                                  await controller!
                                      .setExposureOffset(value);
                                },
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _currentZoomLevel,
                                min: _minAvailableZoom,
                                max: _maxAvailableZoom,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    _currentZoomLevel = value;
                                  });
                                  await controller!
                                      .setZoomLevel(value);
                                },
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(right: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${_currentZoomLevel.toStringAsFixed(1)}x',
                                    style: const TextStyle(
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: Dimens.padding_20),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              if (!widget
                                  .imageDetails.isFrontCamera) ...[
                                buildFrontOrRearCameraButton(),
                              ],
                              buildCaptureOrRecordingButton(),
                              if (!widget
                                  .imageDetails.isFrontCamera) ...[
                                buildRecentThumbnailImageWidget(),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // buildBackIcon(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          buildImageButton(),
                          buildVideoButton(),
                        ],
                      ),
                    ),
                    // Flash Widgets
                    buildFlashWidget(),
                  ],
                ),
              ),
            ),
          ],
        )
            : buildLoadingWidget()
            : buildPermissionDeniedWidget(),
      ),
    );
  }

  Widget buildLoadingWidget() {
    return const Center(
      child: Text(
        'LOADING',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget buildCaptureLoadingWidget() {
    if (isCapturing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCircularProgressIndicator(),
            const SizedBox(height: Dimens.padding_8),
            Text(
              'do_not_move_please_wait'.tr,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyText1?.copyWith(color: AppColors.black),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildPermissionDeniedWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(),
        const Text(
          'Permission denied',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            getPermissionStatus();
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Give permission',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildResolutionDropDown() {
    if (widget.isResolutionDropDownVisible) {
      return Align(
        alignment: Alignment.topRight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: DropdownButton<ResolutionPreset>(
              dropdownColor: Colors.black87,
              underline: Container(),
              value: currentResolutionPreset,
              items: [
                for (ResolutionPreset preset in resolutionPresets)
                  DropdownMenuItem(
                    value: preset,
                    child: Text(
                      preset.toString().split('.')[1].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
              ],
              onChanged: (value) {
                setState(() {
                  currentResolutionPreset = value!;
                  _isCameraInitialized = false;
                });
                onNewCameraSelected(controller!.description);
              },
              hint: const Text("Select item"),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildBackIcon() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MyInkWell(
            onTap: () {
              MRouter.pop(null);
            },
            child:
            const Icon(Icons.arrow_back, color: AppColors.backgroundWhite)),
      ),
    );
  }

  Widget buildFrontOrRearCameraButton() {
    return Expanded(
      child: InkWell(
        onTap: _isRecordingInProgress
            ? () async {
          if (controller!.value.isRecordingPaused) {
            await resumeVideoRecording();
          } else {
            await pauseVideoRecording();
          }
        }
            : () {
          setState(() {
            _isCameraInitialized = false;
          });
          onNewCameraSelected(cameras[_isRearCameraSelected ? 1 : 0]);
          setState(() {
            _isRearCameraSelected = !_isRearCameraSelected;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.circle,
              color: Colors.black38,
              size: 60,
            ),
            _isRecordingInProgress
                ? controller!.value.isRecordingPaused
                ? const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 30,
            )
                : const Icon(
              Icons.pause,
              color: Colors.white,
              size: 30,
            )
                : Icon(
              _isRearCameraSelected
                  ? Icons.camera_front
                  : Icons.camera_rear,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCaptureOrRecordingButton() {
    return Expanded(
      child: InkWell(
        onTap: _isVideoCameraSelected
            ? () async {
          if (_isRecordingInProgress) {
            XFile? rawVideo = await stopVideoRecording();
            File videoFile = File(rawVideo!.path);

            int currentUnix = DateTime.now().millisecondsSinceEpoch;

            Tuple2<String, Directory>? subFolderPath =
            await FileUtils.getSubFolderPath(
                Get.context!, widget.imageDetails.subFolderName);
            if (subFolderPath != null) {
              String fileFormat = videoFile.path.split('.').last;

              _videoFile = await videoFile.copy(
                '${subFolderPath.item1}/$currentUnix.$fileFormat',
              );

              _startVideoPlayer();
            }
          } else {
            await startVideoRecording();
          }
        }
            : () async {
          setState(() {
            isCapturing = true;
          });
          XFile? rawImage = await takePicture();
          if (rawImage != null) {
            File imageFile = File(rawImage.path);
            if (widget.imageDetails.dataType == DataType.array) {
              int currentUnix = DateTime.now().millisecondsSinceEpoch;
              String fileFormat = rawImage.path.split('.').last;
              AppLog.i(
                  'File path: ${rawImage.path}, File format: $fileFormat');
              Tuple2<String, Directory>? subFolderPath =
              await FileUtils.getSubFolderPath(
                  Get.context!, widget.imageDetails.subFolderName);
              if (subFolderPath != null) {
                await imageFile.copy(
                  '${subFolderPath.item1}/$currentUnix.$fileFormat',
                );
                AppLog.i(
                    'File path: ${subFolderPath.item1}, File format: $fileFormat');
                refreshAlreadyCapturedImages();
              }
            } else {
              setState(() {
                isCapturing = false;
              });
              launchImageEditorWidget(rawImage.name, rawImage.path);
            }
          } else {
            setState(() {
              isCapturing = false;
            });
          }
          LoggingData loggingData = LoggingData(
              event: LoggingEvents.clickPictureClicked,
              action: LoggingActions.clicked,pageName: LoggingPageNames.takingSelfie);
          CaptureEventHelper.captureEvent(loggingData: loggingData);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.circle,
              color: _isVideoCameraSelected ? Colors.white : Colors.white38,
              size: 80,
            ),
            Icon(
              Icons.circle,
              color: _isVideoCameraSelected ? Colors.red : Colors.white,
              size: 65,
            ),
            _isVideoCameraSelected && _isRecordingInProgress
                ? const Icon(
              Icons.stop_rounded,
              color: Colors.white,
              size: 32,
            )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildRecentThumbnailImageWidget() {
    if (widget.imageDetails.dataType == DataType.array) {
      if (_imageFile != null || _videoFile != null) {
        return Expanded(
          child: InkWell(
            onTap: _imageFile != null || _videoFile != null
                ? () {
              launchImageEditorWidget(null, null);
            }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    Container(
                      width: Dimens.imageWidth_40,
                      height: Dimens.imageHeight_40,
                      margin: const EdgeInsets.only(top: Dimens.padding_4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(Dimens.radius_8),
                        image: _imageFile != null
                            ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: /*videoController != null && videoController!.value.isInitialized
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: AspectRatio(
                              aspectRatio: videoController!.value.aspectRatio,
                              child: VideoPlayer(videoController!),
                            ),
                          )
                        :*/
                      Container(),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(Dimens.radius_8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: Dimens.badgeIconWidth,
                          minHeight: Dimens.badgeIconWidth,
                        ),
                        child: Text(
                          '${allFileList.length}',
                          style: Get.textTheme.caption2
                              .copyWith(color: AppColors.backgroundWhite),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: Dimens.padding_4),
                SvgPicture.asset(
                  'assets/images/ic_arrow_right.svg',
                  color: AppColors.backgroundWhite,
                ),
              ],
            ),
          ),
        );
      } else {
        return const Expanded(child: SizedBox());
      }
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget buildImageButton() {
    if (widget.isImageButtonVisible) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 4.0,
          ),
          child: TextButton(
            onPressed: _isRecordingInProgress
                ? null
                : () {
              if (_isVideoCameraSelected) {
                setState(() {
                  _isVideoCameraSelected = false;
                });
              }
            },
            style: TextButton.styleFrom(
              primary: _isVideoCameraSelected ? Colors.black54 : Colors.black,
              backgroundColor:
              _isVideoCameraSelected ? Colors.white30 : Colors.white,
            ),
            child: const Text('IMAGE'),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildVideoButton() {
    if (widget.isVideoButtonVisible) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 8.0),
          child: TextButton(
            onPressed: () {
              if (!_isVideoCameraSelected) {
                setState(() {
                  _isVideoCameraSelected = true;
                });
              }
            },
            style: TextButton.styleFrom(
              primary: _isVideoCameraSelected ? Colors.black : Colors.black54,
              backgroundColor:
              _isVideoCameraSelected ? Colors.white : Colors.white30,
            ),
            child: const Text('VIDEO'),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildFlashWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () async {
              setState(() {
                _currentFlashMode = FlashMode.off;
              });
              await controller!.setFlashMode(
                FlashMode.off,
              );
            },
            child: Icon(
              Icons.flash_off,
              color: _currentFlashMode == FlashMode.off
                  ? Colors.amber
                  : Colors.white,
            ),
          ),
          InkWell(
            onTap: () async {
              setState(() {
                _currentFlashMode = FlashMode.auto;
              });
              await controller!.setFlashMode(
                FlashMode.auto,
              );
            },
            child: Icon(
              Icons.flash_auto,
              color: _currentFlashMode == FlashMode.auto
                  ? Colors.amber
                  : Colors.white,
            ),
          ),
          InkWell(
            onTap: () async {
              setState(() {
                _currentFlashMode = FlashMode.always;
              });
              await controller!.setFlashMode(
                FlashMode.always,
              );
            },
            child: Icon(
              Icons.flash_on,
              color: _currentFlashMode == FlashMode.always
                  ? Colors.amber
                  : Colors.white,
            ),
          ),
          InkWell(
            onTap: () async {
              setState(() {
                _currentFlashMode = FlashMode.torch;
              });
              await controller!.setFlashMode(
                FlashMode.torch,
              );
            },
            child: Icon(
              Icons.highlight,
              color: _currentFlashMode == FlashMode.torch
                  ? Colors.amber
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  launchImageEditorWidget(String? fileName, String? filePath) async {
    if (widget.imageDetails.dataType == DataType.array &&
        !allFileList.isNullOrEmpty) {
      List<ImageDetails> imageDetailsList = [];
      for (int i = 0; i < allFileList.length; i++) {
        ImageDetails imageDetails =
        ImageDetails.fromImageDetails(widget.imageDetails);
        imageDetails.originalFileName = allFileList[i].name;
        imageDetails.originalFilePath = allFileList[i].path;
        imageDetailsList.add(imageDetails);
      }
      widget.imageDetails.imageDetailsList = imageDetailsList;
    } else if (fileName != null && filePath != null) {
      widget.imageDetails.originalFileName = fileName;
      widget.imageDetails.originalFilePath = filePath;
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    if (widget.imageDetails.isOpenImageEditor) {
      widget.imageDetails.fromRoute = MRouter.inAppCameraWidget;
      WidgetResult? widgetResult = await MRouter.pushNamed(
          MRouter.imageEditorWidgetNew,
          arguments: widget.imageDetails);
      LoggingData loggingData = LoggingData(
          event: LoggingEvents.uploadSelfieOpened,
          action: LoggingActions.opened,pageName: LoggingPageNames.uploadSelfie);
      CaptureEventHelper.captureEvent(loggingData: loggingData);
      if (widgetResult != null) {
        MRouter.pop(widgetResult);
      } else {
        widget.imageDetails = ImageDetails(isFrontCamera: true);
        refreshAlreadyCapturedImages();
      }
    } else {
      WidgetResult widgetResult =
      WidgetResult(event: Event.selected, data: widget.imageDetails);
      MRouter.pop(widgetResult);
    }
  }
}
