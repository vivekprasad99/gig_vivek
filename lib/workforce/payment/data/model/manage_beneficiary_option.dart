import 'package:awign/workforce/core/data/model/enum.dart';

class ManageBeneficiaryOption<String> extends Enum1<String> {
  const ManageBeneficiaryOption(String val) : super(val);

  static const ManageBeneficiaryOption activate =
  ManageBeneficiaryOption('activate');
  static const ManageBeneficiaryOption deactivateAccount =
      ManageBeneficiaryOption('deactivateAccount');
  static const ManageBeneficiaryOption deleteAccount =
  ManageBeneficiaryOption('deleteAccount');
}
