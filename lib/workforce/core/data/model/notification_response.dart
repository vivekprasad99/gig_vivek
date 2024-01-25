import 'package:awign/workforce/core/data/model/advance_search/query_condition.dart';

class NotificationResponse
{
  String? status;
  NotificationData? data;
  String? message;

  NotificationResponse(
      {this.status, this.data, this.message});

  NotificationResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null
        ? NotificationData.fromJson(json['data'])
        : null;
    message = json['message'];
  }
}

class NotificationData {
  int? total;
  int? count;
  List<Notifications>? notifications;
  int? total_unread_count;
  int? page;
  int? limit;

  NotificationData(
      {this.total,
        this.count,
        this.notifications,
        this.page,
        this.total_unread_count,
        this.limit
        });

  NotificationData.fromJson(Map<String, dynamic> json) {
    if (json['notifications'] != null) {
      notifications = <Notifications>[];
      json['notifications'].forEach((v) {
        notifications!.add(Notifications.fromJson(v));
      });
    }
  }
}

class Notifications
{
  int? id;
  String? title;
  String? notification_text;
  String? created_by_id;
  int? user_id;
  String? click_action;
  FCMIntentData? actionData;
  String? created_at;
  String? updated_at;
  String? mediums;
  String? status;
  String? click_url;
  String? notify_at;
  String? body_type;
  String? campaign_id;
  String? image;

  Notifications(
      {this.id,
        this.title,
        this.notification_text,
        this.status,
        this.created_by_id,
        this.user_id,
        this.actionData,
        this.created_at,
        this.updated_at,
        this.mediums,
        this.click_url,
        this.notify_at,this.body_type,this.campaign_id,this.click_action,this.image});


  Notifications.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    id = json['id'];
    title = json['title'];
    notification_text = json['notification_text'];
    created_by_id = json['created_by_id'];
    click_action = json['click_action'];
    user_id = json['user_id'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
    actionData = json['action_data'] != null
        ? FCMIntentData.fromJson(json['action_data'])
        : null;
    mediums = json['mediums'];
    click_url = json['click_url'];
    notify_at = json['notify_at'];
    body_type = json['body_type'];
    campaign_id = json['campaign_id'];
    image = json['image'];
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
  // String? conversationID;
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
    // conversationID = json['conversation_id'];
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
}

class NotificationPageRequest
{
  int? userID;
  NotificationPageRequest({this.userID});
}