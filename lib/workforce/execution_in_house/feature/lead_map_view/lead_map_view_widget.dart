import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_map_view_entity.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/widget/tile/lead_tile.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_map_view/cubit/lead_map_view_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../core/di/app_injection_container.dart';
import '../../../core/utils/helper.dart';
import '../../../core/utils/implicit_intent_utils.dart';
import '../../../core/widget/common/desktop_coming_soon_widget.dart';
import '../../data/model/lead_entity.dart';
import '../../data/model/lead_view_config_entity.dart';
import '../lead_list/helper/lead_constant.dart';
import '../lead_list/widget/bottomsheet/call_bridge_bottom_sheet.dart';
import '../lead_list/widget/bottomsheet/lead_card_action_bottomsheet.dart';
import '../lead_list/widget/bottomsheet/more_action_bottomsheet.dart';

class LeadMapViewWidget extends StatefulWidget {
  LeadMapViewEntity leadMapViewEntity;

  LeadMapViewWidget(this.leadMapViewEntity, {super.key});

  @override
  State<LeadMapViewWidget> createState() => _LeadMapViewWidgetState();
}

class _LeadMapViewWidgetState extends State<LeadMapViewWidget> {
  final LeadMapViewCubit _leadMapViewCubit = sl<LeadMapViewCubit>();
  late GoogleMapController mapController;
  LatLng initialPosition = const LatLng(17.3850, 78.4867);

  @override
  void initState() {
    super.initState();
    _leadMapViewCubit.getPrimaryColumnUid(widget.leadMapViewEntity);
    _leadMapViewCubit.addMarkers(widget.leadMapViewEntity);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      body: Stack(
        children: [
          buildGoogleMap(),
          buildCloseIcon(),
          buildHorizontalLeadList(),
        ],
      ),
    );
  }

  void _onLeadTap(int index, Lead lead) {
    mapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: _leadMapViewCubit.markerDataListValue[index].latLng,
            zoom: 20)))
        .then((value) =>
            {mapController.showMarkerInfoWindow(MarkerId(index.toString()))});
  }

  void _onMoreLeadActionTap(String action, Lead lead,
      List<Columns> actionColumns, List<String> moreAction) {
    List<Columns> moreColumns = <Columns>[];
    for (int i = 0; i < moreAction.length; i++) {
      List<Columns> actionColumn =
          getColumnsForAction(moreAction[i], actionColumns);
      moreColumns.addAll(actionColumn);
    }
    onActionClicked(lead, action, moreColumns);
  }

  void _onLeadActionTap(String action, Lead lead, List<Columns> actionColumns) {
    List<Columns> columns = getColumnsForAction(action, actionColumns);
    List<Columns> nonNullColumns = <Columns>[];
    for (Columns column in columns) {
      if (lead.get(column.uid!) != null) {
        nonNullColumns.add(column);
      }
    }

    if (nonNullColumns.isNotEmpty) {
      onActionClicked(lead, action, nonNullColumns);
    } else {
      Helper.showInfoToast('action_not_set'.tr);
    }
  }

  List<Columns> getColumnsForAction(
      String action, List<Columns> actionColumns) {
    List<Columns> columns = <Columns>[];
    for (Columns column in actionColumns) {
      if (column.action != null && column.action == action) {
        columns.add(column);
      }
    }
    return columns;
  }

  void onActionClicked(Lead lead, String action, List<Columns> columns) {
    if (action == ColumnAction.MORE) {
      showMoreActionBottomSheet(context, columns, lead,
          (bottomSheetAction, actionColumn) {
        handleAction(lead, bottomSheetAction, actionColumn);
      });
      return;
    }

    if (columns.length == 1) {
      handleAction(lead, action, columns[0]);
    } else {
      showLeadCardActionBottomSheet(context, action, columns, lead, (position) {
        handleAction(lead, action, columns.elementAt(position));
      });
    }
  }

  void handleAction(Lead lead, String action, Columns columns) {
    var value = lead.get(columns.uid!);
    switch (action.toLowerCase()) {
      case ColumnAction.WHATSAPP:
        if (value != null) {
          ImplicitIntentUtils().fireWhatsAppIntent(value.toString());
        }
        break;
      case ColumnAction.CALL:
        if (value != null) {
          ImplicitIntentUtils().fireCallIntent(value.toString());
        }
        break;
      case ColumnAction.BRIDGE_CALL:
        if (columns.uid != null) {
          showCallBridgeBottomSheet(context, columns.uid!, lead.getLeadID(),
              widget.leadMapViewEntity.executionId);
        }
        break;
      case ColumnAction.EMAIL:
        if (value != null) {
          ImplicitIntentUtils()
              .fireEmailIntent([value.toString()], "Awign Email", "");
        }
        break;
      case ColumnAction.LOCATION:
        if (value != null && value is List) {
          ImplicitIntentUtils()
              .fireLocationIntent([value[0].toString(), value[1].toString()]);
        }
        break;
    }
  }

  Widget buildGoogleMap() {
    return StreamBuilder<List<MarkerData>>(
        stream: _leadMapViewCubit.markerDataList,
        builder: (context, markerList) {
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
              (markerList.hasData && !markerList.data.isNullOrEmpty)
                  ? _leadMapViewCubit.markerDataListValue[0].latLng
                  : initialPosition,
              zoom: 12.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            markers:
            (markerList.hasData && !markerList.data.isNullOrEmpty)
                ? Set<Marker>.from(_leadMapViewCubit.markerList())
                : <Marker>{},
          );
        });
  }

  Widget buildCloseIcon() {
    return Padding(
      padding: const EdgeInsets.only(
          top: Dimens.padding_32, left: Dimens.padding_20),
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: SvgPicture.asset(
            width: Dimens.iconSize_48,
            height: Dimens.iconSize_48,
            'assets/images/ic_close_circle.svg'),
      ),
    );
  }

  Widget buildHorizontalLeadList() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.leadMapViewEntity.leadList.length,
          padding: const EdgeInsets.all(0),
          itemBuilder: (_, i) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: LeadTile(
                index: i,
                lead: widget.leadMapViewEntity.leadList[i],
                leadListHeaderData:
                widget.leadMapViewEntity.listHeaderData,
                summaryBlockList:
                widget.leadMapViewEntity.summaryBlockResponse!.blocks,
                onLeadTap: _onLeadTap,
                onLeadActionTap: _onLeadActionTap,
                onMoreLeadActionTap: _onMoreLeadActionTap,
                onCloneOrDeleteTap: null,
              ),
            );
          },
        ),
      ),
    );
  }
}
