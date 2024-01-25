import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_response.dart';

import '../work_application/application_status.dart';

class CampusAmbassadorMapper {
  static Future<Map<String, num>> transform(
      CampusAmbassadorAnalyticsResponse entity) async {
    Map<String, num> hashMap = {};
    if (entity.analytics == null) return hashMap;
    num selected = 0;
    if (entity.analytics!.containsKey(ApplicationStatus.selected.value)) {
      selected += entity.analytics![ApplicationStatus.selected.value!];
    }
    if (entity.analytics!
        .containsKey(ApplicationStatus.executionCompleted.value)) {
      selected += entity.analytics![ApplicationStatus.executionCompleted.value];
    }
    if (entity.analytics!
        .containsKey(ApplicationStatus.executionStarted.value)) {
      selected += entity.analytics![ApplicationStatus.executionStarted.value];
    }

    num working = 0;
    if (entity.analytics!.containsKey(ApplicationStatus.approvedToWork.value)) {
      working += entity.analytics![ApplicationStatus.approvedToWork.value];
    }

    num failedCount = 0;

    if (entity.analytics!.containsKey(ApplicationStatus.rejected.value)) {
      failedCount += entity.analytics![ApplicationStatus.rejected.value];
    }
    if (entity.analytics!.containsKey(ApplicationStatus.disqualified.value)) {
      failedCount += entity.analytics![ApplicationStatus.disqualified.value];
    }
    if (entity.analytics!.containsKey(ApplicationStatus.backedOut.value)) {
      failedCount += entity.analytics![ApplicationStatus.backedOut.value];
    }

    hashMap['working'] = working;
    hashMap['selected'] = selected;
    num total = 0;

    for (num v in entity.analytics!.values) {
      total += v;
    }

    total -= (failedCount + working + selected);
    hashMap['all'] = total < 0 ? 0 : total;

    return hashMap;
  }
}
