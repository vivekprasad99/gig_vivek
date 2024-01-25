import 'dart:math';

import 'package:awign/workforce/core/data/model/advance_search/query_condition.dart';
import 'package:awign/workforce/core/utils/constants.dart';

class FCMData {
  late int id;
  late String title;
  late String message;
  String? conversationID;
  FCMViewBody? viewBody;

  FCMData(
      {this.title = Constants.appName,
      this.message = '',
      this.conversationID,
      this.viewBody}) {
    id = Random(DateTime.now().millisecond).nextInt(9999);
  }

  FCMData.fromJson(Map<String, dynamic> json) {
    id = Random(DateTime.now().millisecond).nextInt(9999);
    title = json['title'] ?? Constants.appName;
    message = json['message'] ?? '';
    conversationID = json['conversation_id'];
    viewBody = json['view_body'] != null
        ? FCMViewBody.fromJson(json['view_body'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['message'] = message;
    data['conversation_id'] = conversationID;
    data['view_body'] = viewBody?.toJson();
    return data;
  }
}

class FCMViewBody {
  String? title;
  String? message;
  String? iconURL;
  String? icon;
  String? notificationText;
  String? clickAction;
  String? largeIconUrl;
  String? largeIcon;
  String? soundUrl;
  String? sound;
  String? actionUrl;
  String? deepLinkingUrl;
  String? action;
  String? conversationID;
  int? userID;
  FCMIntentData? intentData;
  String? notificationImage;
  String? summary;
  bool? isCleverTapNotification;
  Map<String, dynamic>? extras;

  FCMViewBody(
      {this.title,
      this.message,
      this.iconURL,
      this.icon,
      this.notificationText,
      this.clickAction,
      this.largeIconUrl,
      this.largeIcon,
      this.soundUrl,
      this.sound,
      this.actionUrl,
      this.deepLinkingUrl,
      this.action,
      this.conversationID,
      this.userID,
      this.intentData,
      this.notificationImage,
      this.summary,
      this.isCleverTapNotification,
      this.extras});

  FCMViewBody.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    message = json['message'];
    iconURL = json['icon_url'];
    icon = json['icon'];
    notificationText = json['notification_text'];
    clickAction = json['click_action'];
    largeIconUrl = json['large_icon_url'];
    largeIcon = json['large_icon'];
    soundUrl = json['sound_url'];
    sound = json['sound'];
    actionUrl = json['action_url'];
    deepLinkingUrl = json['deeplinking_url'];
    action = json['action'];
    conversationID = json['conversation_id'];
    userID = json['user_id'];
    intentData = json['intent_data'] != null
        ? FCMIntentData.fromJson(json['intent_data'])
        : null;
    notificationImage = json['notification_image'];
    summary = json['summary'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['message'] = message;
    data['icon_url'] = iconURL;
    data['icon'] = icon;
    data['notification_text'] = notificationText;
    data['click_action'] = clickAction;
    data['large_icon_url'] = largeIconUrl;
    data['large_icon'] = largeIcon;
    data['sound_url'] = soundUrl;
    data['sound'] = sound;
    data['action_url'] = actionUrl;
    data['deeplinking_url'] = deepLinkingUrl;
    data['action'] = action;
    data['conversation_id'] = conversationID;
    data['user_id'] = userID;
    data['intent_data'] = intentData?.toJson();
    data['notification_image'] = notificationImage;
    data['summary'] = summary;
    return data;
  }
}

class FCMIntentData {
  int? workListingID;
  String? internApplicationID;
  String? internExecutionID;
  String? taskID;
  String? clientName;
  int? internshipID;
  String? leadID;
  String? projectExecutionID;
  String? internshipExecutionID;
  String? executiveTaskID;
  String? bannerID;
  String? projectID;
  String? executionID;
  String? projectRoleID;
  String? conversationID;
  String? projectRoleUID;
  String? leadStatus;
  String? tabName;
  String? applicationID;
  int? categoryID;
  List<Map<String, QueryCondition>>? conditions;
  String? supplyPendingAction;

  FCMIntentData.fromJson(Map<String, dynamic> json) {
    workListingID = json['worklisting_id'];
    internApplicationID = json['intern_application_id'];
    internExecutionID = json['intern_execution_id'];
    taskID = json['task_id'];
    clientName = json['client_name'];
    internshipID = json['internship_id'];
    leadID = json['lead_id'];
    projectExecutionID = json['project_execution_id'];
    internshipExecutionID = json['internship_execution_id'];
    executiveTaskID = json['executive_task_id'];
    bannerID = json['banner_id'];
    projectID = json['project_id'];
    executionID = json['execution_id'];
    projectRoleID = json['project_role_id'];
    conversationID = json['conversation_id'];
    projectRoleUID = json['project_role_uid'];
    leadStatus = json['lead_status'];
    tabName = json['tab_name'];
    applicationID = json['application_id'];
    categoryID = json['category_id'];
    if (json['conditions'] != null) {
      conditions = <Map<String, QueryCondition>>[];
      json['conditions'].forEach((v) {
        Map<String, dynamic> map = v as Map<String, dynamic>;
        Map<String, QueryCondition> tempMap = {};
        map.forEach((key, value) {
          tempMap[key] = QueryCondition.fromJson(value);
        });
        conditions!.add(tempMap);
      });
    }
    supplyPendingAction = json['supply_pending_action'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['worklisting_id'] = workListingID;
    data['intern_application_id'] = internApplicationID;
    data['intern_execution_id'] = internExecutionID;
    data['task_id'] = taskID;
    data['client_name'] = clientName;
    data['internship_id'] = internshipID;
    data['lead_id'] = leadID;
    data['project_execution_id'] = projectExecutionID;
    data['internship_execution_id'] = internshipExecutionID;
    data['executive_task_id'] = executiveTaskID;
    data['banner_id'] = bannerID;
    data['project_id'] = projectID;
    data['execution_id'] = executionID;
    data['project_role_id'] = projectRoleID;
    data['conversation_id'] = conversationID;
    data['project_role_uid'] = projectRoleUID;
    data['lead_status'] = leadStatus;
    data['tab_name'] = tabName;
    data['application_id'] = applicationID;
    data['category_id'] = categoryID;
    List<Map<String, dynamic>> list = [];
    for (int i = 0; i < (conditions?.length ?? 0); i++) {
      Map<String, QueryCondition> map = conditions![i];
      Map<String, dynamic> tempMap = <String, dynamic>{};
      for (MapEntry<String, QueryCondition> e in map.entries) {
        tempMap[e.key] = e.value.toJson();
      }
      list.add(tempMap);
    }
    if (list.isEmpty) {
      list.add({});
    }
    data['conditions'] = list.map((e) => e).toList();
    data['supply_pending_action'] = supplyPendingAction;
    return data;
  }
}
