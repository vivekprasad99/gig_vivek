class UpdateBeneficiaryRequest {
  String? beneficiaryID;

  UpdateBeneficiaryRequest({this.beneficiaryID});

  UpdateBeneficiaryRequest.fromJson(Map<String, dynamic> json) {
    beneficiaryID = json['beneficiary_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if(beneficiaryID != null) {
      data['beneficiary_id'] = beneficiaryID;
    }
    return data;
  }
}
