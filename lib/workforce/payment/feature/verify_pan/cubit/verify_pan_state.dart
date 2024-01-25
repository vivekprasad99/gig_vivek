import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:equatable/equatable.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

import '../../../../core/data/model/button_status.dart';
import '../../../../onboarding/data/model/application_question/application_question_response.dart';
import '../../../data/model/pan_details_request.dart';
import '../../../data/model/pan_details_response.dart';

part 'verify_pan_state.g.dart';

@CopyWith()
class VerifyPANState extends Equatable {
  final UIStatus? uiState;
  final String? panNumber;
  final String? panNumberError;
  final ButtonStatus? buttonState;
  final bool? isUploading;
  final int? uploadPercent;
  final double? uploadProgress;
  final String? panURL;
  final bool? showConfirmOrCleanPANNumberCTAs;
  final PANDetailsResponse? panDetailsResponse;
  final bool? isStatusUpdating;
  final UploadFromOptionEntity? uploadFromOptionEntity;
  final int? thirdPartyVerifiedCount;

  const VerifyPANState(
      {this.uiState, this.panNumber, this.panNumberError, this.buttonState,
        this.isUploading, this.uploadPercent, this.uploadProgress, this.panURL, this.showConfirmOrCleanPANNumberCTAs,
        this.panDetailsResponse, this.isStatusUpdating, this.uploadFromOptionEntity, this.thirdPartyVerifiedCount});

  @override
  List<Object?> get props => [
    uiState,
    panNumber,
    panNumberError,
    buttonState,
    isUploading,
    uploadPercent,
    uploadProgress,
    panURL,
    showConfirmOrCleanPANNumberCTAs,
    panDetailsResponse,
    isStatusUpdating,
    uploadFromOptionEntity,
    thirdPartyVerifiedCount,
  ];
}
