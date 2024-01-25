import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/data/model/advance_search/query_condition.dart';

class AdvancedSearchRequest {
  static const categoryID = 'category_id';
  static const status = 'status';
  static const supplyPendingAction = 'supply_pending_action';
  static const exploreOtherJobs = 'explore_other_jobs';
  static const worklistingID = 'worklisting_id';
  String? _searchColumn;
  String? _searchTerm;
  List<Map<String, QueryCondition>>? _conditions;
  int? _page;
  int? _limit;
  String? _sortOrder;
  String? _sortColumn;
  String? _aggs;
  Map<String, String>? _emailCondition;
  Map<String, String>? _smsCondition;
  Map<String, String>? _notification;
  bool? _skipSaasOrgId;
  bool? _createApplication;
  bool? _includeApplicationEligibilities;
  bool? _includeAttendanceConfig;
  bool? _includeNextPunchCta;
  bool? _skipLimit;

  void setSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
  }

  void setConditions(List<Map<String, QueryCondition>> conditions) {
    _conditions = conditions;
  }

  void addToConditions(Map<String, QueryCondition> condition) {
    _conditions?.add(condition);
  }

  void setPage(int page) {
    _page = page;
  }

  void setLimit(int limit) {
    _limit = limit;
  }

  void setAggs(String aggs) {
    _aggs = aggs;
  }

  void setSortColumn(String sortColumn) {
    _sortColumn = sortColumn;
  }

  void setSortOrder(String sortOrder) {
    _sortOrder = sortOrder;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    if (_searchColumn != null)
      _data['search_column'] = _searchColumn;
    if (_searchTerm != null)
      _data['search_term'] = _searchTerm;
    List<Map<String, dynamic>> list = [];
    for (int i = 0; i < _conditions!.length; i++) {
      Map<String, QueryCondition> map = _conditions![i];
      Map<String, dynamic> tempMap = <String, dynamic>{};
      for (MapEntry<String, QueryCondition> e in map.entries) {
        tempMap[e.key] = e.value.toJson();
      }
      list.add(tempMap);
    }
    if(list.isEmpty) {
      list.add({});
    }
    _data['conditions'] = list.map((e) => e).toList();
    if (_page != null)
    _data['page'] = _page;
    if (_limit != null)
    _data['limit'] = _limit;
    if (_sortOrder != null)
    _data['sort_order'] = _sortOrder;
    if (_sortColumn != null)
    _data['sort_column'] = _sortColumn;
    if (_aggs != null)
    _data['aggs'] = _aggs;
    if (_emailCondition != null)
    _data['email'] = _emailCondition;
    if (_smsCondition != null)
    _data['sms'] = _smsCondition;
    if (_notification != null)
    _data['notification'] = _notification;
    if (_skipSaasOrgId != null)
    _data['skip_saas_org_id'] = _skipSaasOrgId;
    if (_createApplication != null)
      _data['create_application'] = _createApplication;
    if (_includeApplicationEligibilities != null)
      _data['include_application_eligibilities'] = _includeApplicationEligibilities;
    if (_includeAttendanceConfig != null)
      _data['include_attendance_config'] = _includeAttendanceConfig;
    if (_includeNextPunchCta != null)
      _data['include_next_punch_cta'] =  _includeNextPunchCta;
    if (_skipLimit != null)
      _data['skip_limit'] =  _skipLimit;
    if (_includeApplicationEligibilities != null)
      _data['include_application_eligibilities'] = _includeApplicationEligibilities;
    return _data;
  }
}

class AdvanceSearchRequestBuilder {
  static const defaultPosition = 0;
  static const defaultLimit = 10;
  late AdvancedSearchRequest request;

  AdvanceSearchRequestBuilder() {
    request = AdvancedSearchRequest();
    request._conditions = [];
  }

  AdvanceSearchRequestBuilder putPropertyToCondition(
      String key, Operator operator, Object value) {
    if (request._conditions != null && request._conditions!.isNotEmpty) {
      for (int i = 0; i < request._conditions!.length; i++) {
        _putPropertyToCondition(i, key, operator, value);
      }
      return this;
    } else {
      return _putPropertyToCondition(defaultPosition, key, operator, value);
    }
  }

