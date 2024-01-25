import 'dart:io' as io;

import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

class ZohoHelper {
  static Future<void> init(String zohoAppKey, String zohoAccessKey) async {
    try {
      if (kIsWeb) {
      } else if (io.Platform.isIOS || io.Platform.isAndroid) {
        ZohoSalesIQ.init(zohoAppKey, zohoAccessKey).then((_) {
          // initialization successful
          // To show the default live chat launcher, you can use the showLauncher API.
          // Alternatively, you may use the 'Avail floating chat button for your app' option under Settings → Brands → Installation → Android/iOS.
          AppLog.i('ZohoHelper init: successful');
        }).catchError((error) {
          // initialization failed
          AppLog.i('ZohoHelper init: $error');
        });
      }
    } catch (e) {
      AppLog.e('ZohoHelper init: ${e.toString()}');
    }
  }

  static void setupAndOpenZohoFaq(UserData? currentUser) {
    ZohoSalesIQ.setFAQVisibility(true);
    ZohoSalesIQ.setVisitorName(currentUser!.userProfile!.name!);
    ZohoSalesIQ.setConversationVisibility(false);
    ZohoSalesIQ.setVisitorContactNumber(currentUser.userProfile!.mobileNumber!);
    ZohoSalesIQ.setVisitorEmail(currentUser.userProfile!.email!);
    ZohoSalesIQ.show();
  }

  static void setupAndOpenZohoChat(UserData? currentUser) {
    ZohoSalesIQ.setConversationVisibility(true);
    ZohoSalesIQ.setFAQVisibility(false);
    ZohoSalesIQ.setVisitorName(currentUser!.userProfile!.name!);
    ZohoSalesIQ.setVisitorContactNumber(currentUser.userProfile!.mobileNumber!);
    ZohoSalesIQ.setVisitorEmail(currentUser.userProfile!.email!);
    ZohoSalesIQ.show();
  }
}
