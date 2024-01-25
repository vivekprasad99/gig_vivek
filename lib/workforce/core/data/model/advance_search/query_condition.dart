import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';

class QueryCondition {
  String? operator;
  dynamic value;

  QueryCondition({this.operator, this.value});

  QueryCondition.fromJson(Map<String, dynamic> json) {
    operator = json['operator'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['operator'] = operator;
    _data['value'] = value;
    return _data;
  }

  Operator? getOperator() {
    return operator?.getOperatorByName();
  }
}
