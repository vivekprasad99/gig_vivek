class AppConfigResponse {
  String? key;
  Data? data;

  AppConfigResponse({this.key, this.data});

  AppConfigResponse.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  EndPoints? endPoints;
  PrimaryContact? primaryContact;
  TdsRules? tdsRules;
  TdsDeducationPercentage? tdsDeducationPercentage;
  String? tdsNote;
  String? tenant;
  NewVersionInfo? newVersionInfo;

  Data(
      {this.endPoints,
      this.primaryContact,
      this.tdsRules,
      this.tdsDeducationPercentage,
      this.tdsNote,
      this.tenant,
      this.newVersionInfo});

  Data.fromJson(Map<String, dynamic> json) {
    endPoints = json['end_points'] != null
        ? EndPoints.fromJson(json['end_points'])
        : null;
    primaryContact = json['primary_contact'] != null
        ? PrimaryContact.fromJson(json['primary_contact'])
        : null;
    tdsRules =
        json['tds_rules'] != null ? TdsRules.fromJson(json['tds_rules']) : null;
    tdsDeducationPercentage = json['tds_deducation_percentage'] != null
        ? TdsDeducationPercentage.fromJson(json['tds_deducation_percentage'])
        : null;
    newVersionInfo = json['new_version_info'] != null
        ? NewVersionInfo.fromJson(json['new_version_info'])
        : null;

    tdsNote = json['tds_note'];
    tenant = json['tenant'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (endPoints != null) {
      data['end_points'] = endPoints!.toJson();
    }
    if (primaryContact != null) {
      data['primary_contact'] = primaryContact!.toJson();
    }
    if (tdsRules != null) {
      data['tds_rules'] = tdsRules!.toJson();
    }
    if (tdsDeducationPercentage != null) {
      data['tds_deducation_percentage'] = tdsDeducationPercentage!.toJson();
    }
    if (newVersionInfo != null) {
      data['new_version_info'] = newVersionInfo!.toJson();
    }

    data['tds_note'] = tdsNote;
    data['tenant'] = tenant;
    return data;
  }
}

class EndPoints {
  String? newCas;
  String? ims;
  String? cas;
  String? pms;
  String? core;
  String? pts;
  String? pds;
  String? ssOms;

  EndPoints(
      {this.newCas,
      this.ims,
      this.cas,
      this.pms,
      this.core,
      this.pts,
      this.pds,
      this.ssOms});

  EndPoints.fromJson(Map<String, dynamic> json) {
    newCas = json['new-cas'];
    ims = json['ims'];
    cas = json['cas'];
    pms = json['pms'];
    core = json['core'];
    pts = json['pts'];
    pds = json['pds'];
    ssOms = json['ss-oms'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['new-cas'] = newCas;
    data['ims'] = ims;
    data['cas'] = cas;
    data['pms'] = pms;
    data['core'] = core;
    data['pts'] = pts;
    data['pds'] = pds;
    data['ss-oms'] = ssOms;
    return data;
  }
}

class PrimaryContact {
  String? name;
  String? phone;
  String? whatsappNumber;
  String? email;
  String? designation;
  String? photoUrl;

  PrimaryContact(
      {this.name,
      this.phone,
      this.whatsappNumber,
      this.email,
      this.designation,
      this.photoUrl});

  PrimaryContact.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    whatsappNumber = json['whatsapp_number'];
    email = json['email'];
    designation = json['designation'];
    photoUrl = json['photo_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['phone'] = phone;
    data['whatsapp_number'] = whatsappNumber;
    data['email'] = email;
    data['designation'] = designation;
    data['photo_url'] = photoUrl;
    return data;
  }
}

class TdsRules {
  List<String>? withPan;
  List<String>? withoutPan;

  TdsRules({this.withPan, this.withoutPan});

  TdsRules.fromJson(Map<String, dynamic> json) {
    withPan = json['with_pan'].cast<String>();
    withoutPan = json['without_pan'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['with_pan'] = withPan;
    data['without_pan'] = withoutPan;
    return data;
  }
}

class TdsDeducationPercentage {
  int? panVerified;
  int? panUnverified;

  TdsDeducationPercentage({this.panVerified, this.panUnverified});

  TdsDeducationPercentage.fromJson(Map<String, dynamic> json) {
    panVerified = json['pan_verified'];
    panUnverified = json['pan_unverified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pan_verified'] = panVerified;
    data['pan_unverified'] = panUnverified;
    return data;
  }
}

class NewVersionInfo {
  AndroidVersionInfo? androidVersionInfo;
  IosVersionInfo? iosVersionInfo;

  NewVersionInfo({this.androidVersionInfo, this.iosVersionInfo});

  NewVersionInfo.fromJson(Map<String, dynamic> json) {
    androidVersionInfo = json['android_version_info'] != null
        ? AndroidVersionInfo.fromJson(json['android_version_info'])
        : null;
    iosVersionInfo = json['ios_version_info'] != null
        ? IosVersionInfo.fromJson(json['ios_version_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['android_version_info'] = androidVersionInfo?.toJson();
    data['ios_version_info'] = iosVersionInfo?.toJson();
    return data;
  }
}

class IosVersionInfo {
  RecommendedRelease? recommendedRelease;
  ForcedRelease? forcedRelease;

  IosVersionInfo({this.recommendedRelease, this.forcedRelease});

  IosVersionInfo.fromJson(Map<String, dynamic> json) {
    recommendedRelease = json['recommended_release'] != null
        ? RecommendedRelease.fromJson(json['recommended_release'])
        : null;
    forcedRelease = json['forced_release'] != null
        ? ForcedRelease.fromJson(json['forced_release'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recommended_release'] = recommendedRelease?.toJson();
    data['forced_release'] = forcedRelease?.toJson();
    return data;
  }
}

class AndroidVersionInfo {
  RecommendedRelease? recommendedRelease;
  ForcedRelease? forcedRelease;

  AndroidVersionInfo({this.recommendedRelease, this.forcedRelease});

  AndroidVersionInfo.fromJson(Map<String, dynamic> json) {
    recommendedRelease = json['recommended_release'] != null
        ? RecommendedRelease.fromJson(json['recommended_release'])
        : null;
    forcedRelease = json['forced_release'] != null
        ? ForcedRelease.fromJson(json['forced_release'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recommended_release'] = recommendedRelease?.toJson();
    data['forced_release'] = forcedRelease?.toJson();
    return data;
  }
}

class ForcedRelease {
  String? versionName;
  int? versionNumber;

  ForcedRelease({this.versionName, this.versionNumber});

  ForcedRelease.fromJson(Map<String, dynamic> json) {
    versionName = json['version_name'];
    versionNumber = json['version_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['version_name'] = versionName;
    data['version_number'] = versionNumber;
    return data;
  }
}

class RecommendedRelease {
  String? versionName;
  int? versionNumber;

  RecommendedRelease({this.versionName, this.versionNumber});

  RecommendedRelease.fromJson(Map<String, dynamic> json) {
    versionName = json['version_name'];
    versionNumber = json['version_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['version_name'] = versionName;
    data['version_number'] = versionNumber;
    return data;
  }
}
