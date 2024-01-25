class EarningBreakupResponse {
  EarningBreakupDataEntity? earningBreakupDataEntity;

  EarningBreakupResponse({this.earningBreakupDataEntity});

  EarningBreakupResponse.fromJson(Map<String, dynamic> json) {
    earningBreakupDataEntity =
    json['data'] != null ? EarningBreakupDataEntity.fromJson(json['data']) : null;
  }
}

class EarningBreakupDataEntity {
  List<EarningBreakupEntity>? earningBreakups;
  int? total;
  int? page;

  EarningBreakupDataEntity({this.earningBreakups,this.total,this.page});

  EarningBreakupDataEntity.fromJson(Map<String, dynamic> json) {
    if (json['earnings_breakup'] != null) {
      earningBreakups = <EarningBreakupEntity>[];
      json['earnings_breakup'].forEach((v) {
        earningBreakups!.add(EarningBreakupEntity.fromJson(v));
      });
    }
    total = json['total'];
    page = json['page'];
  }
}

class EarningBreakupEntity {
  double? total;
  String? id;
  String? updatedAt;
  String? name;
  String? status;

  EarningBreakupEntity(
      {this.total,
        this.id,
        this.updatedAt,
        this.name,
        this.status,
        });

  EarningBreakupEntity.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    id = json['_id'];
    updatedAt = json['update_at'];
    name = json['lead_identifier'];
    status = json['status'];
  }
}