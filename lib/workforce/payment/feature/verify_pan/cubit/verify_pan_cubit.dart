import 'dart:io';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../../packages/flutter_image_editor/model/image_details.dart';
import '../../../../auth/data/model/pan_details_entity.dart';
import '../../../../aw_questions/data/model/parent_reference/pan_details_reference.dart';
import '../../../../core/data/model/kyc_details.dart';
import '../../../../core/data/model/ui_status.dart';
import '../../../../core/exception/exception.dart';
import '../../../../core/utils/app_log.dart';
import '../../../../core/utils/validator.dart';
import '../../../../file_storage_remote/data/model/aws_upload_result.dart';
import '../../../../file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';
import '../../../../onboarding/data/model/application_question/application_question_response.dart';
import '../../../data/model/document_entity.dart';
import '../../../data/model/pan_details_request.dart';
import '../../../data/model/pan_details_response.dart';
import '../../../data/repository/documents_verification_remote_repository.dart';
import 'verify_pan_state.dart';

class VerifyPANCubit extends Cubit<VerifyPANState> {
  final DocumentsVerificationRemoteRepository _documentsVerificationRemoteRepository;
  VerifyPANCubit(this._documentsVerificationRemoteRepository) : super(VerifyPANState(buttonState: ButtonStatus(isEnable: false)));

  void updatePANNumber(String? panNumber) {
    if (Validator.checkPANCardNumber(panNumber) == null) {
      emit(state.copyWith(panNumberError: null, panNumber: panNumber, buttonState: ButtonStatus(isEnable: true)));
    } else {
      emit(state.copyWith(panNumberError: Validator.checkPANCardNumber(panNumber), buttonState: ButtonStatus(isEnable: false)));
    }
  }

  void confirmPANNumber() {
    emit(state.copyWith(showConfirmOrCleanPANNumberCTAs: null, buttonState: ButtonStatus(isEnable: true)));
  }

  void clearPANNumber() {
    emit(state.copyWith(showConfirmOrCleanPANNumberCTAs: null, panNumber: null, panURL: null,
        buttonState: ButtonStatus(isEnable: false), uploadFromOptionEntity: null));
  }

  void updateUploadFromOptionEntity(UploadFromOptionEntity? uploadFromOptionEntity) {
    emit(state.copyWith(uploadFromOptionEntity: uploadFromOptionEntity));
  }

  void getPANDetails(UserData? currUser) async {
    try {
      emit(state.copyWith(buttonState: ButtonStatus(isLoading: true, message: 'please_wait'.tr)));
      PANDetailsRequest panDetailsRequest = PANDetailsRequest(panDetails: PANDetailsData(panNumber: state.panNumber ?? ''));
      PANDetailsResponse panDetailsResponse = await _documentsVerificationRemoteRepository
          .getPANDetails(currUser?.id?.toString() ?? '', panDetailsRequest);
      emit(state.copyWith(panDetailsResponse: panDetailsResponse, buttonState: ButtonStatus(isEnable: true),
          uiState: UIStatus(event: Event.success), thirdPartyVerifiedCount: panDetailsResponse.data?.panDetails?.thirdPartyVerifiedCount));
    } on ServerException catch (e) {
      emit(state.copyWith(uiState: UIStatus(event: Event.failed),
          buttonState: ButtonStatus(isEnable: true),
          panDetailsResponse: PANDetailsResponse(status: PANDetailsResponse.error, message: e.message ?? '', statusCode: e.code)));
    } on FailureException catch (e) {
      emit(state.copyWith(uiState: UIStatus(failedWithoutAlertMessage: e.message ?? ''),
          buttonState: ButtonStatus(isEnable: true)));
    } catch (e, st) {
      AppLog.e('getPANDetails : ${e.toString()} \n${st.toString()}');
      emit(state.copyWith(uiState: UIStatus(failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr),
          buttonState: ButtonStatus(isEnable: true)));
    }
  }

