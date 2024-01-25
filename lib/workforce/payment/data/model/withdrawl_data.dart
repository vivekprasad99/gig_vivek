class WithdrawlData {
  String? userId;
  int? beneficiaryId;
  double? amount;
  double? approvedAmount;
  bool? isEarlyWithdrawalIncluded;
  List<Deductions>? deductions;

  WithdrawlData(
      {this.userId,
        this.beneficiaryId,
        this.amount,
        this.approvedAmount,
        this.isEarlyWithdrawalIncluded,
        this.deductions});

  WithdrawlData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    beneficiaryId = json['beneficiary_id'];
    amount = json['amount'];
    approvedAmount = json['approved_amount'];
    isEarlyWithdrawalIncluded = json['is_early_withdrawal_included'];
    if (json['deductions'] != null) {
      deductions = <Deductions>[];
      json['deductions'].forEach((v) {
        deductions!.add(new Deductions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['beneficiary_id'] = this.beneficiaryId;
    data['amount'] = this.amount;
    data['approved_amount'] = this.approvedAmount;
    data['is_early_withdrawal_included'] = this.isEarlyWithdrawalIncluded;
    if (this.deductions != null) {
      data['deductions'] = this.deductions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Deductions {
  String? type;
  double? amount;

  Deductions({this.type, this.amount});

  Deductions.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['amount'] = this.amount;
    return data;
  }
}
