import 'package:awign/workforce/core/data/model/advance_search/query_condition.dart';

class SummaryBlockResponse {
  List<SummaryBlock>? blocks;

  SummaryBlockResponse({this.blocks});

  SummaryBlockResponse.fromJson(Map<String, dynamic> json) {
    if (json['blocks'] != null) {
      blocks = <SummaryBlock>[];
      json['blocks'].forEach((v) {
        blocks!.add(SummaryBlock.fromJson(v));
      });
    }
  }
}

class SummaryBlock {
  String? id;
  String? createdAt;
  List<Map<String, QueryCondition>>? filterConditions;
  int? leadCount;
  String? name;
  String? parentBlockId;
  String? summaryViewId;
  String? updatedAt;

  SummaryBlock(
      {this.id,
        this.createdAt,
        this.filterConditions,
        this.leadCount,
        this.name,
        this.parentBlockId,
        this.summaryViewId,
        this.updatedAt});

  SummaryBlock.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    createdAt = json['created_at'];
    if (json['filter_conditions'] != null) {
      filterConditions = <Map<String, QueryCondition>>[];
      json['filter_conditions'].forEach((v) {
        Map<String, dynamic> map = v as Map<String, dynamic>;
        Map<String, QueryCondition> tempMap = {};
        map.forEach((key, value) {
          tempMap[key] = QueryCondition.fromJson(value);
        });
        filterConditions!.add(tempMap);
      });
    }
    leadCount = json['lead_count'];
    name = json['name'];
    parentBlockId = json['parent_block_id'];
    summaryViewId = json['summary_view_id'];
    updatedAt = json['updated_at'];
  }
}