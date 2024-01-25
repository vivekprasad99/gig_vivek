import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_entity.dart';

class LeadScreensData {
  late Execution execution;
  late Lead lead;
  late String title;
  late ScreenViewType screenViewType;
  late LeadDataSourceParams leadDataSourceParams;
  late Map<String, dynamic> statusAliases;
  late int index;
  // late String availability;
  late Map<String, dynamic>? cleverTapEvent;

  LeadScreensData(
      this.execution,
      this.lead,
      this.title,
      this.screenViewType,
      this.leadDataSourceParams,
      this.statusAliases,
      this.index,
      this.cleverTapEvent);
}
