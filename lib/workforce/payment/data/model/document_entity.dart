class DocumentRequest {
  DocumentRequestBody? pan;
  DocumentRequestBody? aadhar;
  DocumentRequestBody? drivingLicence;

  DocumentRequest({this.pan, this.aadhar, this.drivingLicence});

  DocumentRequest.fromJson(Map<String, dynamic> json) {
    pan = json['pan'];
    aadhar = json['aadhar'];
    drivingLicence = json['driving_licence'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pan != null) {
      data['pan'] = pan;
    }
    if (aadhar != null) {
      data['aadhar'] = aadhar;
    }
    if (drivingLicence != null) {
      data['driving_licence'] = drivingLicence;
    }
    return data;
  }
}

class DocumentRequestBody {
  String? frontImage;

  DocumentRequestBody({this.frontImage});

  DocumentRequestBody.fromJson(Map<String, dynamic> json) {
    frontImage = json['front_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['front_image'] = frontImage;
    return data;
  }
}

class DocumentParseResponse {
  PanEntity? pan;
  DrivingLicenceEntity? drivingLicence;

  DocumentParseResponse({this.pan, this.drivingLicence});

  DocumentParseResponse.fromJson(Map<String, dynamic> json) {
    pan = json['pan'] != null ? PanEntity.fromJson(json['pan']) : null;
    drivingLicence = json['driving_licence'] != null
        ? DrivingLicenceEntity.fromJson(json['driving_licence'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pan != null) {
      data['pan'] = pan!.toJson();
      data['driving_licence'] = drivingLicence!.toJson();
    }
    return data;
  }
}

class PanEntity {
  String? dob;
  String? fathersName;
  String? name;
  String? number;

  PanEntity({this.dob, this.fathersName, this.name, this.number});

  PanEntity.fromJson(Map<String, dynamic> json) {
    dob = json['dob'];
    fathersName = json['fathers_name'];
    name = json['name'];
    number = json['number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dob'] = dob;
    data['fathers_name'] = fathersName;
    data['name'] = name;
    data['number'] = number;
    return data;
  }
}

class DrivingLicenceEntity {
  String? guardiansName;
  String? name;
  String? number;
  String? validTill;
  String? dob;

  DrivingLicenceEntity(
      {this.guardiansName, this.name, this.number, this.validTill, this.dob});

  DrivingLicenceEntity.fromJson(Map<String, dynamic> json) {
    guardiansName = json['guardians_name'];
    name = json['name'];
    number = json['number'];
    validTill = json['valid_till'];
    dob = json['dob'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['guardians_name'] = guardiansName;
    data['name'] = name;
    data['number'] = number;
    data['valid_till'] = validTill;
    data['dob'] = dob;
    return data;
  }
}
