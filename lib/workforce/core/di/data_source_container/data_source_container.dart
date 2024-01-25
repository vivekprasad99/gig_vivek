import 'package:awign/workforce/auth/di/auth_data_source_container.dart'
    as adsc;
import 'package:awign/workforce/more/di/more_data_source_container.dart' as mdc;
import 'package:awign/workforce/onboarding/di/onboarding_data_source_container.dart'
    as odc;
import 'package:awign/workforce/execution_in_house/di/execution_data_source_container.dart'
    as edc;
import 'package:awign/workforce/payment/di/payment_data_source_container.dart'
    as pdc;
import 'package:awign/workforce/university/di/university_data_source_container.dart'
    as udc;

import 'package:awign/workforce/banner/di/banner_data_source_container.dart' as bdc;

void init() {
  /* Data Sources */
  adsc.init();
  mdc.init();
  odc.init();
  edc.init();
  pdc.init();
  udc.init();
  bdc.init();
}
