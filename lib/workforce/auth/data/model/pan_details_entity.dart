import 'dart:convert';

import 'package:awign/workforce/core/data/model/user_data.dart';

class DocumentDetailsData {
  DocumentDetails? panDetails;
  DocumentDetails? aadharDetails;
  DocumentDetails? drivingLicenceDetails;

  DocumentDetailsData(
      {this.panDetails, this.aadharDetails, this.drivingLicenceDetails});

  DocumentDetailsData.fromJson(Map<String, dynamic> json) {
    panDetails = json['pan_details'] != null
        ? DocumentDetails.fromJson(json['pan_details'])
        : null;
    if (panDetails == null && json.containsKey('pan_status')) {
      panDetails = DocumentDetails.fromJson(json);
    }
    aadharDetails = json['aadhar_details'] != null
        ? DocumentDetails.fromJson(json['aadhar_details'])
        : null;
    if (aadharDetails == null && json.containsKey('aadhar_status')) {
      aadharDetails = DocumentDetails.fromJson(json);
    }
    drivingLicenceDetails = json['driving_licence_details'] != null
        ? DocumentDetails.fromJson(json['driving_licence_details'])
        : null;
    if (drivingLicenceDetails == null &&
        json.containsKey('driving_licence_status')) {
      drivingLicenceDetails = DocumentDetails.fromJson(json);
    }
  }

  Map<String, dynamic> toJson({bool isFromAWQuestion = false}) {
    if (isFromAWQuestion) {
      if (panDetails != null) {
        return panDetails!.toJson();
      } else if (aadharDetails != null) {
        return aadharDetails!.toJson();
      } else if (drivingLicenceDetails != null) {
        return drivingLicenceDetails!.toJson();
      } else {
        return {};
      }
    } else {
      final Map<String, dynamic> data = <String, dynamic>{};
      if (panDetails != null) {
        data['pan_details'] = panDetails!.toJson();
      }
      if (aadharDetails != null) {
        data['aadhar_details'] = aadharDetails!.toJson();
      }
      if (drivingLicenceDetails != null) {
        data['driving_licence_details'] = drivingLicenceDetails!.toJson();
      }
      return data;
    }
  }
}

class DocumentDetails {
  String? name;
  String? dob;
  String? panNumber;
  String? panName;
  String? panDob;
  String? panImage;
  PanVerificationStatus? panStatus;
  String? panStatusMessage;
  int? taxDeductionPercentage;
  String? aadharNumber;
  String? aadharFrontImage;
  String? aadharBackImage;
  PanVerificationStatus? aadharStatus;
  String? aadharStatusMessage;
  String? drivingLicenceNumber;
  String? drivingLicenceValidity;
  DrivingLicenceData? drivingLicenceData;
  List<String>? drivingLicenceVehicleTypes;
  String? drivingLicenceType;
  PanVerificationStatus? drivingLicenceStatus;
  String? drivingLicenceVerificationMessage;
  bool? rejectIfFailed;
  bool? autoVerifyAadhaar;

  DocumentDetails({
    this.name,
    this.dob,
    this.panNumber,
    this.panName,
    this.panDob,
    this.panImage,
    this.panStatus,
    this.panStatusMessage,
    this.taxDeductionPercentage,
    this.aadharNumber,
    this.aadharFrontImage,
    this.aadharBackImage,
    this.aadharStatus,
    this.aadharStatusMessage,
    this.drivingLicenceNumber,
    this.drivingLicenceValidity,
    this.drivingLicenceData,
    this.drivingLicenceVehicleTypes,
    this.drivingLicenceType,
    this.drivingLicenceStatus,
    this.drivingLicenceVerificationMessage,
    this.rejectIfFailed,
    this.autoVerifyAadhaar,
  });

