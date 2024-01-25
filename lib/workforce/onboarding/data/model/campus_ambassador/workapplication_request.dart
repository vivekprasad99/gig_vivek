import 'package:awign/workforce/core/data/model/advance_search/query_condition.dart';

class WorkApplicationPageRequest
{
  int? userId;
  int? workListingId;
  String? referredBy;
  String? supplyPendingActionAppliedJobs;
  List<Map<String, QueryCondition>>? applicationHistoryQueryCondition;
  List<String>? validStatuses;
  List<String>? invalidStatuses;
  bool? skipSaasOrgId;

  WorkApplicationPageRequest({this.userId,this.workListingId,this.referredBy,this.supplyPendingActionAppliedJobs,this.applicationHistoryQueryCondition,this.validStatuses,this.invalidStatuses,this.skipSaasOrgId});
}