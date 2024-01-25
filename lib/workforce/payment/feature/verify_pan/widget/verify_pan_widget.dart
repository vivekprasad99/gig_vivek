import 'dart:io';

import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/image_loader/network_image_loader.dart';
import 'package:awign/workforce/payment/feature/verify_pan/cubit/verify_pan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../packages/flutter_image_editor/model/image_details.dart';
import '../../../../aw_questions/data/model/sub_type.dart';
import '../../../../aw_questions/widget/attachment/helper/file_picker_helper.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_section_names.dart';
import '../../../../core/data/local/shared_preference_utils.dart';
import '../../../../core/data/model/kyc_details.dart';
import '../../../../core/data/model/ui_status.dart';
import '../../../../core/data/model/user_data.dart';
import '../../../../core/data/model/widget_result.dart';
import '../../../../core/data/remote/capture_event/capture_event_helper.dart';
import '../../../../core/data/remote/capture_event/logging_data.dart';
import '../../../../core/router/router.dart';
import '../../../../core/utils/helper.dart';
import '../../../../core/widget/app_bar/default_app_bar.dart';
import '../../../../core/widget/bottom_sheet/select_camera_or_gallery_bottom_sheet/widget/select_camera_or_gallery_bottom_sheet.dart';
import '../../../../core/widget/buttons/raised_rect_button_2.dart';
import '../../../../core/widget/label/app_label.dart';
import '../../../../core/widget/network_sensitive/internet_sensitive.dart';
import '../../../../core/widget/scaffold/app_scaffold.dart';
import '../../../../core/widget/theme/theme_manager.dart';
import '../../../../onboarding/data/model/application_question/application_question_response.dart';
import '../cubit/verify_pan_state.dart';
import 'bottom_sheet/confirm_pan_name_bottom_sheet/confirm_pan_name_bottom_sheet.dart';
import 'bottom_sheet/pan_verification_count_alert_bottom_sheet/pan_verification_count_alert_bottom_sheet.dart';
import 'bottom_sheet/pan_verified_bottom_sheet/pan_verified_bottom_sheet.dart';

class VerifyPANWidget extends StatefulWidget {

  VerifyPANWidget({Key? key}) : super(key: key);

  @override
  State<VerifyPANWidget> createState() => _VerifyPANWidgetState();
}

class _VerifyPANWidgetState extends State<VerifyPANWidget> {
  final TextEditingController _panNumberController = TextEditingController();
  UserData? _currentUser;
  SPUtil? spUtil;

