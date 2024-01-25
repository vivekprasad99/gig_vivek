class EarningResponse {
  String? pillar;
  int? month;
  int? year;
  List<UserEarningData>? userData;

  EarningResponse({this.pillar, this.month, this.year, this.userData});

  EarningResponse.fromJson(Map<String, dynamic> json) {
    pillar = json['pillar'];
    month = json['month'];
    year = json['year'];
    if (json['user_data'] != null) {
      userData = <UserEarningData>[];
      json['user_data'].forEach((v) {
        userData!.add(UserEarningData.fromJson(v));
      });
    }
  }
}

class UserEarningData {
  int? data;
  String? name;
  int? rank;

  UserEarningData({this.data, this.name, this.rank});

  UserEarningData.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    name = json['name'];
    rank = json['rank'];
  }
}
