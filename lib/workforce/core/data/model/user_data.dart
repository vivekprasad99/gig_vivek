import 'package:awign/packages/google_maps_place_picker/src/models/pick_result.dart';
import 'package:awign/workforce/auth/data/model/dream_application_completion_stage.dart';
import 'package:awign/workforce/auth/data/model/onboarding_completion_stage.dart';
import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';
import 'package:awign/workforce/core/data/model/profile_attributes.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/model/language.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class UserLoginRequest {
  late UserData userData;

  UserLoginRequest({required this.userData});

  UserLoginRequest.fromJson(Map<String, dynamic> json) {
    userData = json['user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = userData;
    return data;
  }
}

class LoginResponse {
  LoginResponse({
    required this.user,
    this.headers,
  });

  late final UserData user;
  late final Headers? headers;

  LoginResponse.fromJson(Map<String, dynamic> json) {
    user = UserData.fromJson(json['user']);
    headers =
        json['headers'] != null ? Headers.fromJson(json['headers']) : null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['user'] = user.toJson();
    _data['headers'] = headers?.toJson();
    return _data;
  }
}

class UserData {
  UserData({
    this.id,
    this.provider,
    this.uid,
    this.email,
    this.mobileNumber,
    this.roles,
    this.permissions,
    // this.ssOmsId,
    this.ihOmsId,
    this.supplyId,
    this.memberships,
    this.name,
    // this.permalink,
    this.image,
    // this.fcmToken,
    this.mobileNumberVerified = false,
    this.whatsappNumberVerified,
    this.subscribedToWhatsapp = false,
    this.unreadNotificationCount,
    // this.mandatoryAppVersion,
    this.referralCode,
    // this.status,
    this.createdAt,
    this.updatedAt,
    this.password,
    this.userProfile,
    this.verifiedReferralCount,
    this.paidReferralCount,
    this.totalReferralCount,
    // this.referredBy,
    // this.extraData,
    this.primaryDeviceId,
    this.primaryAppVersion,
    this.deviceInfo,
    // this.unsubscribeReason,
    this.smsNotifications,
    this.emailNotifications,
    // this.executiveId,
    // this.otp,
    this.stages,
    // this.loggedInAs,
    this.pinBlockedTill,
  });

  late int? id;
  late String? provider;
  late String? uid;
  late String? email;
  late String? mobileNumber;
  late List<String>? roles;
  late Permissions? permissions;

  // late Null ssOmsId;
  late String? ihOmsId;
  late String? supplyId;
  late List<Memberships>? memberships;
  late String? name;

  // late Null permalink;
  late String? image;

  // late Null fcmToken;
  late bool mobileNumberVerified;
  late bool? whatsappNumberVerified;
  late bool subscribedToWhatsapp;
  late int? unreadNotificationCount;

  // late Null mandatoryAppVersion;
  late String? referralCode;

  // late Null status;
  late String? createdAt;
  late String? updatedAt;
  late String? password;
  UserProfile? userProfile;
  late int? verifiedReferralCount;
  late int? paidReferralCount;
  late int? totalReferralCount;

  // late Null referredBy;
  // late Null extraData;
  late String? primaryDeviceId;
  late String? primaryAppVersion;
  late String? deviceInfo;

  // late Null unsubscribeReason;
  late bool? smsNotifications;
  late bool? emailNotifications;

  // late Null executiveId;
  // late Null otp;
  late Stages? stages;
  late String? pinBlockedTill;
  late bool pinSet;

