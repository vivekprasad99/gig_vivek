class PaymentsBffAPI {
  String retryWithdrawalAPI(int transferId) {
    return '/transfer/$transferId/update_beneficiary_details';
  }
  String getBeneficiaries() {
    return '/api/v2/beneficiary/search';
  }

  String createBeneficiary() {
    return '/api/v2/beneficiary';
  }

  String deleteBeneficiary(String beneficiaryId) {
    return '/api/v2/beneficiary/$beneficiaryId';
  }

  String markActive(String beneficiaryId) {
    return '/api/v2/beneficiary/mark_active/$beneficiaryId';
  }

  String validateIfsc(String ifscCode) {
    return '/api/v2/beneficiary/ifsc_code/$ifscCode';
  }

  String verifyBeneficiary(String beneficiaryId) {
    return '/api/v2/beneficiary/$beneficiaryId/verify';
  }

  String updateBeneficiaryActiveStatus(String beneficiaryId, String active) {
    return '/api/v2/beneficiary/$beneficiaryId/mark/$active';
  }

  String getEarningStatement() {
    return '/api/v1/workforce_withdrawal_statement/search';
  }
}
