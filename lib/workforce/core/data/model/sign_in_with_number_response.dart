import 'package:awign/workforce/core/data/model/user_data.dart';

class SignInWithNumberResponse {
  UserData? user;
  Headers? headers;

  SignInWithNumberResponse({this.user, this.headers});

  SignInWithNumberResponse.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? UserData.fromJson(json['user']) : null;
    headers =
        json['headers'] != null ? Headers.fromJson(json['headers']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (headers != null) {
      data['headers'] = headers!.toJson();
    }
    return data;
  }
}

class Headers {
  String? xROUTE;

  Headers({this.xROUTE});

  Headers.fromJson(Map<String, dynamic> json) {
    xROUTE = json['X_ROUTE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['X_ROUTE'] = xROUTE;
    return data;
  }
}
