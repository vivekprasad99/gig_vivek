class CalculateDeductionResponse {
  double? requestedAmount;
  double? withdrawableAmount;
  List<Deductions>? deductions;
  List<ApprovedPayouts>? approvedPayouts;

  CalculateDeductionResponse(
      {this.requestedAmount,
        this.withdrawableAmount,
        this.deductions,
        this.approvedPayouts});

  CalculateDeductionResponse.fromJson(Map<String, dynamic> json) {
    requestedAmount = json['requested_amount'];
    withdrawableAmount = json['withdrawable_amount'];
    if (json['deductions'] != null) {
      deductions = <Deductions>[];
      json['deductions'].forEach((v) {
        deductions!.add(Deductions.fromJson(v));
      });
    }
    if (json['approved_payouts'] != null) {
      approvedPayouts = <ApprovedPayouts>[];
      json['approved_payouts'].forEach((v) {
        approvedPayouts!.add(ApprovedPayouts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['requested_amount'] = requestedAmount;
    data['withdrawable_amount'] = withdrawableAmount;
    if (deductions != null) {
      data['deductions'] = deductions!.map((v) => v.toJson()).toList();
    }
    if (approvedPayouts != null) {
      data['approved_payouts'] =
          approvedPayouts!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['amount'] = amount;
    return data;
  }
}

class ApprovedPayouts {
  String? dueDate;
  double? amount;
  double? discount;

  ApprovedPayouts({this.dueDate, this.amount, this.discount});

  ApprovedPayouts.fromJson(Map<String, dynamic> json) {
    dueDate = json['due_date'];
    amount = json['amount'];
    discount = json['discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['due_date'] = dueDate;
    data['amount'] = amount;
    data['discount'] = discount;
    return data;
  }
}
