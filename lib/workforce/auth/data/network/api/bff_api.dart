class BffAPI {
  final String getQuestionAnswersAPI = 'api/v1/user/userID/getQuestionAnswers';
  final String submitAnswerAPI =
      'api/v1/category/categoryUID/screen/screenUID/user/userID/submitAnswer';
  final String getWorkForcePayoutAPI =
      'v1/tracking-engine/user/userID/analyze/v2';
  final String calculateDeductionAPI =
      'v1/tracking-engine/instant_payments/calculate-deductions';
  final String withdrawRequestAPI = 'v1/payments/withdraw/request';
  final String getWithdrawlHistoryAPI = '/transfer/search/userID?page=num&limit=record';

  String getTransferInStatusAPI(int userID, int page, int limit, String status) {
    return '/transfer/search/$userID?page=$page&limit=$limit&status=$status';
  }

  String getExpectedTransferApi() {
    return '/transfer/getExpectedTransferTime';
  }

  String getSingleTransferApi(String userId, String transferId) {
    return 'transfer/v2/user_id/$userId/$transferId';
  }

  String npsRatingApi(String userId) {
    return '/api/v1/core/users/$userId/nps_ratings';
  }

  String getNpsRatingApi(String userId) {
    return '/api/v1/core/users/$userId/user_actions';
  }
}
