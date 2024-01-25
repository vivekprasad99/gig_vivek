class ApiResponse {
  static const success = 'success';
  String? status;
  String? message;
  dynamic data;

  ApiResponse(this.status, this.message, this.data);

  ApiResponse.fromJson(Map<String, dynamic> json) {
    status = json.containsKey('status') ? json['status'] : success;
    message = json['message'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    map['data'] = data;
    return data;
  }
}
