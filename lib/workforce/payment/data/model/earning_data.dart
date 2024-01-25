import 'package:awign/workforce/payment/data/model/calculate_deduction_response.dart';
import 'package:awign/workforce/payment/data/model/workforce_payout_response.dart';

class EarningData {
  bool isToggleOn;
  WorkforcePayoutResponse workforcePayoutResponse;
  CalculateDeductionResponse? calculateDeductionResponse;

  EarningData(
      {this.isToggleOn = false, required this.workforcePayoutResponse,this.calculateDeductionResponse});
}
