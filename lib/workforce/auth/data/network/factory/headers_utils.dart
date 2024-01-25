import 'dart:collection';

import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/utils/app_log.dart';

class HeadersUtils {
  static const accessToken = 'access-token';
  static const client = 'client';
  static const uID = 'uid';
  static const xClientID = 'x_client_id';
  static const contentType = 'Content-Type';
  static const xRequestID = 'X-Request-Id';
  static const saasOrgID = 'saas_org_id';
  static const xRoute = 'X_ROUTE';

  static Future<Map<String, dynamic>> getHeaders() async {
    Map<String, dynamic> headers = HashMap();
    try {
      SPUtil? spUtil = await SPUtil.getInstance();
      String? accessTokenValue = spUtil?.getAccessToken();
      headers.putIfAbsent(accessToken, () => accessTokenValue);
      String? clientValue = spUtil?.getClient();
      headers.putIfAbsent(client, () => clientValue);
      String? uIDValue = spUtil?.getUID();
      headers.putIfAbsent(uID, () => uIDValue);
      String? saasOrgIDValue = spUtil?.getSaasOrgID();
      headers.putIfAbsent(saasOrgID, () => saasOrgIDValue);
      headers.putIfAbsent(xClientID, () => 'intern_android');
      headers.putIfAbsent(contentType, () => 'application/json');
      headers.putIfAbsent(xRequestID,
          () => 'flutter-intern-${DateTime.now().millisecondsSinceEpoch}');
      if (spUtil?.getXRoute() != null) {
        headers.putIfAbsent(xRoute, () => spUtil?.getXRoute());
      }
    } catch (e, stacktrace) {
      AppLog.e('getHeaders : ${e.toString()} \n${stacktrace.toString()}');
    }
    return headers;
  }
}
