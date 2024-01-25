import '../../../../execution_in_house/feature/dashboard/data/model/dashboard_widget_argument.dart';
import '../../../data/model/notification_response.dart';
import '../../../router/router.dart';

class FCMNotificationActionHelper {

  static void launchWidgetFromActionData(Notifications notification) {
    if(notification.actionData != null) {
      if(notification.actionData!.executionID != null && notification.actionData!.projectID != null
        && notification.actionData!.projectRoleUID != null && notification.actionData!.leadStatus != null) {
        DashboardWidgetArgument dashboardWidgetArgument = DashboardWidgetArgument(
          executionID: notification.actionData!.executionID,
          projectID: notification.actionData!.projectID,
          projectRoleUID: notification.actionData!.projectRoleUID,
        );
        MRouter.pushNamed(MRouter.dashboardWidget, arguments: dashboardWidgetArgument);
      }
    }

  }
}