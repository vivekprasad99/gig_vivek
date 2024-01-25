class BannerResponse {
  String? status;
  List<BannerData>? bannerData;
  String? timestamp;

  BannerResponse({this.status, this.bannerData, this.timestamp});

  BannerResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['response'] != null) {
      bannerData = <BannerData>[];
      json['response'].forEach((v) {
        bannerData!.add(BannerData.fromJson(v));
      });
    }
    timestamp = json['timestamp'];
  }
}

class BannerData {
  String? id;
  Target? target;
  Target? source;
  List<String>? placements;

  BannerData({this.id, this.target, this.source, this.placements});

  BannerData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    target =
        json['target'] != null ? new Target.fromJson(json['target']) : null;
    source =
        json['source'] != null ? new Target.fromJson(json['source']) : null;
    placements = json['placements'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    if (target != null) {
      data['target'] = target!.toJson();
    }
    if (source != null) {
      data['source'] = source!.toJson();
    }
    data['placements'] = placements;
    return data;
  }
}

class Target {
  String? type;
  String? data;

  Target({this.type, this.data});

  Target.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = this.type;
    data['data'] = this.data;
    return data;
  }
}
