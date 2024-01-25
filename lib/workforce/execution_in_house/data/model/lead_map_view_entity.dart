import 'package:awign/workforce/execution_in_house/data/model/lead_view_config_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/summary_block_response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../feature/lead_list/helper/lead_list_header_data.dart';
import 'lead_entity.dart';

class LeadMapViewEntity {
  late List<Lead> leadList;
  late Map<String, ListViews?>? statusListViewConfigMap;
  late String mappableUid;
  late String executionId;
  late LeadListHeaderData listHeaderData;
  late SummaryBlockResponse? summaryBlockResponse;

  LeadMapViewEntity(this.leadList, this.statusListViewConfigMap,
      this.mappableUid, this.executionId, this.listHeaderData, this.summaryBlockResponse);
}

class MarkerData {
  late LatLng latLng;
  late String title;
  late String? address;
  late BitmapDescriptor markerIcon;

  MarkerData(this.latLng, this.title, this.address /*, this.markerIcon*/);
}
