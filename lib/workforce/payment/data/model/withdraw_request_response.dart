class WithdrawRequestResponse {
  Transfer? transfer;

  WithdrawRequestResponse({this.transfer});

  WithdrawRequestResponse.fromJson(Map<String, dynamic> json) {
    transfer = json['transfer'] != null
        ?  Transfer.fromJson(json['transfer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (transfer != null) {
      data['transfer'] = transfer!.toJson();
    }
    return data;
  }
}

class Transfer {
  int? id;
  int? beneficiaryId;
  String? status;
  int? amount;
  String? referenceId;
  String? utr;

  Transfer(
      {this.id,
        this.beneficiaryId,
        this.status,
        this.amount,
        this.referenceId,
        this.utr});

  Transfer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    beneficiaryId = json['beneficiary_id'];
    status = json['status'];
    amount = json['amount'];
    referenceId = json['reference_id'];
    utr = json['utr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['beneficiary_id'] = beneficiaryId;
    data['status'] = status;
    data['amount'] = amount;
    data['reference_id'] = referenceId;
    data['utr'] = utr;
    return data;
  }
}
