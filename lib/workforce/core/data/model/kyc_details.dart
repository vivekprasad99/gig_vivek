import 'package:awign/workforce/auth/data/model/pan_details_entity.dart';
import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/utils/app_log.dart';

class KycDetails {
  String? panCardName;
  String? panCardNumber;
  String? panDOB;
  String? panImage;
  String? panVerificationMessage;
  PanStatus? panVerificationStatus;
  String? aadhardNumber;
  String? aadharFrontImage;
  String? aadharBackImage;
  PanStatus? aadharVerificationStatus;
  String? aadharVerificationMessage;
  String? dldNumber;
  String? dlFrontImage;
  String? dlType;
  List<String>? dlVehicleType;
  String? dlValidity;
  String? dlBackImage;
  PanStatus? dlVerificationStatus;
  String? dlVerificationMessage;
  late int aadhaarVerificationCount;
  late int panVerificationCount;

  KycDetails(
      {this.panCardName,
      this.panCardNumber,
      this.panDOB,
      this.panImage,
      this.panVerificationMessage,
      this.panVerificationStatus,
      this.aadhardNumber,
      this.aadharFrontImage,
      this.aadharBackImage,
      this.aadharVerificationStatus,
      this.aadharVerificationMessage,
      this.dldNumber,
      this.dlFrontImage,
      this.dlType,
      this.dlVehicleType,
      this.dlValidity,
      this.dlBackImage,
      this.dlVerificationStatus,
      this.dlVerificationMessage,
      this.aadhaarVerificationCount = 0,
      this.panVerificationCount = 0});

  KycDetails.fromUserProfileForPANCard(UserProfile userProfile) {
    panCardName = userProfile.panName;
    panCardNumber = userProfile.panNumber;
    panDOB = userProfile.panDob;
    panImage = userProfile.panImage;
    panVerificationMessage =
        userProfile.panVerificationMessage ?? userProfile.panStatusMessage;
    panVerificationStatus = PanStatus.get(
        userProfile.panStatus ?? userProfile.panVerificationStatus);
    panVerificationCount = userProfile.panVerificationCount ?? 0;
  }

  KycDetails.fromUserProfileForAadharCard(UserProfile userProfile) {
    aadhardNumber = userProfile.aadharNumber;
    aadharFrontImage = userProfile.aadharFrontImage;
    aadharBackImage = userProfile.aadharBackImage;
    aadharVerificationStatus = PanStatus.get(
        userProfile.aadharStatus ?? userProfile.aadharVerificationStatus);
    aadhaarVerificationCount = userProfile.aadhaarVerificationCount ?? 0;
  }

  KycDetails.fromUserProfileForDLCard(UserProfile userProfile) {
    dldNumber = userProfile.drivingLicenceNumber;
    dlFrontImage = userProfile.drivingLicenceData?.frontImage;
    dlBackImage = userProfile.drivingLicenceData?.backImage;
    dlValidity = userProfile.drivingLicenceValidity;
    dlVerificationMessage = userProfile.drivingLicenceVerificationMessage;
    dlVerificationStatus = PanStatus.get(userProfile.drivingLicenceStatus);
    dlType = userProfile.drivingLicenceType;
  }

  KycDetails.fromPANDetails(DocumentDetails panDetails) {
    panCardName = panDetails.panName;
    panCardNumber = panDetails.panNumber;
    panDOB = panDetails.panDob;
    panImage = panDetails.panImage;
    panVerificationMessage = panDetails.panStatusMessage;
    panVerificationStatus = PanStatus.get(panDetails.panStatus);
    panVerificationCount = 0;
  }

  KycDetails.fromDLDetails(DocumentDetails dlDetails) {
    dldNumber = dlDetails.drivingLicenceNumber;
    dlFrontImage = dlDetails.drivingLicenceData?.frontImage;
    dlBackImage = dlDetails.drivingLicenceData?.backImage;
    dlValidity = dlDetails.drivingLicenceValidity;
    dlVerificationMessage = dlDetails.drivingLicenceVerificationMessage;
    dlVerificationStatus = PanStatus.get(dlDetails.drivingLicenceStatus);
    dlType = dlDetails.drivingLicenceType;
  }

  KycDetails.fromAadharDetails(DocumentDetails aadharDetails) {
    aadhardNumber = aadharDetails.aadharNumber;
    aadharFrontImage = aadharDetails.aadharFrontImage;
    aadharBackImage = aadharDetails.aadharBackImage;
    aadharVerificationStatus = PanStatus.get(aadharDetails.aadharStatus);
    aadhaarVerificationCount = 0;
  }

  bool isDateIsNotValid() {
    bool isValid = false;
    if (dlValidity != null) {
      try {
        var dlValidityDateTime = DateTime.parse(dlValidity!);
        var nowDateTime = DateTime.now();
        isValid = nowDateTime.millisecondsSinceEpoch >
            dlValidityDateTime.millisecondsSinceEpoch;
      } catch (e, st) {
        AppLog.e('isDateIsNotValid : ${e.toString()} \n${st.toString()}');
        isValid = false;
      }
    }
    return isValid;
  }
}

class PanStatus<String> extends Enum1<String> {
  const PanStatus(String val) : super(val);

  static const PanStatus verified = PanStatus('verified');
  static const PanStatus unverified = PanStatus('unverified');
  static const PanStatus inProgress = PanStatus('in_progress');
  static const PanStatus notSubmitted = PanStatus('not_submitted');

  static PanStatus? get(PanVerificationStatus? status) {
    switch (status) {
      case PanVerificationStatus.notSubmitted:
        return PanStatus.notSubmitted;
      case PanVerificationStatus.submitted:
      case PanVerificationStatus.inProgress:
        return PanStatus.inProgress;
      case PanVerificationStatus.verified:
        return PanStatus.verified;
      case PanVerificationStatus.rejected:
      case PanVerificationStatus.unverified:
        return PanStatus.unverified;
      default:
        return PanStatus.notSubmitted;
    }
  }
}

class KYCType<String> extends Enum1<String> {
  const KYCType(String val) : super(val);

  static const KYCType idProofPAN = KYCType('idProofPAN');
  static const KYCType idProofAadhar = KYCType('idProofAadhar');
  static const KYCType idProofDrivingLicence = KYCType('idProofDrivingLicence');
}