  // late Null loggedInAs;

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    provider = json['provider'];
    uid = json['uid'];
    email = json['email'];
    mobileNumber = json['mobile_number'];
    roles = json['roles'] != null
        ? List.castFrom<dynamic, String>(json['roles'])
        : null;
    permissions = json['permissions'] != null
        ? Permissions.fromJson(json['permissions'])
        : null;
    // ssOmsId = null;
    ihOmsId = json['ih_oms_id'];
    supplyId = json['supply_id'];
    memberships = json['memberships'] != null
        ? List.from(json['memberships'])
            .map((e) => Memberships.fromJson(e))
            .toList()
        : null;
    name = json['name'];
    // permalink = null;
    image = json['image'];
    // fcmToken = json['fcm_token'];
    mobileNumberVerified = json['mobile_number_verified'] ?? false;
    whatsappNumberVerified = json['whatsapp_number_verified'];
    subscribedToWhatsapp = json['subscribed_to_whatsapp'] ?? false;
    unreadNotificationCount = json['unread_notification_count'];
    // mandatoryAppVersion = null;
    referralCode = json['referral_code'] ?? json['my_referral_code'];
    // status = null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    password = json['password'];
    userProfile = json['userProfile'] != null
        ? UserProfile.fromJson(json['userProfile'])
        : null;
    verifiedReferralCount = json['verified_referral_count'];
    paidReferralCount = json['paid_referral_count'];
    totalReferralCount = json['total_referral_count'];
    // referredBy = json['referred_by'];
    // extraData = json['extra_data'];
    primaryDeviceId = json['primary_device_id'];
    primaryAppVersion = json['primary_app_version'];
    deviceInfo = json['device_info'];
    // unsubscribeReason = json['unsubscribe_reason'];
    smsNotifications = json['sms_notifications'];
    emailNotifications = json['email_notifications'];
    // executiveId = json['executive_id'];
    // otp = json['otp'];
    stages = json['stages'] != null ? Stages.fromJson(json['stages']) : null;
    // loggedInAs = json['logged_in_as'];
    pinBlockedTill = json['pin_blocked_till'];
    pinSet = json['pin_set'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['provider'] = provider;
    _data['uid'] = uid;
    _data['email'] = email;
    _data['mobile_number'] = mobileNumber;
    _data['roles'] = roles;
    _data['permissions'] = permissions?.toJson();
    // _data['ss_oms_id'] = ssOmsId;
    _data['ih_oms_id'] = ihOmsId;
    _data['supply_id'] = supplyId;
    _data['memberships'] = memberships?.map((e) => e.toJson()).toList();
    _data['name'] = name;
    // _data['permalink'] = permalink;
    _data['image'] = image;
    // _data['fcm_token'] = fcmToken;
    _data['mobile_number_verified'] = mobileNumberVerified;
    _data['whatsapp_number_verified'] = whatsappNumberVerified;
    _data['subscribed_to_whatsapp'] = subscribedToWhatsapp;
    _data['unread_notification_count'] = unreadNotificationCount;
    // _data['mandatory_app_version'] = mandatoryAppVersion;
    _data['referral_code'] = referralCode;
    _data['my_referral_code'] = referralCode;
    // _data['status'] = status;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['password'] = password;
    _data['userProfile'] = userProfile?.toJson();
    _data['verified_referral_count'] = verifiedReferralCount;
    _data['paid_referral_count'] = paidReferralCount;
    _data['total_referral_count'] = totalReferralCount;
    // _data['referred_by'] = referredBy;
    // _data['extra_data'] = extraData;
    _data['primary_device_id'] = primaryDeviceId;
    _data['primary_app_version'] = primaryAppVersion;
    _data['device_info'] = deviceInfo;
    // _data['unsubscribe_reason'] = unsubscribeReason;
    _data['sms_notifications'] = smsNotifications;
    _data['email_notifications'] = emailNotifications;
    // _data['executive_id'] = executiveId;
    // _data['otp'] = otp;
    _data['stages'] = stages?.toJson();
    _data['pin_blocked_till'] = pinBlockedTill;
    _data['pin_set'] = pinSet;
    return _data;
  }
}

class Permissions {
  Permissions({
    required this.awign,
  });

  late List<String>? awign;

