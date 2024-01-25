class AmountDeductionResponse {
  double? requestedAmount;
  double? withdrawalAmount;
  double? financialYearEarning;
  late bool withdrawAble;
  String? message;
  late List<AmountDeduction> transferDeductions;

  AmountDeductionResponse(
      {this.requestedAmount,
      this.withdrawalAmount,
      this.financialYearEarning,
      this.withdrawAble = false,
      this.message,
      required this.transferDeductions});

  AmountDeductionResponse.fromJson(Map<String, dynamic> json) {
    requestedAmount = json['requestedAmount'];
    withdrawalAmount = json['withdrawalAmount'];
    financialYearEarning = json['financialYearEarning'];
    withdrawAble = json['withdrawable'] ?? false;
    message = json['message'];
    transferDeductions = <AmountDeduction>[];
    json['transferDeductions'].forEach((v) {
      transferDeductions.add(AmountDeduction.fromJson(v));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['requestedAmount'] = requestedAmount;
    data['withdrawalAmount'] = withdrawalAmount;
    data['financialYearEarning'] = financialYearEarning;
    data['withdrawable'] = withdrawAble;
    data['message'] = message;
    data['transferDeductions'] = transferDeductions;
    return data;
  }
}

class AmountDeduction {
  late String type;
  late double amount;
  late double percentage;
  late double taxableAmount;
  late List<String> comments;
  late bool failure;

  AmountDeduction(
      {required this.type,
      required this.amount,
      required this.percentage,
      required this.taxableAmount,
      required this.comments,
      required this.failure});

  AmountDeduction.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    amount = json['amount'];
    percentage = json['percentage'];
    taxableAmount = json['taxable_amount'] ?? false;
    comments = List.castFrom<dynamic, String>(json['comments']);
    failure = json['failure'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['amount'] = amount;
    data['percentage'] = percentage;
    data['taxable_amount'] = taxableAmount;
    data['comments'] = comments;
    data['failure'] = failure;
    return data;
  }
}