  @override
  void initState() {
    super.initState();
    LoggingData loggingData = LoggingData(
        event: LoggingEvents.userLandingInsidePANPage,
        pageName: LoggingPageNames.panDetails,
        sectionName: '${LoggingSectionNames.profileSection}, ${LoggingSectionNames.withdrawalJourney}');
    CaptureEventHelper.captureEvent(loggingData: loggingData);
    getCurrentUser();
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: 'verify_pan'.tr),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: BlocConsumer<VerifyPANCubit, VerifyPANState>(
          listenWhen: (previous, current) {
            return (previous.uiState != current.uiState || previous.panDetailsResponse != current.panDetailsResponse);
          },
          listener: (context, state) {
            if(state.uiState?.event == Event.success && state.panDetailsResponse != null) {
              showConfirmPANNameBottomSheet(context, state.panDetailsResponse!, onConfirmTap: () {
                context.read<VerifyPANCubit>().updatePANStatus(_currentUser);
              }, onWrongNameTap: () {
                showPANVerificationCountAlertBottomSheet(context, state.panDetailsResponse!);
              });
            } else if(state.uiState?.event == Event.failed && state.panDetailsResponse != null) {
              showConfirmPANNameBottomSheet(context, state.panDetailsResponse!);
            } else if((state.uiState?.failedWithoutAlertMessage.isNullOrEmpty != true)) {
              Helper.showErrorToast(state.uiState!.failedWithoutAlertMessage);
            } else if(state.uiState?.event == Event.updated) {
              showPANVerifiedBottomSheet(context, () {
                MRouter.pop(state.uiState?.data);
              });
            }
          },
          buildWhen: (previous, state) {
            return ((state.uiState?.event == Event.reloadWidget &&
                previous.uiState != state.uiState) || previous.isUploading != state.isUploading);
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_32, Dimens.padding_16, Dimens.padding_16),
              child: Column(
                children: [
                  buildPANDetailsOrUploadingWidget(state),
                  Column(
                    children: [
                      buildNoteWidget(),
                      buildVerifyNowButton(),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildPANDetailsOrUploadingWidget(VerifyPANState state) {
    if(state.isUploading ?? false) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: Dimens.pbWidth_72,
                    height: Dimens.pbHeight_72,
                    child: CircularProgressIndicator(
                      value: state.uploadProgress,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(
                          AppColors.success300),
                      backgroundColor: AppColors.backgroundWhite,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: Dimens.padding_24),
                    child: Text(
                      '${state.uploadPercent ?? 0}%',
                      style: Get.textTheme.headline7SemiBold
                          .copyWith(
                          color: AppColors.backgroundBlack),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimens.padding_16),
            Text(
              'loading_pan_card'.tr,
              style: Get.textTheme.bodyText2
                  ?.copyWith(color: AppColors.backgroundBlack),
            ),
          ],
        ),
      );
    } else {
      return Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(),
              const SizedBox(height: Dimens.padding_32),
              TextFieldLabel(label: 'pan_number'.tr, fontWeight: FontWeight.w500),
              const SizedBox(height: Dimens.padding_12),
              buildPANNumberTextField(),
              buildPANImageWidget(),
            ],
          ),
        ),
      );
    }
  }

  Widget buildHeader() {
    return Text('please_provide_details_of_your_pan'.tr,
        style: Get.textTheme.bodyText2Bold?.copyWith(color: AppColors.backgroundBlack, fontSize: Dimens.font_16));
  }

  Widget buildPANNumberTextField() {
    return BlocBuilder<VerifyPANCubit, VerifyPANState>(
      buildWhen: (prevState, curState) {
        if ((prevState.panNumberError == null && curState.panNumberError != null)
            || (prevState.panNumberError != null && curState.panNumberError == null)
            || (prevState.panNumber != null && curState.panNumber == null)
            || (prevState.showConfirmOrCleanPANNumberCTAs != null && curState.showConfirmOrCleanPANNumberCTAs == null)) {
          return true;
        } else {
          return false;
        }
      },
      builder: (context, state) {
        if(state.panNumber != null && _panNumberController.text.isNullOrEmpty) {
          _panNumberController.text = state.panNumber!;
        } else if(state.panNumber == null && _panNumberController.text.isNotEmpty && _panNumberController.text.length > 3) {
          _panNumberController.text = state.panNumber ?? '';
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: context.textTheme.bodyText1,
                    controller: _panNumberController,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textInputAction: TextInputAction.done,
                    onChanged: context.read<VerifyPANCubit>().updatePANNumber,
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                          Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
                      fillColor: (_panNumberController.text.isEmpty)
                          ? context.theme.textFieldBackgroundColor
                          : AppColors.backgroundWhite,
                      hintText: 'enter_your_pan_or_upload'.tr,
                      counterText: "",
                      hintStyle: const TextStyle(color: AppColors.backgroundGrey600),
                      errorText: state.panNumberError,
                      errorMaxLines: 1,
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(Dimens.radius_8)),
                        borderSide:
                        BorderSide(color: context.theme.textFieldBackgroundColor),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(Dimens.radius_8)),
                        borderSide: BorderSide(color: AppColors.primaryMain),
                      ),
                      suffixIcon: state.showConfirmOrCleanPANNumberCTAs == null ? MyInkWell(
                        onTap: () {
                          _showSelectCameraOrGalleryBottomSheet(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.margin_16,
                              10, Dimens.margin_12, Dimens.margin_8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(width: Dimens.dividerWidth_1, height: 26, color: AppColors.backgroundGrey500),
                              const SizedBox(width: Dimens.padding_8),
                              SvgPicture.asset('assets/images/ic_camera_2.svg'),
                            ],
                          ),
                        ),
                      ) : null,
                    ),
                  ),
                ),
                buildShowConfirmOrClearPANNumberWidgets(context, state),
              ],
            ),
            buildMatchPANWithImageMessage(),
          ],
        );
      },
    );
  }

  Widget buildShowConfirmOrClearPANNumberWidgets(BuildContext context, VerifyPANState state) {
    if(state.showConfirmOrCleanPANNumberCTAs ?? false) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_16, 0, Dimens.padding_4, 0),
            child: MyInkWell(
              onTap: () {
                context.read<VerifyPANCubit>().confirmPANNumber();
              },
              child: SvgPicture.asset(
                  'assets/images/ic_confirm_pan_number.svg'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_4, 0, 0, 0),
            child: MyInkWell(
              onTap: () {
                context.read<VerifyPANCubit>().clearPANNumber();
              },
              child:
              SvgPicture.asset('assets/images/ic_clear_pan_number.svg'),
            ),
          )
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildMatchPANWithImageMessage() {
    return BlocBuilder<VerifyPANCubit, VerifyPANState>(
      buildWhen: (prev, curr) {
        return prev.showConfirmOrCleanPANNumberCTAs != curr.showConfirmOrCleanPANNumberCTAs;
      },
      builder: (context, state) {
        if(state.showConfirmOrCleanPANNumberCTAs ?? false) {
          return Padding(
            padding: const EdgeInsets.only(top: Dimens.padding_12),
            child: Text('please_match_pan_with_the_below_image'.tr,
                style: Get.textTheme.bodyText2?.copyWith(color: AppColors.primaryMain)),
          );
        } else {
          return buildPANHint();
        }
      },
    );
  }

  _showSelectCameraOrGalleryBottomSheet(BuildContext context) {
    showSelectCameraOrGalleryBottomSheet(Get.context!, (onSelectOption) {
      context.read<VerifyPANCubit>().updateUploadFromOptionEntity(onSelectOption);
      if (onSelectOption == UploadFromOptionEntity.camera) {
        LoggingData loggingData = LoggingData(
            action: LoggingActions.panCameraIcon,
            pageName: LoggingPageNames.panDetails,
            sectionName: '${LoggingSectionNames.profileSection}, ${LoggingSectionNames.withdrawalJourney}');
        CaptureEventHelper.captureEvent(loggingData: loggingData);
        _captureImage(context);
      } else if (onSelectOption == UploadFromOptionEntity.gallery) {
        _pickMedia(context);
      }
    });
    LoggingData loggingData = LoggingData(
        action: LoggingActions.verifyPAN,
        pageName: LoggingPageNames.verificationPage);
    CaptureEventHelper.captureEvent(loggingData: loggingData);
  }

  void _captureImage(BuildContext context) async {
    ImageDetails imageDetails = ImageDetails(uploadLater: false);
    WidgetResult? cameraWidgetResult = await MRouter.pushNamed(
        MRouter.inAppCameraWidget,
        arguments: imageDetails);
    if (cameraWidgetResult != null &&
        cameraWidgetResult.event == Event.selected &&
        cameraWidgetResult.data != null) {
      context.read<VerifyPANCubit>().upload(_currentUser?.id ?? -1,
          cameraWidgetResult.data, KYCType.idProofPAN);
    }
  }

  void _pickMedia(BuildContext context) {
    FilePickerHelper.pickMedia(
      SubType.image,
      null,
          (result) async {
        File file = File(result.files.single.path ?? '');
        ImageDetails imageDetailsResult = ImageDetails(
            originalFileName: result.names[0],
            originalFilePath: file.path,
            fileQuality: FileQuality.high);
        context.read<VerifyPANCubit>().upload(_currentUser?.id ?? -1,
            imageDetailsResult, KYCType.idProofPAN);
      },
    );
  }

  Widget buildPANHint() {
    return Padding(
      padding: const EdgeInsets.only(top: Dimens.padding_12),
      child: Text('to_auto_capture_pan_click_on_camera_icon'.tr,
          style: Get.textTheme.bodyText2?.copyWith(color: AppColors.backgroundGrey800)),
    );
  }

  Widget buildPANImageWidget() {
    return BlocBuilder<VerifyPANCubit, VerifyPANState>(
      buildWhen: (preState, curState) {
        return preState.panURL != curState.panURL;
      },
      builder: (context, state) {
        if(state.panURL != null) {
          return Container(
            margin: const EdgeInsets.only(top: Dimens.padding_24),
            padding: const EdgeInsets.all(Dimens.padding_24),
            width: double.infinity,
            height: 211,
            decoration: ShapeDecoration(
              color: AppColors.backgroundWhite,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                    width: Dimens.border_0_5, color: AppColors.backgroundGrey400),
                borderRadius: BorderRadius.circular(Dimens.radius_8),
              ),
            ),
            child: NetworkImageLoader(url: state.panURL ?? '', fit: BoxFit.fitWidth),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildNoteWidget() {
    return Container(
      padding: const EdgeInsets.all(Dimens.padding_12),
      decoration: BoxDecoration(
        color: AppColors.warning100,
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_16)),
        border: Border.all(
          color: AppColors.warning200,
        ),
      ),
      child: Text('to_ensure_the_accuracy_of_your_pan_card_details'.tr,
          style: Get.textTheme.bodyText2?.copyWith(color: AppColors.backgroundGrey800)),
    );
  }

  Widget buildVerifyNowButton() {
    return BlocBuilder<VerifyPANCubit, VerifyPANState>(
      buildWhen: (previousState, state) {
        return (previousState.buttonState != state.buttonState
          || previousState.isStatusUpdating != state.isStatusUpdating);
      },
      builder: (context, state) {
        if(state.isStatusUpdating ?? false) {
          return buildPleaseWaitWidget();
        } else {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16,
                0, Dimens.padding_16),
            child: RaisedRectButton2(
              text: 'verify_now'.tr,
              buttonState: state.buttonState,
              onPressed: () {
                if(state.uploadFromOptionEntity == UploadFromOptionEntity.camera) {
                  LoggingData loggingData = LoggingData(
                      action: LoggingActions.panCameraIconTakeAPhoto,
                      pageName: LoggingPageNames.panDetails,
                      sectionName: '${LoggingSectionNames.profileSection}, ${LoggingSectionNames.withdrawalJourney}');
                  CaptureEventHelper.captureEvent(loggingData: loggingData);
                } else if(state.uploadFromOptionEntity == UploadFromOptionEntity.gallery) {
                  LoggingData loggingData = LoggingData(
                      action: LoggingActions.panCameraIconUploadFromGallery,
                      pageName: LoggingPageNames.panDetails,
                      sectionName: '${LoggingSectionNames.profileSection}, ${LoggingSectionNames.withdrawalJourney}');
                  CaptureEventHelper.captureEvent(loggingData: loggingData);
                }
                context.read<VerifyPANCubit>().getPANDetails(_currentUser);
              },
            ),
          );
        }
      },
    );
  }

  Widget buildPleaseWaitWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16,
          0, Dimens.padding_16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: Dimens.padding_16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                backgroundColor: AppColors.grey,
              ),
            ),
          ),
          Text(
            'please_wait'.tr,
            overflow: TextOverflow.ellipsis,
            style: Get.textTheme.bodyText1SemiBold!.copyWith(
                color: AppColors.primaryMain,
                fontSize: Dimens.font_14),
          ),
        ],
      ),
    );
  }
}
