class WithdrawalResponse {
  Transfer? transfer;

  WithdrawalResponse({this.transfer});

  WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    transfer = json['transfer'] != null
        ?  Transfer.fromJson(json['transfer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (transfer != null) {
      data['transfer'] = transfer!.toJson();
    }
    return data;
  }
}

class Transfer {
  int? id;
  String? status;
  int? userId;
  int? beneficiaryId;
  double? amount;

  Transfer(
      {this.id, this.status, this.userId, this.beneficiaryId, this.amount});

  Transfer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    userId = json['user_id'];
    beneficiaryId = json['beneficiary_id'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['status'] = status;
    data['user_id'] = userId;
    data['beneficiary_id'] = beneficiaryId;
    data['amount'] = amount;
    return data;
  }
}
