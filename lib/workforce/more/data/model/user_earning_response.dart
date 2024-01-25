class UserEarningResponse {
  String? pillar;
  String? performance;
  int? rank;
  int? month;
  int? data;
  int? year;
  String? message;
  Goals? goals;

  UserEarningResponse(
      {this.pillar,
        this.performance,
        this.rank,
        this.month,
        this.data,
        this.year,
        this.message,
        this.goals});

  UserEarningResponse.fromJson(Map<String, dynamic> json) {
    pillar = json['pillar'];
    performance = json['performance'];
    rank = json['rank'];
    month = json['month'];
    data = json['data'];
    year = json['year'];
    message = json['message'];
    goals = json['goals'] != null ? Goals.fromJson(json['goals']) : null;
  }
}

class Goals {
  int? average;
  int? excellent;
  int? good;

  Goals({this.average, this.excellent, this.good});

  Goals.fromJson(Map<String, dynamic> json) {
    average = json['average'];
    excellent = json['excellent'];
    good = json['good'];
  }
}