  DocumentDetails.fromJson(Map<String, dynamic> jsonMap) {
    name = jsonMap['name'];
    dob = jsonMap['dob'];
    panNumber = jsonMap['pan_number'];
    panName = jsonMap['pan_name'];
    panDob = jsonMap['pan_dob'];
    panImage = jsonMap['pan_image'];
    panStatus = PanVerificationStatus.get(jsonMap['pan_status']);
    panStatusMessage = jsonMap['pan_status_message'];
    taxDeductionPercentage = jsonMap['tax_deduction_percentage'];
    aadharNumber = jsonMap['aadhar_number'];
    aadharFrontImage = jsonMap['aadhar_front_image'];
    aadharBackImage = jsonMap['aadhar_back_image'];
    aadharStatus = PanVerificationStatus.get(jsonMap['aadhar_status']);
    aadharStatusMessage = jsonMap['aadhar_status_message'];
    drivingLicenceNumber = jsonMap['driving_licence_number'];
    drivingLicenceValidity = jsonMap['driving_licence_validity'];
    if (jsonMap['driving_licence_data'] != null &&
        jsonMap['driving_licence_data'] is String) {
      drivingLicenceData = jsonMap['driving_licence_data'] != null
          ? DrivingLicenceData.fromJson(
              json.decode(jsonMap['driving_licence_data']))
          : null;
    } else {
      drivingLicenceData = jsonMap['driving_licence_data'] != null
          ? DrivingLicenceData.fromJson(jsonMap['driving_licence_data'])
          : null;
    }
    drivingLicenceVehicleTypes =
        jsonMap['driving_licence_vehicle_types'] != null
            ? List.castFrom<dynamic, String>(
                jsonMap['driving_licence_vehicle_types'])
            : null;
    drivingLicenceType = jsonMap['driving_licence_type'];
    drivingLicenceStatus =
        PanVerificationStatus.get(jsonMap['driving_licence_status']);
    drivingLicenceVerificationMessage =
        jsonMap['driving_licence_verification_message'];
    rejectIfFailed = jsonMap['reject_if_failed'];
    autoVerifyAadhaar = jsonMap['autoverify_aadhar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (name != null) {
      data['name'] = name;
    }
    if (dob != null) {
      data['dob'] = dob;
    }
    if (panNumber != null) {
      data['pan_number'] = panNumber;
    }
    if (panName != null) {
      data['pan_name'] = panName;
    }
    if (panDob != null) {
      data['pan_dob'] = panDob;
    }
    if (panImage != null) {
      data['pan_image'] = panImage;
    }
    if (panStatus?.value != null) {
      data['pan_status'] = panStatus?.value;
    }
    if (panStatusMessage != null) {
      data['pan_status_message'] = panStatusMessage;
    }
    if (taxDeductionPercentage != null) {
      data['tax_deduction_percentage'] = taxDeductionPercentage;
    }
    if (aadharNumber != null) {
      data['aadhar_number'] = aadharNumber;
    }
    if (aadharFrontImage != null) {
      data['aadhar_front_image'] = aadharFrontImage;
    }
    if (aadharBackImage != null) {
      data['aadhar_back_image'] = aadharBackImage;
    }
    if (aadharStatus?.value != null) {
      data['aadhar_status'] = aadharStatus?.value;
    }
    if (aadharStatusMessage != null) {
      data['aadhar_status_message'] = aadharStatusMessage;
    }
    if (drivingLicenceNumber != null) {
      data['driving_licence_number'] = drivingLicenceNumber;
    }
    if (drivingLicenceValidity != null) {
      data['driving_licence_validity'] = drivingLicenceValidity;
    }
    if (drivingLicenceData != null) {
      data['driving_licence_data'] = drivingLicenceData;
    }
    if (drivingLicenceVehicleTypes != null) {
      data['driving_licence_vehicle_types'] = drivingLicenceVehicleTypes;
    }
    if (drivingLicenceType != null) {
      data['driving_licence_type'] = drivingLicenceType;
    }
    if (drivingLicenceStatus?.value != null) {
      data['driving_licence_status'] = drivingLicenceStatus?.value;
    }
    if (drivingLicenceVerificationMessage != null) {
      data['driving_licence_verification_message'] =
          drivingLicenceVerificationMessage;
    }
    if (rejectIfFailed != null) {
      data['reject_if_failed'] = rejectIfFailed;
    }
    if (autoVerifyAadhaar != null) {
      data['autoverify_aadhar'] = autoVerifyAadhaar;
    }
    return data;
  }
}
