import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigHelper {
  static RemoteConfigHelper? _instance;
  late FirebaseRemoteConfig _remoteConfig;
  bool isVideoConfigured = true;
  String howAppWorks = '';
  bool isVerifyBeneficiaryConfigured = false;
  bool isEarningStatementConfigured = false;
  bool isEarningSectionDisabled = false;
  String? earningSectionDisabledMessage;
  bool isBeneficiaryUpiModeDisabled = false;
  String? earningStatementNoteMessage;
  bool enableAwignUniversity = false;
  int delayWhatsappBottomSheet = 0;
  bool isOtplessEnabled = false;
  bool isLeaderboardEnabled = false;
  bool showLeadPayoutDate = true;
  int showNewUpdateForLeaderBoard = 0;

  RemoteConfigHelper._() {
    _remoteConfig = FirebaseRemoteConfig.instance;
    _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(milliseconds: 3000),
      minimumFetchInterval: const Duration(seconds: 3600),
    ));
    fetchConfiguration();
  }

  static RemoteConfigHelper instance() {
    _instance ??= RemoteConfigHelper._();
    return _instance!;
  }

  fetchConfiguration() async {
    try {
      await _remoteConfig.fetch();
      await _remoteConfig.activate();
      isEarningSectionDisabled =
          _remoteConfig.getBool("is_earning_section_disabled");
      earningSectionDisabledMessage =
          _remoteConfig.getString("earning_section_disabled_message");
      isVideoConfigured = _remoteConfig.getBool("is_video_configured");
      howAppWorks = _remoteConfig.getString("how_app_works");
      isVerifyBeneficiaryConfigured =
          _remoteConfig.getBool("is_verify_beneficiary_configured");
      isEarningStatementConfigured =
          _remoteConfig.getBool("is_earning_statement_configured");
      isBeneficiaryUpiModeDisabled =
          _remoteConfig.getBool("is_beneficiary_upi_mode_disabled");
      earningStatementNoteMessage =
          _remoteConfig.getString("earning_statement_note_message");
      enableAwignUniversity = _remoteConfig.getBool("enable_awign_university");
      delayWhatsappBottomSheet = _remoteConfig
          .getInt("delay_for_showing_whatsapp_notifications_bottom_sheet");
      isLeaderboardEnabled = _remoteConfig.getBool("is_leaderboard_enabled");
      showLeadPayoutDate = _remoteConfig.getBool("show_lead_payout_date");
      isOtplessEnabled = _remoteConfig.getBool("is_otpless_enabled");
      isLeaderboardEnabled =
          _remoteConfig.getBool("is_leaderboard_enabled");
      isLeaderboardEnabled = _remoteConfig.getBool("is_leaderboard_enabled");
      showNewUpdateForLeaderBoard =
          _remoteConfig.getInt("show_new_update_for_leaderboard");
    } catch (e, st) {
      AppLog.e(
          'RemoteConfigHelper.instance : ${e.toString()} \n${st.toString()}');
    }
  }
}
