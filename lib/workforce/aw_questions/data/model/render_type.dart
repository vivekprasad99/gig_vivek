import 'package:awign/workforce/core/data/model/enum.dart';

class RenderType<String> extends Enum1<String> {
  const RenderType(String val) : super(val);

  static const RenderType ARRAY = RenderType('array');
  static const RenderType DEFAULT = RenderType('single');
  static const RenderType NESTED = RenderType('hash');
}
