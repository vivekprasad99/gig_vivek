import '../../../../data/model/execution.dart';

class DashboardWidgetArgument {
  Execution? execution;
  String? executionID;
  String? projectID;
  String? projectRoleUID;
  String? leadStatus;

  DashboardWidgetArgument(
      {this.execution,
      this.executionID,
      this.projectID,
      this.projectRoleUID,
      this.leadStatus});
}