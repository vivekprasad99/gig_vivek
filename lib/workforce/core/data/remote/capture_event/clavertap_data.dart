import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';

class ClevertapData {
  String? eventName;
  Map<String, dynamic>? properties;
  ApplicationAction? applicationAction;
  WorkApplicationEntity? workApplicationEntity;
  UserData? currentUser;
  late bool isApplicationEvent;
  late bool isApplicationActionEvent;
  late bool isApplicationStatusEvent;
  String? clevertapActionType;
  ApplicationStatus? applicationStatus;

  ClevertapData(
      {this.eventName,
      this.properties,
      this.applicationAction,
      this.workApplicationEntity,
      this.currentUser,
      this.clevertapActionType,
      this.applicationStatus,
      this.isApplicationEvent = false,
      this.isApplicationActionEvent = false,
      this.isApplicationStatusEvent = false});
}
