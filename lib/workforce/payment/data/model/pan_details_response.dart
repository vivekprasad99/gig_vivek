import 'pan_details_request.dart';

class PANDetailsResponse {
  static const success = 'success';
  static const error = 'error';
  String? status;
  String? message;
  Data? data;
  int? statusCode;

  PANDetailsResponse({this.status, this.message, this.data, this.statusCode});

  PANDetailsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  PANDetailsData? panDetails;

  Data({this.panDetails});

  Data.fromJson(Map<String, dynamic> json) {
    panDetails = json['pan_details'] != null
        ? PANDetailsData.fromJson(json['pan_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (panDetails != null) {
      data['pan_details'] = panDetails!.toJson();
    }
    return data;
  }
}