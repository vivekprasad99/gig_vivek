class WosAPI {
  final String applicationQuestionAPI =
      'api/v1/application_question_libraries/search';
  final String categoryListAPI = '/api/v2/categories/search';
  final String categoryApplicationListAPI =
      '/api/v2/supplies/SupplyID/category_applications/search';
  final String getCategoryAPI = '/api/v2/categories/id';
  final String createCategoryAPI =
      '/api/v2/categories/categoryID/supplies/supplyID/category_applications';
  final String getCategoryApplicationDetailsAPI =
      '/api/v2/categories/categoryID/supplies/supplyID/applications/search';
  final String searchWorkApplications =
      '/api/v1/supplies/UserID/applications/search';
  final String searchLocationsAPI = '/api/v1/locations/search';
  final String executeInAppInterviewEventAPI =
      '/api/v1/supplies/userID/applications/applicationID/in_app_interview/event';
  final String executeApplicationEventAPI =
      '/api/v1/supplies/userID/applications/applicationID/event';
  final String fetchWorkApplicationAPI =
      '/api/v1/supplies/userID/applications/applicationID';
  final String fetchTimelineAPI =
      '/api/v1/supplies/userID/applications/applicationID/process_flow';
  final String fetchInAppInterviewScreensAPI =
      '/api/v1/supplies/userID/applications/applicationID/in_app_interview/next_screens';
  final String submitInAppInterviewAnswerAPI =
      '/api/v1/supplies/userID/applications/applicationID/in_app_interview/answer';
  final String fetchWorkListingAPI = '/api/v1/worklistings/workListingID';
  final String fetchInterviewSlotsAPI =
      '/api/v1/supplies/userID/applications/applicationID/telephonic_interview/slots/search';
  final String scheduleTelephonicInterviewAPI =
      '/api/v1/supplies/userID/applications/applicationID/telephonic_interview/schedule';
  final String fetchInAppTrainingScreensAPI =
      '/api/v1/supplies/userID/applications/applicationID/in_app_training/next_screens';
  final String submitInAppTrainingAnswerAPI =
      '/api/v1/supplies/userID/applications/applicationID/in_app_training/answer';
  final String executeInAppTrainingEventAPI =
      '/api/v1/supplies/userID/applications/applicationID/in_app_training/event';
  final String fetchTrainingBatchAPI =
      '/api/v1/supplies/userID/applications/applicationID/webinar_training_batches/search';
  final String scheduleTrainingBatchAPI =
      '/api/v1/supplies/userID/applications/applicationID/webinar_training/schedule';
  final String executeWebinarTrainingEventAPI =
      '/api/v1/supplies/userID/applications/applicationID/webinar_training/event';
  final String supplyConfirmWebinarTrainingAPI =
      '/api/v1/supplies/userID/applications/applicationID/webinar_training/supply_confirm';
  final String supplyUnConfirmWebinarTrainingAPI =
      '/api/v1/supplies/userID/applications/applicationID/webinar_training/supply_unconfirm';
  final String executePitchDemoEventAPI =
      '/api/v1/supplies/userID/applications/applicationID/pitch_demo/event';
  final String fetchPitchDemoSlotAPI =
      '/api/v1/supplies/userID/applications/applicationID/pitch_demo/slots/search';
  final String schedulePitchDemoAPI =
      '/api/v1/supplies/userID/applications/applicationID/pitch_demo/schedule';
  final String supplyConfirmPitchDemoAPI =
      '/api/v1/supplies/userID/applications/applicationID/pitch_demo/supply_confirm';
  final String supplyUnConfirmPitchDemoAPI =
      '/api/v1/supplies/userID/applications/applicationID/pitch_demo/supply_unconfirm';
  final String fetchPitchDemoScreensAPI =
      '/api/v1/supplies/userID/applications/applicationID/pitch_demo/next_screens';
  final String submitPitchDemoAnswerAPI =
      '/api/v1/supplies/userID/applications/applicationID/pitch_demo/answer';
  final String executePitchTestEventAPI =
      '/api/v1/supplies/userID/applications/applicationID/pitch_test/event';
  final String fetchPitchTestScreensAPI =
      '/api/v1/supplies/userID/applications/applicationID/pitch_test/next_screens';
  final String submitPitchTestAnswerAPI =
      '/api/v1/supplies/userID/applications/applicationID/pitch_test/answer';
  final String fetchResourcesAPI =
      '/api/v1/supplies/userID/applications/applicationID/resources';
  final String createCampusAmbassadorAPI =
      '/api/v1/supplies/id/campus_ambassadors';
  final String getCATaskAPI =
      'api/v1/supplies/user_id/campus_ambassadors/tasks/search';
  final String getCampusAmbassadorAnalyzeAPI = 'api/v1/applications/analyze';
  final String caApplicationSearchAPI = 'api/v1/applications/search';
  final String applicationCreateAPI =
      '/api/v2/categories/categoryID/supplies/supplyID/applications';
  final String fetchEligiblityAPI = '/api/v1/application_answer/search';
  final String getQuestionsAPI = '/api/v1/application_questions/search';
  final String workListingSearchAPI = 'api/v1/worklistings/search';
  final String fetchResourceAPI = '/api/v1/supplies/{user_id}/applications/{id}/resources';

  String fetchLocationsListAPI(String workListingId){
    return '/api/v1/worklistings/$workListingId/search_locations';
  }

  String markAttendanceForWebinarTrainingAPI(int applicationId) {
    return '/api/v1/applications/$applicationId/webinar_training/start';
  }
}
