import 'package:awign/workforce/auth/di/auth_cubit_container.dart' as acc;
import 'package:awign/workforce/more/di/more_cubit_container.dart' as mcc;
import 'package:awign/workforce/aw_questions/di/aw_questions_cubit_container.dart' as awqcc;
import 'package:awign/workforce/onboarding/di/onboarding_cubit_container.dart' as occ;
import 'package:awign/workforce/execution_in_house/di/execution_cubit_container.dart' as ecc;
import 'package:awign/workforce/payment/di/payment_cubit_container.dart' as pcc;
import 'package:awign/workforce/university/di/university_cubit_container.dart' as ucc;
import 'package:awign/workforce/banner/di/banner_cubit_container.dart' as bcc;

void init() {
  /* Cubits */
  acc.init();
  mcc.init();
  awqcc.init();
  occ.init();
  ecc.init();
  pcc.init();
  ucc.init();
  bcc.init();
}