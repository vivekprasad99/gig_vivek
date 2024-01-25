class WorkforcePayoutResponse {
  late double approved;
  late double requested;
  late double redeemable;
  late double redeemed;
  String? validationStatus;
  String? paymentDisbursalService;
  String? earningsSince;
  bool? instantPaymentEligible;

  WorkforcePayoutResponse(
      {this.approved = 0.0,
      this.requested = 0.0,
      this.redeemable = 0.0,
      this.redeemed = 0.0,
      this.validationStatus,
      this.paymentDisbursalService,
      this.earningsSince,
      this.instantPaymentEligible});

  WorkforcePayoutResponse.fromJson(Map<String, dynamic> json) {
    approved = json['approved'] ?? 0.0;
    requested = json['requested'] ?? 0.0;
    redeemable = json['redeemable'] ?? 0.0;
    redeemed = json['redeemed'] ?? 0.0;
    validationStatus = json['validationStatus'];
    paymentDisbursalService = json['paymentDisbursalService'];
    earningsSince = json['earnings_since'];
    instantPaymentEligible = json['instant_payment_eligible'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['approved'] = approved;
    data['requested'] = requested;
    data['redeemable'] = redeemable;
    data['redeemed'] = redeemed;
    data['validationStatus'] = validationStatus;
    data['paymentDisbursalService'] = paymentDisbursalService;
    data['earnings_since'] = earningsSince;
    data['instant_payment_eligible'] = instantPaymentEligible;
    return data;
  }
}
