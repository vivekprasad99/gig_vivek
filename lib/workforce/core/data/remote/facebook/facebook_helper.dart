import 'package:facebook_app_events/facebook_app_events.dart';

class FaceBookEventHelper {
  static late FacebookAppEvents facebookAppEvents;

  static void init() {
    facebookAppEvents = FacebookAppEvents();
    facebookAppEvents.setAdvertiserTracking(enabled: false);
  }

  static void addEvent(String eventName, Map<String, dynamic>? parameters) {
    facebookAppEvents.logEvent(name: eventName, parameters: parameters);
  }
}