  Permissions.fromJson(Map<String, dynamic> json) {
    awign = json['awign'] != null
        ? List.castFrom<dynamic, String>(json['awign'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['awign'] = awign;
    return _data;
  }
}

class Memberships {
  Memberships({
    required this.orgId,
    required this.name,
    required this.domain,
    required this.icon,
    required this.ownerName,
  });

  late int? orgId;
  late String? name;
  late String? domain;
  late String? icon;
  late String? ownerName;

  Memberships.fromJson(Map<String, dynamic> json) {
    orgId = json['org_id'];
    name = json['name'];
    domain = json['domain'];
    icon = json['icon'];
    ownerName = json['owner_name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['org_id'] = orgId;
    _data['name'] = name;
    _data['domain'] = domain;
    _data['icon'] = icon;
    _data['owner_name'] = ownerName;
    return _data;
  }
}

class Headers {
  Headers({
    required this.accessToken,
    required this.client,
    required this.uid,
    required this.saasOrgID,
  });

  late String accessToken;
  late String client;
  late String uid;
  late String? saasOrgID;

  Headers.fromJson(Map<String, dynamic> json) {
    accessToken = json['access-token'];
    client = json['client'];
    uid = json['uid'];
    saasOrgID = json['saas_org_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['access-token'] = accessToken;
    _data['client'] = client;
    _data['uid'] = uid;
    _data['saas_org_id'] = saasOrgID;
    return _data;
  }
}

class UserProfileResponse {
  UserProfileResponse({
    required this.userProfile,
  });

  late UserProfile? userProfile;
  late UserData? currentUser;

  UserProfileResponse.fromJson(Map<String, dynamic> json) {
    userProfile = json['workforce_details'] != null
        ? UserProfile.fromJson(json['workforce_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['workforce_details'] = userProfile?.toJson();
    return _data;
  }
}

enum Gender { male, female, other }

extension GetGender on Gender {
  String? name() {
    String name = '';
    switch (this) {
      case Gender.male:
        name = 'male'.tr;
        break;
      case Gender.female:
        name = 'female'.tr;
        break;
      case Gender.other:
        name = 'other'.tr;
        break;
      default:
        name = '';
    }
    return name;
  }
}

class UserProfile {
  int? id;
  int? userId;
  String? name;
  String? email;
  String? mobileNumber;

  // Null image;
  Gender? gender;
  String? dob;

  String? panNumber;
  String? panName;
  String? panDob;
  String? panImage;
  PanVerificationStatus? panVerificationStatus;
  PanVerificationStatus? panStatus;
  int? panVerificationCount;
  String? panVerificationMessage;
  String? panStatusMessage;

  // late Null commuteType;
  // late String? supplyType;

  // late Null projectsCompleted;
  // late Null projectsNotCompleted;
  late bool locationTrackingEnabled;

  // late Null locationTrackingFrequency;
  // late Null profileCompletionPercentage;
  // late Null addressDetailsCompletionPercentage;
  // late Null userDetailsCompletionPercentage;
  // late Null educationDetailsCompletionPercentage;
  String? referralCode;
  // late Null referredBy;
  // late Null totalReferralCount;
  // late Null awignIdCardExpiryDate;
  // late Null awignIdCardStatus;
  String? educationLevel;
  String? profileCompletionStage;

  String? aadharNumber;
  String? aadharFrontImage;
  String? aadharBackImage;
  PanVerificationStatus? aadharVerificationStatus;
  PanVerificationStatus? aadharStatus;
  int? aadhaarVerificationCount;

  // late Null aadharVerificationMessage;
  // late Null aadharStatusMessage;
  late bool itrFiled;

  String? drivingLicenceNumber;
  String? drivingLicenceType;
  // late Null drivingLicenceVehicleTypes;
  String? drivingLicenceValidity;
  String? drivingLicenceVerificationMessage;
  DrivingLicenceData? drivingLicenceData;
  PanVerificationStatus? drivingLicenceStatus;

  // late Null drivingLicenceStatusMessage;
  late bool subscribedToWhatsapp;

  // late Null siplyUserId;
  String? createdAt;
  String? updatedAt;
  List<Address>? addresses;
  Education? education;
  List<UserRoles>? userRoles;
  List<ProfessionalExperiences>? professionalExperiences;
  List<Languages>? languages;
  // List<dynamic>? profileAttributes;
  List<ProfileAttributes>? profileAttributes;
  List<dynamic>? profileTags;
  int? profileCompletionPercentage;
  int? dreamApplicationCompletionPercentage;
  KycDetails? kycDetails;
  KycDetails? aadharDetails;
  KycDetails? dlDetails;
  OnboardingCompletionStage? onboardingCompletionStage;
  DreamApplicationCompletionStage? dreamApplicationCompletionStage;

  UserProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    email = json['email'];
    mobileNumber = json['mobile_number'];
    // image = null;
    switch (json['gender']) {
      case 'male':
        gender = Gender.male;
        break;
      case 'female':
        gender = Gender.female;
        break;
      case 'other':
        gender = Gender.other;
        break;
      default:
        gender = null;
    }
    dob = json['dob'];
    panNumber = json['pan_number'];
    panName = json['pan_name'];
    panDob = json['pan_dob'];
    panImage = json['pan_image'];
    panStatus = PanVerificationStatus.get(json['pan_status']);
    panVerificationCount = json['pan_verification_count'];
    panStatusMessage = json['pan_status_message'];
    panVerificationStatus =
        PanVerificationStatus.get(json['pan_verification_status']);
    // panVerificationMessage = null;
    // panStatusMessage = null;
    // commuteType = null;
    // supplyType = json['supply_type'];
    // projectsCompleted = null;
    // projectsNotCompleted = null;
    locationTrackingEnabled = json['location_tracking_enabled'];
    // locationTrackingFrequency = null;
    // profileCompletionPercentage = null;
    // addressDetailsCompletionPercentage = null;
    // userDetailsCompletionPercentage = null;
    // educationDetailsCompletionPercentage = null;
    referralCode = json['referral_code'];
    // referredBy = null;
    // totalReferralCount = null;
    // awignIdCardExpiryDate = null;
    // awignIdCardStatus = null;
    educationLevel = json['education_level'];
    profileCompletionStage = json['profile_completion_stage'];
    aadharNumber = json['aadhar_number'];
    aadharFrontImage = json['aadhar_front_image'];
    aadharBackImage = json['aadhar_back_image'];
    aadharVerificationStatus =
        PanVerificationStatus.get(json['aadhar_verification_status']);
    aadharStatus = PanVerificationStatus.get(json['aadhar_status']);
    aadhaarVerificationCount = json['aadhaar_verification_count'];
    // aadharVerificationMessage = null;
    // aadharStatusMessage = null;
    itrFiled = json['itr_filed'];
    drivingLicenceNumber = json['driving_licence_number'];
    drivingLicenceType = json['driving_licence_type'];
    // drivingLicenceVehicleTypes = null;
    drivingLicenceValidity = json['driving_licence_validity'];
    drivingLicenceVerificationMessage =
        json['driving_licence_verification_message'];
    drivingLicenceData = json['driving_licence_data'] != null
        ? DrivingLicenceData.fromJson(json['driving_licence_data'])
        : null;
    drivingLicenceStatus =
        PanVerificationStatus.get(json['driving_licence_status']);
    // drivingLicenceStatusMessage = null;
    subscribedToWhatsapp = json['subscribed_to_whatsapp'] ?? false;
    // siplyUserId = null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    addresses = json['addresses'] != null
        ? List.from(json['addresses']).map((e) => Address.fromJson(e)).toList()
        : null;
    education = json['education'] != null
        ? Education.fromJson(json['education'])
        : null;
    userRoles = json['user_roles'] != null
        ? List.from(json['user_roles'])
            .map((e) => UserRoles.fromJson(e))
            .toList()
        : null;
    professionalExperiences = json['professional_experiences'] != null
        ? List.from(json['professional_experiences'])
            .map((e) => ProfessionalExperiences.fromJson(e))
            .toList()
        : null;
    languages = json['languages'] != null
        ? List.from(json['languages'])
            .map((e) => Languages.fromJson(e))
            .toList()
        : null;
    if (json['profile_attributes'] != null) {
      profileAttributes = <ProfileAttributes>[];
      json['profile_attributes'].forEach((v) {
        profileAttributes!.add(ProfileAttributes.fromJson(v));
      });
    }
    profileTags = json['profile_tags'] != null
        ? List.castFrom<dynamic, dynamic>(json['profile_tags'])
        : null;
    profileCompletionPercentage = json['profile_completion_percentage'];
    dreamApplicationCompletionPercentage =
        json['dream_application_completion_percentage'];
    kycDetails = KycDetails.fromUserProfileForPANCard(this);
    aadharDetails = KycDetails.fromUserProfileForAadharCard(this);
    dlDetails = KycDetails.fromUserProfileForDLCard(this);
    dreamApplicationCompletionStage = DreamApplicationCompletionStage.get(
        json['dream_application_completion_stage']);
    onboardingCompletionStage =
        OnboardingCompletionStage.get(json['onboarding_completion_stage']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['name'] = name;
    _data['email'] = email;
    _data['mobile_number'] = mobileNumber;
    // _data['image'] = image;
    switch (gender) {
      case Gender.male:
        _data['gender'] = 'male';
        break;
      case Gender.female:
        _data['gender'] = 'female';
        break;
      case Gender.other:
        _data['gender'] = 'other';
        break;
      default:
        _data['gender'] = null;
    }
    _data['dob'] = dob;
    _data['pan_number'] = panNumber;
    _data['pan_name'] = panName;
    _data['pan_dob'] = panDob;
    _data['pan_image'] = panImage;
    _data['pan_status'] = panStatus?.value;
    _data['pan_verification_count'] = panVerificationCount;
    _data['pan_status_message'] = panStatusMessage;
    _data['pan_verification_status'] = panVerificationStatus?.value;
    // _data['pan_verification_message'] = panVerificationMessage;
    // _data['commute_type'] = commuteType;
    // _data['supply_type'] = supplyType;
    // _data['projects_completed'] = projectsCompleted;
    // _data['projects_not_completed'] = projectsNotCompleted;
    _data['location_tracking_enabled'] = locationTrackingEnabled;
    // _data['location_tracking_frequency'] = locationTrackingFrequency;
    // _data['profile_completion_percentage'] = profileCompletionPercentage;
    // _data['address_details_completion_percentage'] =
    // addressDetailsCompletionPercentage;
    // _data['user_details_completion_percentage'] =
    // userDetailsCompletionPercentage;
    // _data['education_details_completion_percentage'] =
    //     educationDetailsCompletionPercentage;
    _data['referral_code'] = referralCode;
    // _data['referred_by'] = referredBy;
    // _data['total_referral_count'] = totalReferralCount;
    // _data['awign_id_card_expiry_date'] = awignIdCardExpiryDate;
    // _data['awign_id_card_status'] = awignIdCardStatus;
    _data['education_level'] = educationLevel;
    _data['profile_completion_stage'] = profileCompletionStage;
    _data['aadhar_number'] = aadharNumber;
    _data['aadhar_front_image'] = aadharFrontImage;
    _data['aadhar_back_image'] = aadharBackImage;
    _data['aadhar_verification_status'] = aadharVerificationStatus?.value;
    _data['aadhar_status'] = aadharStatus?.value;
    _data['aadhaar_verification_count'] = aadhaarVerificationCount;
    // _data['aadhar_verification_message'] = aadharVerificationMessage;
    // _data['aadhar_status_message'] = aadharStatusMessage;
    _data['itr_filed'] = itrFiled;
    _data['driving_licence_number'] = drivingLicenceNumber;
    _data['driving_licence_type'] = drivingLicenceType;
    // _data['driving_licence_vehicle_types'] = drivingLicenceVehicleTypes;
    _data['driving_licence_validity'] = drivingLicenceValidity;
    _data['driving_licence_verification_message'] =
        drivingLicenceVerificationMessage;
    _data['driving_licence_data'] = drivingLicenceData?.toJson();
    _data['driving_licence_status'] = drivingLicenceStatus?.value;
    // _data['driving_licence_status_message'] = drivingLicenceStatusMessage;
    _data['subscribed_to_whatsapp'] = subscribedToWhatsapp;
    // _data['siply_user_id'] = siplyUserId;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['addresses'] = addresses?.map((e) => e.toJson()).toList();
    _data['education'] = education?.toJson();
    _data['user_roles'] = userRoles?.map((e) => e.toJson()).toList();
    _data['professional_experiences'] =
        professionalExperiences?.map((e) => e.toJson()).toList();
    _data['languages'] = languages?.map((e) => e.toJson()).toList();
    if (profileAttributes != null) {
      _data['profile_attributes'] =
          profileAttributes!.map((v) => v.toJson()).toList();
    }
    _data['profile_tags'] = profileTags;
    _data['profile_completion_percentage'] = profileCompletionPercentage;
    _data['dream_application_completion_percentage'] =
        dreamApplicationCompletionPercentage;
    _data['dream_application_completion_stage'] =
        dreamApplicationCompletionStage?.value;
    _data['onboarding_completion_stage'] = onboardingCompletionStage?.value;
    return _data;
  }
}

class Address {
  Address({
    required this.id,
    required this.userId,
    required this.state,
    required this.city,
    required this.area,
    required this.pincode,
    this.addressType,
    required this.latitude,
    required this.longitude,
    this.coordinates,
    required this.createdAt,
    required this.updatedAt,
    required this.primary,
    required this.entityId,
    required this.entityType,
  });

  late int? id;
  late int? userId;
  late String? state;
  late String? city;
  late String? area;
  late String? pincode;
  late String? addressType;
  late double? latitude;
  late double? longitude;
  late String? coordinates;
  late String? createdAt;
  late String? updatedAt;
  late bool primary;
  late int? entityId;
  late String? entityType;

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    state = json['state'];
    city = json['city'];
    area = json['area'];
    pincode = json['pincode'];
    addressType = json['address_type'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    coordinates = null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    primary = json['primary'] ?? false;
    entityId = json['entity_id'];
    entityType = json['entity_type'];
  }

  Address.fromLocationResult(PickResult? pickResult) {
    id = null;
    userId = null;
    state = pickResult?.state;
    city = pickResult?.city;
    area = pickResult?.formattedAddress;
    pincode = pickResult?.postalCode;
    addressType = null;
    latitude = pickResult?.geometry?.location.lat;
    longitude = pickResult?.geometry?.location.lng;
    coordinates =
        '${pickResult?.geometry?.location.lat},${pickResult?.geometry?.location.lng}';
    createdAt = null;
    updatedAt = null;
    primary = true;
    entityId = null;
    entityType = null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    if(id != null) {
      _data['id'] = id;
    }
    if(userId != null) {
      _data['user_id'] = userId;
    }
    if(state != null) {
      _data['state'] = state;
    }
    if(city != null) {
      _data['city'] = city;
    }
    if(area != null) {
      _data['area'] = area;
    }
    if(pincode != null) {
      _data['pincode'] = pincode;
    }
    if(addressType != null) {
      _data['address_type'] = addressType;
    }
    if(latitude != null) {
      _data['latitude'] = latitude;
    }
    if(longitude != null) {
      _data['longitude'] = longitude;
    }
    if(coordinates != null) {
      _data['coordinates'] = coordinates;
    }
    if(createdAt != null) {
      _data['created_at'] = createdAt;
    }
    if(updatedAt != null) {
      _data['updated_at'] = updatedAt;
    }
    if(primary != null) {
      _data['primary'] = primary;
    }
    if(entityId != null) {
      _data['entity_id'] = entityId;
    }
    if(entityType != null) {
      _data['entity_type'] = entityType;
    }
    return _data;
  }
}

class AddressType<String> extends Enum1<String> {
  const AddressType(String val) : super(val);

  static const AddressType home = AddressType('home');
  static const AddressType work = AddressType('work');
}

class Education {
  Education({
    this.id,
    this.organisationId,
    this.orgType,
    this.status,
    this.doe,
    this.address,
    this.userId,
    required this.collegeName,
    required this.fromYear,
    required this.toYear,
    this.stream,
    required this.fieldOfStudy,
    this.createdAt,
    this.updatedAt,
  });

  late int? id;
  late int? organisationId;
  late String? orgType;
  late String? status;
  late String? doe;
  late Address? address;
  late int? userId;
  late String? collegeName;
  late String? fromYear;
  late String? toYear;
  late String? stream;
  late String? fieldOfStudy;
  late String? createdAt;
  late String? updatedAt;

  Education.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    organisationId = json['organisation_id'];
    orgType = json['org_type'];
    status = json['status'];
    doe = json['doe'];
    address = json['address'];
    userId = json['user_id'];
    collegeName = json['college_name'];
    fromYear = json['from_year'];
    toYear = json['to_year'];
    stream = json['stream'];
    fieldOfStudy = json['field_of_study'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['organisation_id'] = organisationId;
    _data['org_type'] = orgType;
    _data['status'] = status;
    _data['doe'] = doe;
    _data['address'] = address;
    _data['user_id'] = userId;
    _data['college_name'] = collegeName;
    _data['from_year'] = fromYear;
    _data['to_year'] = toYear;
    _data['stream'] = stream;
    _data['field_of_study'] = fieldOfStudy;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    return _data;
  }
}

class UserRoles {
  UserRoles({
    required this.id,
    required this.userId,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  late int? id;
  late int? userId;
  late String? role;
  late String? createdAt;
  late String? updatedAt;

  UserRoles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    role = json['role'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['role'] = role;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    return _data;
  }
}

class ProfessionalExperiences {
  ProfessionalExperiences({
    this.id,
    this.userId,
    this.skill,
    // this.experience,
    this.createdAt,
    this.updatedAt,
  });

  late int? id;
  late int? userId;
  late String? skill;

  // late Null experience;
  late String? createdAt;
  late String? updatedAt;

  ProfessionalExperiences.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    skill = json['skill'];
    // experience = null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['skill'] = skill;
    // _data['experience'] = experience;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    return _data;
  }
}

class ValidateTokenResponse {
  ValidateTokenResponse({
    required this.user,
    required this.oldUser,
    required this.headers,
  });

  late UserData? user;
  late UserData? oldUser;
  late Headers? headers;

  ValidateTokenResponse.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? UserData.fromJson(json['user']) : null;
    oldUser =
        json['old_user'] != null ? UserData.fromJson(json['old_user']) : null;
    headers =
        json['headers'] != null ? Headers.fromJson(json['headers']) : null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['user'] = user?.toJson();
    _data['old_user'] = oldUser?.toJson();
    _data['headers'] = headers?.toJson();
    return _data;
  }
}

class Stages {
  Stages({
    required this.mobileNumber,
    required this.studentType,
    required this.collegeDetails,
    required this.addressDetails,
    required this.gender,
    required this.dob,
  });

  late bool? mobileNumber;
  late bool? studentType;
  late bool? collegeDetails;
  late bool? addressDetails;
  late bool? gender;
  late bool? dob;

  Stages.fromJson(Map<String, dynamic> json) {
    mobileNumber = json['mobile_number'];
    studentType = json['student_type'];
    collegeDetails = json['college_details'];
    addressDetails = json['address_details'];
    gender = json['gender'];
    dob = json['dob'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['mobile_number'] = mobileNumber;
    _data['student_type'] = studentType;
    _data['college_details'] = collegeDetails;
    _data['address_details'] = addressDetails;
    _data['gender'] = gender;
    _data['dob'] = dob;
    return _data;
  }
}

class DrivingLicenceData {
  DrivingLicenceData({
    required this.frontImage,
    this.backImage,
  });

  late String? frontImage;
  late String? backImage;

  DrivingLicenceData.fromJson(Map<String, dynamic> json) {
    frontImage = json['front_image'];
    backImage = json['back_image'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['front_image'] = frontImage;
    if (backImage != null) {
      _data['back_image'] = backImage;
    }
    return _data;
  }
}

class PanVerificationStatus<String> extends Enum1<String> {
  const PanVerificationStatus(String val) : super(val);

  static const PanVerificationStatus notSubmitted =
      PanVerificationStatus('not_submitted');
  static const PanVerificationStatus verified =
      PanVerificationStatus('verified');
  static const PanVerificationStatus unverified =
      PanVerificationStatus('unverified');
  static const PanVerificationStatus inProgress =
      PanVerificationStatus('in_progress');
  static const PanVerificationStatus rejected =
      PanVerificationStatus('rejected');
  static const PanVerificationStatus submitted =
      PanVerificationStatus('submitted');

  static PanVerificationStatus? get(dynamic status) {
    switch (status) {
      case 'not_submitted':
        return PanVerificationStatus.notSubmitted;
      case 'verified':
        return PanVerificationStatus.verified;
      case 'unverified':
        return PanVerificationStatus.unverified;
      case 'in_progress':
        return PanVerificationStatus.inProgress;
      case 'rejected':
        return PanVerificationStatus.rejected;
      case 'submitted':
        return PanVerificationStatus.submitted;
    }
    return null;
  }
}
