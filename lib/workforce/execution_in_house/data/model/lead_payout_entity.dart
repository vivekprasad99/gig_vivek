import 'package:awign/workforce/execution_in_house/data/model/execution.dart';

class LeadPayoutResponse {
  LeadPayoutData? leadPayoutData;

  LeadPayoutResponse({this.leadPayoutData});

  LeadPayoutResponse.fromJson(Map<String, dynamic> json) {
    leadPayoutData =
        json['data'] != null ? LeadPayoutData.fromJson(json['data']) : null;
  }
}

class LeadPayoutData {
  List<LeadPayoutEntity>? leadPayouts;

  LeadPayoutData({this.leadPayouts});

  LeadPayoutData.fromJson(Map<String, dynamic> json) {
    if (json['lead_payouts'] != null) {
      leadPayouts = <LeadPayoutEntity>[];
      json['lead_payouts'].forEach((v) {
        leadPayouts!.add(LeadPayoutEntity.fromJson(v));
      });
    }
  }
}

class LeadPayoutEntity {
  double? amount;
  String? comments;
  String? createdAt;
  String? dueDate;
  String? description;
  String? name;
  String? payoutSubType;
  String? status;
  String? redeemedAt;

  LeadPayoutEntity(
      {this.amount,
      this.comments,
      this.createdAt,
      this.dueDate,
      this.description,
      this.name,
      this.payoutSubType,
      this.status,
      this.redeemedAt});

  LeadPayoutEntity.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    comments = json['comments'];
    createdAt = json['created_at'];
    dueDate = json['due_date'];
    description = json['description'];
    name = json['lead_identifier'];
    payoutSubType = json['payout_sub_type'];
    status = json['status'];
    redeemedAt = json['redeemed_at'];
  }
}

class EarningBreakupParams {
  num? amount;
  Execution? execution;
  String? executionID;

  EarningBreakupParams({this.amount, this.execution, this.executionID});
}
