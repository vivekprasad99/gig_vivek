import 'package:awign/workforce/auth/di/auth_repository_container.dart' as arc;
import 'package:awign/workforce/more/di/more_repository_container.dart' as mrc;
import 'package:awign/workforce/onboarding/di/onboarding_repository_container.dart'
    as orc;
import 'package:awign/workforce/execution_in_house/di/execution_repository_container.dart'
    as erc;
import 'package:awign/workforce/payment/di/payment_repository_container.dart'
    as prc;
import 'package:awign/workforce/university/di/university_repository_container.dart'
    as urc;
import 'package:awign/workforce/banner/di/banner_repository_container.dart' as brc;

void init() {
  /* Repositories */
  arc.init();
  mrc.init();
  orc.init();
  erc.init();
  prc.init();
  urc.init();
  brc.init();
}
