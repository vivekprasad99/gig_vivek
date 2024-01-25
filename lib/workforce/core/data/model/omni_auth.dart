class OmniAuthRequest {
  OmniAuthRequest({
    required this.omniauth
  });

  late final GoogleSignInData omniauth;

  OmniAuthRequest.fromJson(Map<String, dynamic> json) {
    omniauth = GoogleSignInData.fromJson(json['omniauth']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['omniauth'] = omniauth.toJson();
    return _data;
  }
}

class GoogleSignInData {
  GoogleSignInData({
    required this.info,
    required this.uid,
    required this.provider,
  });

  late final GoogleSignInInfo info;
  late final String uid;
  late final String provider;

  GoogleSignInData.fromJson(Map<String, dynamic> json) {
    info = GoogleSignInInfo.fromJson(json['info']);
    uid = json['uid'];
    provider = json['provider'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['info'] = info.toJson();
    _data['uid'] = uid;
    _data['provider'] = provider;
    return _data;
  }
}

class GoogleSignInInfo {
  GoogleSignInInfo({
    required this.name,
    required this.email,
    required this.image,
  });

  late final String name;
  late final String email;
  late final String image;

  GoogleSignInInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['email'] = email;
    _data['image'] = image;
    return _data;
  }
}