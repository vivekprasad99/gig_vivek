enum Operator {
  equal,
  notEqual,
  greaterThan,
  greaterThanEqual,
  lessThen,
  lessThenEqual,
  between,
  contains,
  notContains,
  startsWith,
  endsWith,
  isEmpty,
  notEmpty,
  IN,
  notIn,
  boolean
}

extension ExtOperator on Operator {
  String? name() {
    String name = '';
    switch (this) {
      case Operator.equal:
        name = 'eq';
        break;
      case Operator.notEqual:
        name = 'not';
        break;
      case Operator.greaterThan:
        name = 'gt';
        break;
      case Operator.greaterThanEqual:
        name = 'gte';
        break;
      case Operator.lessThen:
        name = 'lt';
        break;
      case Operator.lessThenEqual:
        name = 'lte';
        break;
      case Operator.between:
        name = 'between';
        break;
      case Operator.contains:
        name = 'contains';
        break;
      case Operator.notContains:
        name = 'not_contains';
        break;
      case Operator.startsWith:
        name = 'starts_with';
        break;
      case Operator.endsWith:
        name = 'ends_with';
        break;
      case Operator.isEmpty:
        name = 'empty';
        break;
      case Operator.notEmpty:
        name = 'not_empty';
        break;
      case Operator.IN:
        name = 'in';
        break;
      case Operator.notIn:
        name = 'not_in';
        break;
      case Operator.boolean:
        name = 'bool';
        break;
      default:
        name = '';
    }
    return name;
  }
}
