class PaymentWithdrawRequest {
  double? requestedAmount;
  String? beneficiaryUserID;
  String? beneficiaryID;
  String? requesterID;
  String? requestedAT;
  String? remark;
  String? paymentDisbursalService;

  PaymentWithdrawRequest(
      {this.requestedAmount,
      this.beneficiaryUserID,
      this.beneficiaryID,
      this.requesterID,
      this.requestedAT,
      this.remark,
      this.paymentDisbursalService});

  PaymentWithdrawRequest.fromJson(Map<String, dynamic> json) {
    requestedAmount = json['requested_amount'];
    beneficiaryUserID = json['beneficiary_user_id'];
    beneficiaryID = json['beneficiary_id'];
    requesterID = json['requester_id'];
    requestedAT = json['requested_at'];
    remark = json['remark'];
    paymentDisbursalService = json['payment_disbursal_service'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if(requestedAmount != null) {
      data['requested_amount'] = requestedAmount;
    }
    if(beneficiaryUserID != null) {
      data['beneficiary_user_id'] = beneficiaryUserID;
    }
    if(beneficiaryID != null) {
      data['beneficiary_id'] = beneficiaryID;
    }
    if(requesterID != null) {
      data['requester_id'] = requesterID;
    }
    if(requestedAT != null) {
      data['requested_at'] = requestedAT;
    }
    if(remark != null) {
      data['remark'] = remark;
    }
    if(paymentDisbursalService != null) {
      data['payment_disbursal_service'] = paymentDisbursalService;
    }
    return data;
  }
}
