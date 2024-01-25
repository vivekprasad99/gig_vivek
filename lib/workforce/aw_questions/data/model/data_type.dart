import 'package:awign/workforce/core/data/model/enum.dart';

class DataType<String> extends Enum1<String> {
  const DataType(String val) : super(val);

  static const DataType single = DataType('single');
  static const DataType array = DataType('array');
  static const DataType hash = DataType('hash');

  static DataType? get(dynamic dataTypeValue) {
    switch (dataTypeValue) {
      case 'single':
        return DataType.single;
      case 'array':
        return DataType.array;
      case 'hash':
        return DataType.hash;
      default:
        return null;
    }
  }
}
