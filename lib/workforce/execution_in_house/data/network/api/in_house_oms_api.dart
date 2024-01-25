class InHouseOMSAPI {
  final String executionsAPI =
      'office/api/v1/members/memberID/executions/workforce/search';
  final String signaturesAPI =
      '/office/api/v1/members/memberID/signatures/search';
  final String createSignatureAPI =
      '/office/api/v1/members/memberID/signatures';
  final String acceptOfferLetterAPI =
      '/office/api/v1/workforce/projects/projectID/executions/executionID/signatures/signatureID/accept_offer_letter';
  final String getTabsAPI =
      '/office/api/v1/workforce/executions/executionID/project_roles/projectRole/tabs/analyze';
  final String getProjectAPI = "office/api/v1/projects/projectID";
  final String getLeadPayoutAmountAPI =
      "/office/api/v1/workforce/executions/executionID/lead_payouts/analyze";
  final String certificateStatusUpdateAPI =
      "/office/api/v1/project_owner/projects/projectID/executions/executionID/status_update";
  final String fetchListViewAPI =
      "office/api/v1/workforce/executions/executionID/project_roles/projectRoleUID/list_views/search";
  final String fetchLeadAnalyzeAPI =
      "office/api/v1/executions/executionID/project_roles/projectRoleUID/leads/analyze";
  final String fetchSummaryViewAPI =
      "/office/api/v1/workforce/executions/executionID/project_roles/projectRoleUID/summary_views/search";
  final String fetchLeadBlockAPI =
      "/office/api/v1/workforce/executions/executionID/project_roles/projectRoleUID/list_views/listViewID/summary_views/summaryViewID/blocks/analyze";
  final String searchLeadsAPI =
      "/office/api/v1/workforce/executions/executionID/project_roles/projectRoleUID/list_views/listViewID/blocks/blockID/leads/search";
  final String getScreensAPI =
      "office/api/v1/workforce/executions/executionID/project_roles/projectRoleUID/data_views/search";
  final String getLeadAPI =
      "office/api/v1/workforce/executions/executionID/project_roles/projectRoleUID/leads/leadID";
  final String getNextScreenAPI =
      "office/api/v1/workforce/executions/executionID/leads/leadID/screens/screenID/next";
  final String addLeadAPI =
      "/office/api/v1/workforce/executions/executionID/project_roles/projectRoleUID/list_views/listViewID/leads";
  final String updateLeadAPI =
      "office/api/v1/workforce/executions/executionID/screens/screenID/leads/leadID";
  final String updateLeadStatusAPI =
      "office/api/v1/workforce/executions/executionID/project_roles/projectRoleUID/screens/screenID/leads/leadID/status";
  final String getWorkLogAPI =
      "/projects/api/v1/projects/project_id/project_roles/project_role_uid/worklog_configs/search";
  final String createWorklogAPI =
      "/office/api/v1/workforce/executions/execution_id/project_roles/project_role_id/worklogs";
  final String getUpcomingSlotsAPI =
      "office/api/v1/members/member_id/member_time_slots/upcoming";
  final String updateAvailabilitySlotsAPI =
      "office/api/v1/members/member_id/member_time_slots/slot_id";
  final String createAvailabilitySlotsAPI =
      "office/api/v1/members/member_id/member_time_slots";
  final String getLeadPayoutsAPI = "/office/api/v1/lead_payouts/search";
  final String getEarningsBreakupAPI =
      "/office/api/v1/workforce/executions/execution_id/lead_payouts/earnings_search";
  final String requestWorkAPI =
      "/office/api/v1/executions/executionID/request_work";
  final String callBridgeAPI = "/office/api/v1/executions/executionID/leads/leadID/phone_bridge";
  final String attendancePunchesSearchAPI = '/office/api/v1/workforce/attendance_punches/search';
  final String attendancePunchesUpdateAPI = '/office/api/v1/executions/execution_id/attendance_punches/id';
  final String cloneLeadApi = "/office/api/v1/workforce/executions/execution_id/project_roles/project_role_id/list_views/list_view_id/leads/lead_id/clone";
  final String deleteLeadApi = "office/api/v1/workforce/executions/execution_id/project_roles/project_role_uid/list_views/list_view_id/leads/lead_id";
  final String getExecutionAPI = "office/api/v1/workforce/projects/projectID/executions/executionID";

}