  Future upload(int userID, ImageDetails imageDetails, KYCType kycType) async {
    if (imageDetails.getFile() == null) {
      return;
    }
    emit(state.copyWith(isUploading: true, buttonState: ButtonStatus(isEnable: false), panURL: null, uploadPercent: 0, uploadProgress: null));
    RemoteStorageRepository remoteStorageRepository = RemoteStorageRepository();
    remoteStorageRepository.getUploadPercentageStream().listen((progress) {
      int percentValue = progress ?? 0;
      double value = 0.0;
      if(progress != null) {
        value = (progress as int).toDouble() / 100;
      }
      emit(state.copyWith(uploadPercent: percentValue, uploadProgress: value));
    });
    File file = imageDetails.getFile()!;
    String? updatedFileName, s3FolderPath;
    PANDetailsReference panDetailsReference = PANDetailsReference(userID);
    updatedFileName = file.name?.cleanForUrl();
    s3FolderPath = panDetailsReference.getUploadPath(file.name!);
    if (updatedFileName != null) {
      AWSUploadResult? uploadResult = await remoteStorageRepository
          .uploadFile(file, updatedFileName, s3FolderPath);
      if (uploadResult?.url != null) {
        parsePan(uploadResult!.url!);
      }
    }
  }

  void parsePan(String docURL) async {
    try {
      DocumentParseResponse documentParseResponse =
      await _documentsVerificationRemoteRepository.parsePAN(docURL);
      updatePANNumber(documentParseResponse.pan?.number);
      emit(state.copyWith(isUploading: false, buttonState: ButtonStatus(isEnable: false),
          panURL: docURL, showConfirmOrCleanPANNumberCTAs: true));
    } on ServerException catch (e) {
      emit(state.copyWith(isUploading: false, uiState: UIStatus(failedWithoutAlertMessage: e.message!),
          buttonState: ButtonStatus(isEnable: false)));
    } on FailureException catch (e) {
      emit(state.copyWith(isUploading: false, uiState: UIStatus(failedWithoutAlertMessage: e.message!),
          buttonState: ButtonStatus(isEnable: false)));
    } catch (e, st) {
      AppLog.e('parsePan : ${e.toString()} \n${st.toString()}');
      emit(state.copyWith(isUploading: false, uiState: UIStatus(failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr),
          buttonState: ButtonStatus(isEnable: false)));
    }
  }

  void updatePANStatus(UserData? currUser) async {
    try {
      emit(state.copyWith(isStatusUpdating: true));
      PANDetailsRequest panDetailsRequest = PANDetailsRequest(panDetails: PANDetailsData(panNumber: state.panNumber ?? '', panStatus: 'verified'));
      PANDetailsResponse panDetailsResponse = await _documentsVerificationRemoteRepository
          .updatePANStatus(currUser?.id?.toString() ?? '', panDetailsRequest);
      emit(state.copyWith(isStatusUpdating: null, uiState: UIStatus(event: Event.updated,
          data: DocumentDetailsData(panDetails: DocumentDetails(panName: panDetailsResponse.data?.panDetails?.panName,
            panNumber: panDetailsResponse.data?.panDetails?.panNumber, panStatus: PanVerificationStatus.verified)))));
    } on ServerException catch (e) {
      emit(state.copyWith(isStatusUpdating: null, uiState: UIStatus(event: Event.updateError, failedWithoutAlertMessage: e.message ?? '')));
    } on FailureException catch (e) {
      emit(state.copyWith(isStatusUpdating: null, uiState: UIStatus(event: Event.updateError, failedWithoutAlertMessage: e.message ?? '')));
    } catch (e, st) {
      AppLog.e('updatePANStatus : ${e.toString()} \n${st.toString()}');
      emit(state.copyWith(isStatusUpdating: null, uiState: UIStatus(event: Event.updateError, failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr)));
    }
  }
}
