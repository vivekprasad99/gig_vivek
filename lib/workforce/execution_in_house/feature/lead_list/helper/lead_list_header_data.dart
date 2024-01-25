import 'package:awign/workforce/core/data/model/advance_search/query_condition.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_view_config_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/summary_block_response.dart';

class LeadListHeaderData {
  late List<SummaryBlock> selectedBlockList = [];
  String? searchTerm;
  late bool isFilterApplied;
  List<Map<String, QueryCondition>>? filters;
  Map<String, ListViews>? statusListViewHash;
  late bool isFilterEmpty;

  LeadListHeaderData(
      {this.searchTerm,
      this.isFilterApplied = false,
      this.filters,
      this.statusListViewHash,
      this.isFilterEmpty = true});
}