  AdvanceSearchRequestBuilder putPropertyToConditionList(
      String key, Operator operator, Object value) {
    if (request._conditions != null && request._conditions!.isNotEmpty) {
        _putPropertyToCondition(request._conditions!.length, key, operator, value);
      return this;
    } else {
      return _putPropertyToCondition(defaultPosition, key, operator, value);
    }
  }

  AdvanceSearchRequestBuilder _putPropertyToCondition(
      int position, String key, Operator operator, Object value) {
    if (request._conditions != null &&
        position >= request._conditions!.length) {
      position = request._conditions!.length;
      request._conditions!.add(<String, QueryCondition>{});
    }
    Map<String, QueryCondition> condition = request._conditions![position];
    QueryCondition queryCondition = QueryCondition();
    queryCondition.value = value;
    queryCondition.operator = operator.name();
    condition[key] = queryCondition;
    return this;
  }

  AdvanceSearchRequestBuilder addCondition(
      Map<String, QueryCondition> condition) {
    return _addCondition(defaultPosition, condition);
  }

  AdvanceSearchRequestBuilder _addCondition(
      int position, Map<String, QueryCondition>? condition) {
    if (condition == null) {
      return this;
    }
    if (position >= request._conditions!.length) {
      request._conditions!.add(condition);
    } else {
      request._conditions![position] = condition;
    }
    return this;
  }

  AdvanceSearchRequestBuilder setConditions(
      List<Map<String, QueryCondition>>? conditions) {
    conditions ??= <Map<String, QueryCondition>>[];
    request._conditions = conditions;
    return this;
  }

  AdvanceSearchRequestBuilder setPage(int page) {
    request._page = page;
    return this;
  }

  AdvanceSearchRequestBuilder setLimit(int? limit) {
    if (limit != null && limit > 0) {
      request._limit = limit;
    }
    return this;
  }

  AdvanceSearchRequestBuilder setSearchColumn(String searchColumn) {
    request._searchColumn = searchColumn;
    return this;
  }

  AdvanceSearchRequestBuilder setSearchTerm(String searchTerm) {
    request._searchTerm = searchTerm;
    return this;
  }

  AdvanceSearchRequestBuilder setSortOrder(String sortOrder) {
    request._sortOrder = sortOrder;
    return this;
  }

  AdvanceSearchRequestBuilder setSortColumn(String sortColumn) {
    request._sortColumn = sortColumn;
    return this;
  }

  AdvanceSearchRequestBuilder setEmailCondition(
      Map<String, String> emailCondition) {
    request._emailCondition = emailCondition;
    return this;
  }

  AdvanceSearchRequestBuilder setSMSCondition(
      Map<String, String> smsCondition) {
    request._smsCondition = smsCondition;
    return this;
  }

  AdvanceSearchRequestBuilder setNotification(
      Map<String, String> notification) {
    request._notification = notification;
    return this;
  }

  AdvanceSearchRequestBuilder setSkipSaasOrgId(bool skipSaasOrgId) {
    request._skipSaasOrgId = skipSaasOrgId;
    return this;
  }

  AdvanceSearchRequestBuilder setCreateApplication(bool createApplication) {
    request._createApplication = createApplication;
    return this;
  }

  AdvanceSearchRequestBuilder setIncludeApplicationEligibilities(bool includeApplicationEligibilities) {
    request._includeApplicationEligibilities = includeApplicationEligibilities;
    return this;
  }

  AdvanceSearchRequestBuilder setIncludeAttendanceConfig(bool includeAttendanceConfig) {
    request._includeAttendanceConfig = includeAttendanceConfig;
    return this;
  }

  AdvanceSearchRequestBuilder setIncludeNextPunchCta(bool includeNextPunchCta) {
    request._includeNextPunchCta = includeNextPunchCta;
    return this;
  }

  AdvanceSearchRequestBuilder setSkipLimit(bool skipLimit) {
    request._skipLimit = skipLimit;
    return this;
  }

  AdvancedSearchRequest build() {
    return request;
  }
}
