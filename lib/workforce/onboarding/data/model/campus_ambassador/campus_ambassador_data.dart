import 'package:awign/workforce/onboarding/data/model/campus_ambassador/campus_ambassador_entity.dart';

class CampusAmbassadorData {
  String? referralCode;
  CampusAmbassadorTasks campusAmbassadorTasks;

  CampusAmbassadorData(
      {required this.referralCode, required this.campusAmbassadorTasks});
}

class CampusApplicationData {
  List<String>? statusList;
  int? workListingId;
  String? referralCode;
  bool? isConditionEqual;

  CampusApplicationData(
      {this.referralCode,
       this.statusList,
       this.workListingId,
       this.isConditionEqual});
}
