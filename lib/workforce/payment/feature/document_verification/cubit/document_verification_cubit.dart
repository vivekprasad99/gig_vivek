import 'dart:io';

import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/auth/data/model/pan_details_entity.dart';
import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/aw_questions/data/model/parent_reference/pan_details_reference.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:awign/workforce/file_storage_remote/data/repository/upload_remote_storage/remote_storage_repository.dart';
import 'package:awign/workforce/payment/data/model/document_entity.dart';
import 'package:awign/workforce/payment/data/repository/documents_verification_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../../core/di/app_injection_container.dart';
import '../../../../file_storage_remote/data/model/aws_upload_result.dart';

part 'document_verification_state.dart';

class DocumentVerificationCubit extends Cubit<DocumentVerificationState>
    with Validator {
  final DocumentsVerificationRemoteRepository
      _documentsVerificationRemoteRepository;
  final AuthRemoteRepository _authRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final number = BehaviorSubject<String?>();
  Stream<String?> get dlNumberStream => number.stream.transform(validateDlNumber);
  Stream<String?> get aadhaarNumberStream => number.stream.transform(validateNumber);
  Function(String?) get changeNumber => number.sink.add;

  final panNumber = BehaviorSubject<String?>();
  Stream<String?> get panNumberStream =>
      panNumber.stream.transform(validatePANCardNumber);
  Function(String?) get changePanNumber => panNumber.sink.add;

  final name = BehaviorSubject<String?>();
  Stream<String?> get nameStream => name.stream.transform(validName);
  Function(String?) get changeName => name.sink.add;

  final dateOfBirth = BehaviorSubject<String?>();
  Stream<String?> get dateOfBirthStream =>
      dateOfBirth.stream.transform(validateDateOfBirth);
  Function(String?) get changeDateOfBirth => dateOfBirth.sink.add;

  final _docURL = BehaviorSubject<String?>();
  Stream<String?> get docURL => _docURL.stream;
  Function(String?) get changeDocURL => _docURL.sink.add;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());
  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  final validity = BehaviorSubject<String?>();
  Stream<String?> get validityStream =>
      validity.stream.transform(validateValidity);

  Function(String?) get changeValidity => validity.sink.add;
  final _userProfileResponse = BehaviorSubject<UserProfileResponse>();
  Stream<UserProfileResponse> get userProfileResponse =>
      _userProfileResponse.stream;

  int totalFileSize = 0;
  KYCType? kycType;

  DocumentVerificationCubit(
      this._documentsVerificationRemoteRepository, this._authRemoteRepository)
      : super(DocumentVerificationInitial()) {
    number.listen((value) {
      _checkValidation();
    });
    name.listen((value) {
      _checkValidation();
    });
    dateOfBirth.listen((value) {
      _checkValidation();
    });
    validity.listen((value) {
      _checkValidation();
    });
    panNumber.listen((value) {
      _checkValidation();
    });
  }

  _checkValidation() {
    switch (kycType) {
      case KYCType.idProofPAN:
        _checkValidationForPANCard();
        break;
      case KYCType.idProofAadhar:
        _checkValidationForAadharCard();
        break;
      case KYCType.idProofDrivingLicence:
        _checkValidationForDLCard();
        break;
    }
  }

  @override
  Future<void> close() {
    _uiStatus.close();
    number.close();
    name.close();
    dateOfBirth.close();
    _docURL.close();
    buttonStatus.close();
    validity.close();
    _userProfileResponse.close();
    panNumber.close();
    return super.close();
  }

  _checkValidationForPANCard() {
    if (!panNumber.isClosed &&
        panNumber.hasValue &&
        !name.isClosed &&
        name.hasValue &&
        !dateOfBirth.isClosed &&
        dateOfBirth.hasValue) {
      if (Validator.checkPANCardNumber(panNumber.value) == null &&
          Validator.checkName(name.value) == null &&
          Validator.checkDateOfBirthCombined(dateOfBirth.value) == null) {
        changeButtonStatus(ButtonStatus(isEnable: true));
      } else {
        changeButtonStatus(ButtonStatus(isEnable: false));
      }
    } else {
      changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  _checkValidationForAadharCard() {
    if (!number.isClosed &&
        number.hasValue &&
        Validator.checkNumber(number.value) == null) {
      changeButtonStatus(ButtonStatus(isEnable: true));
    } else {
      changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  _checkValidationForDLCard() {
    if (!name.isClosed &&
        name.hasValue &&
        !validity.isClosed &&
        validity.hasValue &&
        !number.isClosed &&
        number.hasValue &&
        !dateOfBirth.isClosed &&
        dateOfBirth.hasValue) {
      if (Validator.checkName(name.value) == null &&
          Validator.checkValidity(validity.value) == null &&
          Validator.checkDLNumber(number.value) == null &&
          Validator.checkDateOfBirthCombined(dateOfBirth.value) == null) {
        changeButtonStatus(ButtonStatus(isEnable: true));
      } else {
        changeButtonStatus(ButtonStatus(isEnable: false));
      }
    } else {
      changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  Future upload(int userID, ImageDetails imageDetails, KYCType kycType) async {
    if (imageDetails.getFile() == null) {
      return;
    }
    changeButtonStatus(ButtonStatus(isEnable: false));
    changeUIStatus(UIStatus(isOnScreenLoading: true));
    File file = imageDetails.getFile()!;
    FileUtils.getFileSizeInBytes(file.path, 2).then((fileSize) {
      totalFileSize = fileSize;
    });
    String? updatedFileName, s3FolderPath;
    PANDetailsReference panDetailsReference = PANDetailsReference(userID);
    updatedFileName = file.name?.cleanForUrl();
    s3FolderPath = panDetailsReference.getUploadPath(file.name!);
    if (updatedFileName != null) {
      AWSUploadResult? uploadResult = await sl<RemoteStorageRepository>()
          .uploadFile(file, updatedFileName, s3FolderPath);
      if (uploadResult?.url != null) {
        parseDocument(uploadResult!.url!);
      }
    }
  }

  void parseDocument(String url) {
    if (!_docURL.isClosed) {
      changeDocURL(url);
    }
    switch (kycType) {
      case KYCType.idProofPAN:
        parsePan(url);
        break;
      case KYCType.idProofAadhar:
        parseAadhar(url);
        break;
      case KYCType.idProofDrivingLicence:
        parseDL(url);
        break;
    }
  }

  void parsePan(String docURL) async {
    try {
      DocumentParseResponse documentParseResponse =
          await _documentsVerificationRemoteRepository.parsePAN(docURL);
      if (documentParseResponse.pan != null) {
        if (!panNumber.isClosed) {
          changePanNumber(documentParseResponse.pan?.number);
        }
        if (!name.isClosed) {
          changeName(documentParseResponse.pan?.name);
        }
        if (!dateOfBirth.isClosed) {
          changeDateOfBirth(documentParseResponse.pan?.dob);
        }
      }
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('parsePan : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void parseAadhar(String docURL) async {
    try {
      DocumentParseResponse documentParseResponse =
          await _documentsVerificationRemoteRepository
              .parseDrivingLicence(docURL);
      if (documentParseResponse.drivingLicence != null) {
        if (!number.isClosed) {
          changeNumber(documentParseResponse.drivingLicence?.number);
        }
      }
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('parseAadhar : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void parseDL(String docURL) async {
    try {
      DocumentParseResponse documentParseResponse =
          await _documentsVerificationRemoteRepository
              .parseDrivingLicence(docURL);
      if (documentParseResponse.drivingLicence != null) {
        if (!name.isClosed) {
          changeName(documentParseResponse.drivingLicence?.name);
        }
        if (!validity.isClosed) {
          changeValidity(documentParseResponse.drivingLicence?.validTill);
        }
        if (!number.isClosed) {
          changeNumber(documentParseResponse.drivingLicence?.number);
        }
        if (!dateOfBirth.isClosed) {
          changeDateOfBirth(documentParseResponse.drivingLicence?.dob);
        }
      }
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('parseDL : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void updatePanDetails(
      int userID, int panVerificationCount, bool rejectIfFailed) async {
    try {
      if (panVerificationCount >= 3) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage:
                'please_contact_support_to_get_your_pan_card_verified'.tr));
        return;
      }
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));
      KycDetails kycDetailsRequest = KycDetails(
          panCardName: name.value,
          panCardNumber: panNumber.value,
          panDOB: dateOfBirth.value,
          panImage: _docURL.value);
      Tuple2<KycDetails, DocumentDetailsData> tuple2 =
          await _authRemoteRepository.updatePanDetails(
              userID, kycDetailsRequest, rejectIfFailed);
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? currUser = spUtil?.getUserData();
      currUser?.userProfile?.kycDetails = tuple2.item1;
      spUtil?.putUserData(currUser);
      changeButtonStatus(ButtonStatus(isSuccess: true));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(event: Event.updated, data: tuple2.item2));
    } on ServerException catch (e) {
      getUserProfile(userID);
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
      getUserProfile(userID);
    } catch (e, st) {
      AppLog.e('updatePanDetails : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(
          isLoading: false,
          isEnable: true,
          message: 'we_regret_the_technical_error'.tr));
      getUserProfile(userID);
    }
  }

  void updateAadharDetails(int userID, int aadharVerificationCount) async {
    try {
      if (aadharVerificationCount >= 3) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage:
                'please_contact_support_to_get_your_aadhar_card_verified'.tr));
        return;
      }
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));
      KycDetails kycDetailsRequest = KycDetails(
        aadhardNumber: number.value,
        aadharFrontImage: _docURL.value,
      );
      Tuple2<KycDetails, DocumentDetailsData> tuple2 =
          await _authRemoteRepository.updateAadharDetails(
              userID, kycDetailsRequest);
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? currUser = spUtil?.getUserData();
      currUser?.userProfile?.aadharDetails = tuple2.item1;
      spUtil?.putUserData(currUser);
      changeButtonStatus(ButtonStatus(isSuccess: true));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(event: Event.updated, data: tuple2.item2));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
    } catch (e, st) {
      AppLog.e('updateDLDetails : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(
          isLoading: false,
          isEnable: true,
          message: 'we_regret_the_technical_error'.tr));
    }
  }

  void updateDLDetails(int userID) async {
    try {
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));
      KycDetails kycDetailsRequest = KycDetails(
          dldNumber: number.value,
          dlFrontImage: _docURL.value,
          dlValidity: validity.value);
      Tuple2<KycDetails, DocumentDetailsData> tuple2 =
          await _authRemoteRepository.updateDrivingLicence(
              userID, kycDetailsRequest);
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? currUser = spUtil?.getUserData();
      currUser?.userProfile?.dlDetails = tuple2.item1;
      spUtil?.putUserData(currUser);
      changeButtonStatus(ButtonStatus(isSuccess: true));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(event: Event.updated, data: tuple2.item2));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
    } catch (e, st) {
      AppLog.e('updateDLDetails : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(
          isLoading: false,
          isEnable: true,
          message: 'we_regret_the_technical_error'.tr));
    }
  }

  void getUserProfile(int? userID) async {
    try {
      changeUIStatus(UIStatus(isDialogLoading: true));
      UserProfileResponse userProfileResponse =
          await _authRemoteRepository.getUserProfile(userID);
      if (!_userProfileResponse.isClosed) {
        _userProfileResponse.sink.add(userProfileResponse);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_userProfileResponse.isClosed) {
        _userProfileResponse.sink.addError(e.message ?? '');
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_userProfileResponse.isClosed) {
        _userProfileResponse.sink.addError(e.message ?? '');
      }
    } catch (e, st) {
      AppLog.e('getUserProfile : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_userProfileResponse.isClosed) {
        _userProfileResponse.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }
}
