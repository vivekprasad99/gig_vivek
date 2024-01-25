import 'package:awign/workforce/execution_in_house/data/model/lead_map_view_entity.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/model/lead_view_config_entity.dart';

part 'lead_map_view_state.dart';

class LeadMapViewCubit extends Cubit<LeadMapViewState> {
  LeadMapViewCubit() : super(LeadMapViewInitial());

  final _markerDataList = BehaviorSubject<List<MarkerData>>();

  Stream<List<MarkerData>> get markerDataList => _markerDataList.stream;

  Function(List<MarkerData>) get changeMarkerDataList =>
      _markerDataList.sink.add;

  List<MarkerData> get markerDataListValue => _markerDataList.value;

  final _primaryColumnUid = BehaviorSubject<String?>();

  Stream<String?> get primaryColumnUid => _primaryColumnUid.stream;

  Function(String?) get changePrimaryColumnUid => _primaryColumnUid.sink.add;

  String? get primaryColumnUidValue => _primaryColumnUid.valueOrNull;

  @override
  Future<void> close() {
    _markerDataList.close();
    _primaryColumnUid.close();
    return super.close();
  }

  Future<void> addMarkers(LeadMapViewEntity leadMapViewEntity) async {
    List<MarkerData> allMarkers = [];
    // BitmapDescriptor customMarkerIcon = await BitmapDescriptor.fromAssetImage(
    //   const ImageConfiguration(),
    //   'assets/images/ic_pin_blue.png',
    // );
    for (final lead in leadMapViewEntity.leadList) {
      allMarkers.addAll(await addMarker(
          lead.leadMap, leadMapViewEntity.mappableUid /*, customMarkerIcon*/));
    }
    changeMarkerDataList(allMarkers);
  }

  Future<List<MarkerData>> addMarker(Map<String, dynamic> leadObject,
      String mappableUid /*, BitmapDescriptor customMarkerIcon*/) async {
    List<MarkerData> listOfMarkers = [];
    LatLng latLng = getLatLng(leadObject, mappableUid);
    // setSelected(marker)
    List<Placemark> address =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    String fullAddress =
        '${address[0].name}, ${address[0].subLocality}, ${address[0].locality}, ${address[0].postalCode}, ${address[0].country}';
    listOfMarkers.add(MarkerData(
        latLng, getLeadName(leadObject), fullAddress /*, customMarkerIcon*/));

    return listOfMarkers;
  }

  LatLng getLatLng(Map<String, dynamic> leadObject, String mappableUid) {
    List<dynamic> latLngArray = leadObject[mappableUid] as List<dynamic>;
    return LatLng(latLngArray[0] as double, latLngArray[1] as double);
  }

  String getLeadName(Map<String, dynamic> leadObject) {
    return leadObject[primaryColumnUidValue] as String? ?? "No Name";
  }

  void getPrimaryColumnUid(LeadMapViewEntity leadMapViewEntity) {
    List<Columns> listViewColumns = [];
    List<Columns> actionColumns = [];
    List<Columns> listColumns = [];
    String? renderType;

    if (leadMapViewEntity.statusListViewConfigMap == null) return;
    ListViews listViews;
    leadMapViewEntity.statusListViewConfigMap!.forEach((k, v) {
      listViews = v as ListViews;
      listViewColumns = v.columns ?? <Columns>[];
    });

    if (listViewColumns.isEmpty) return;

    for (final column in listViewColumns) {
      if (primaryColumnUidValue == null && column.primary) {
        changePrimaryColumnUid(column.uid);
        renderType = column.renderType;
      } else if (column.action != null) {
        actionColumns.add(column);
      } else {
        listColumns.add(column);
      }
    }
    if (primaryColumnUidValue == null && listViewColumns.isNotEmpty) {
      changePrimaryColumnUid(listViewColumns[0].uid);
      renderType = listViewColumns[0].renderType;
    }
  }

  Set<Marker> markerList() {
    Set<Marker> markerSet = {};
    int markerID = 0;
    for (final markerData in markerDataListValue) {
      markerSet.add(Marker(
        markerId: MarkerId(markerID.toString()),
        position: markerData.latLng,
        infoWindow:
            InfoWindow(title: markerData.title, snippet: markerData.address),
      ));
      markerID++;
    }
    return markerSet;
  }
}
