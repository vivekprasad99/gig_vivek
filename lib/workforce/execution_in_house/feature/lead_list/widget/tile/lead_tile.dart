import 'dart:math';

import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_view_config_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/summary_block_response.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/helper/lead_list_header_data.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/helper/lead_selection_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/lead_constant.dart';

class LeadTile extends StatelessWidget {
  static const int maxActionsOnCard = 4;
  static const lastActionPuttonPosition = maxActionsOnCard - 1;
  final int index;
  final Lead lead;
  final LeadListHeaderData leadListHeaderData;
  final List<SummaryBlock>? summaryBlockList;
  String? _primaryColumnUid;
  String? _renderType;
  ListViews? _listView;
  final List<Columns> _listColumns = [];
  final List<Columns> _actionColumns = [];
  final List<Columns> _mListColumns = [];
  final LeadSelectionData leadSelectionData = LeadSelectionData();
  final Function(int index, Lead lead) onLeadTap;
  final Function(String action, Lead lead, List<Columns> actionColumns)
      onLeadActionTap;
  final Function(String action, Lead lead, List<Columns> actionColumns,
      List<String> moreAction) onMoreLeadActionTap;
  final Function(LeadOption leadOption,int index, Lead lead,String listViewId)? onCloneOrDeleteTap;

  LeadTile(
      {Key? key,
      required this.index,
      required this.lead,
      required this.leadListHeaderData,
      required this.summaryBlockList,
      required this.onLeadTap,
      required this.onLeadActionTap,
      required this.onMoreLeadActionTap,
      required this.onCloneOrDeleteTap})
      : super(key: key) {
    _setColumnsData();
  }

  void _setColumnsData() {
    List<Columns> listViewColumns = [];
    if (leadListHeaderData.statusListViewHash == null) {
      return;
    }
    leadListHeaderData.statusListViewHash?.forEach((key, value) {
      _listView = value;
      listViewColumns = value.columns ?? [];
    });
    if (listViewColumns.isEmpty) {
      return;
    }
    for (Columns column in listViewColumns) {
      if (_primaryColumnUid == null && column.primary) {
        _primaryColumnUid = column.uid;
        _renderType = column.renderType;
      } else if (column.action != null) {
        _actionColumns.add(column);
      } else {
        _listColumns.add(column);
      }
    }
    if (_primaryColumnUid == null && listViewColumns.isNotEmpty) {
      _primaryColumnUid = listViewColumns[0].uid;
      _renderType = listViewColumns[0].renderType;
    }
    _setListColumns();
  }

  void _setListColumns() {
    for (Columns columns in _listColumns) {
      if (columns.uid == null || columns.columnTitle == null) {
        continue;
      } else {
        _mListColumns.add(columns);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_8),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyInkWell(
                            onTap: (){
                              onLeadTap(index, lead);
                            },
                            child: buildPrimaryColumnTitle()),
                      ),
                      Visibility(
                          visible: (_listView!.allowCloneLead! || _listView!.allowDeleteLead!) && onCloneOrDeleteTap!= null,
                          child: leadPopUpMenu()),
                    ],
                  ),
                  const SizedBox(height: Dimens.margin_8),
                  InkWell(
                    onTap: (){
                      onLeadTap(index, lead);
                    },
                      excludeFromSemantics: true,
                      child: buildsListRowsWidgets()),
                ],
              ),
              buildSetActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPrimaryColumnTitle() {
    if (_primaryColumnUid == null && _mListColumns.isNotEmpty) {
      _primaryColumnUid = _mListColumns[0].columnTitle;
      _renderType = _mListColumns[0].renderType;
      _mListColumns.removeAt(0);
    }
    Object? title;
    if (_primaryColumnUid != null) {
      title = lead.get(_primaryColumnUid!);
    }
    String ansValue = Constants.na;
    if (title != null) {
      ansValue = title.toString();
      if (_renderType != null &&
          _renderType == SubType.dateTime.value.toString().toLowerCase()) {
        if (title is List) {
          ansValue = title[0].toString().getFormattedDateTimeFromUTCDateTime(
              StringUtils.dateTimeFormatDMYHMSA);
        } else if (title is String) {
          ansValue = title.toString().getFormattedDateTimeFromUTCDateTime(
              StringUtils.dateTimeFormatDMYHMSA);
        }
      } else if (_renderType != null &&
          _renderType == SubType.date.value.toString().toLowerCase()) {
        if (title is List) {
          ansValue = title[0]
              .toString()
              .getFormattedDateTimeFromUTCDateTime(StringUtils.dateFormatDMY);
        } else if (title is String) {
          ansValue = title
              .toString()
              .getFormattedDateTimeFromUTCDateTime(StringUtils.dateFormatDMY);
        }
      } else if (_renderType != null &&
          _renderType == SubType.dateTimeRange.value.toString().toLowerCase()) {
        if (title is List) {
          ansValue = title[0].toString().getFormattedDateTimeFromUTCDateTime(
              StringUtils.dateTimeFormatDMYHMSA);
        } else if (title is String) {
          ansValue = title.toString().getFormattedDateTimeFromUTCDateTime(
              StringUtils.dateTimeFormatDMYHMSA);
        }
      } else if (_renderType != null &&
          _renderType == SubType.dateRange.value.toString().toLowerCase()) {
        if (title is List) {
          ansValue = title[0]
              .toString()
              .getFormattedDateTimeFromUTCDateTime(StringUtils.dateFormatDMY);
        } else if (title is String) {
          ansValue = title
              .toString()
              .getFormattedDateTimeFromUTCDateTime(StringUtils.dateFormatDMY);
        }
      }
    }
    return Text(ansValue, style: Get.textTheme.bodyText1Bold);
  }

  ListView buildsListRowsWidgets() {
    List<Widget> widgets = [];
    if (_mListColumns.isEmpty) {
      widgets.add(const SizedBox());
    } else {
      List<List<String>> listKeyValues = [];
      for (Columns column in _mListColumns) {
        Object? value = lead.get(column.uid ?? '');
        if (value != null) {
          String ansValue = value.toString();
          if (column.renderType != null &&
              column.renderType ==
                  SubType.dateTime.value.toString().toLowerCase()) {
            if (value is List) {
              ansValue = value[0]
                  .toString()
                  .getFormattedDateTimeFromUTCDateTime(
                      StringUtils.dateTimeFormatDMYHMSA);
            } else if (value is String) {
              ansValue = value.toString().getFormattedDateTimeFromUTCDateTime(
                  StringUtils.dateTimeFormatDMYHMSA);
            }
          } else if (column.renderType != null &&
              column.renderType ==
                  SubType.date.value.toString().toLowerCase()) {
            if (value is List) {
              ansValue = value[0]
                  .toString()
                  .getFormattedDateTimeFromUTCDateTime(
                      StringUtils.dateFormatDMY);
            } else if (value is String) {
              ansValue = value.toString().getFormattedDateTimeFromUTCDateTime(
                  StringUtils.dateFormatDMY);
            }
          } else if (column.renderType != null &&
              column.renderType ==
                  SubType.dateTimeRange.value.toString().toLowerCase()) {
            if (value is List) {
              ansValue = value[0]
                  .toString()
                  .getFormattedDateTimeFromUTCDateTime(
                      StringUtils.dateTimeFormatDMYHMSA);
            } else if (value is String) {
              ansValue = value.toString().getFormattedDateTimeFromUTCDateTime(
                  StringUtils.dateTimeFormatDMYHMSA);
            }
          } else if (column.renderType != null &&
              column.renderType ==
                  SubType.dateRange.value.toString().toLowerCase()) {
            if (value is List) {
              ansValue = value[0]
                  .toString()
                  .getFormattedDateTimeFromUTCDateTime(
                      StringUtils.dateFormatDMY);
            } else if (value is String) {
              ansValue = value.toString().getFormattedDateTimeFromUTCDateTime(
                  StringUtils.dateFormatDMY);
            }
          }
          listKeyValues.add([column.columnTitle ?? '', ansValue]);
        } else {
          listKeyValues.add([column.columnTitle ?? '', Constants.na]);
        }
      }
      for (int i = 0; i < min(5, listKeyValues.length); i++) {
        List<String> keyValue = listKeyValues[i];
        if (keyValue.length == 2) {

          bool shouldShowLink = keyValue.contains("Cdn Link");

          widgets.add(Padding(
            padding: const EdgeInsets.only(top: Dimens.padding_8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${keyValue[0]} :',
                    style: Get.textTheme.bodyText2SemiBold),
                const SizedBox(width: Dimens.padding_4),
                Flexible(
                    child: InkWell(
                      onTap: (){
                        if (shouldShowLink) {
                          _launchURL(keyValue[1]);
                        }
                      },
                      child: Text(shouldShowLink ? "view" : keyValue[1],
                          style: Get.textTheme.bodyText2?.copyWith(
                            decoration: shouldShowLink
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            // Add underline for "view" text
                            color: shouldShowLink
                                ? Colors.blue
                                : Colors.black, // Blue color for "view" text
                          )),
                    )),
              ],
            ),
          ));
        }
      }
    }
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 0),
      children: widgets,
    );
  }

  // Function to launch a URL
  void _launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  Widget buildSetActionButtons() {
    List<String> actionsToShowOnCard = <String>[];
    for (var columnData in _actionColumns) {
      if (columnData.action == null || columnData.uid == null) {
        continue;
      }
      actionsToShowOnCard.add(columnData.action!);
    }
    if (actionsToShowOnCard.isEmpty) {
      return const SizedBox();
    } else {
      return showActions(actionsToShowOnCard, lead);
    }
  }

  Widget showActions(List<String> actionsToShowOnCard, Lead lead) {
    List<String> newActionList = getTotalActionCount(actionsToShowOnCard);
    int actionsLimit = newActionList.length > maxActionsOnCard
        ? lastActionPuttonPosition
        : newActionList.length; // one less for more actions button

    String moreActionCount = "";
    if (newActionList.length != 3 && actionsLimit == 3) {
      // more than 4 present, show more button instead 4th button
      newActionList.insert(3, ColumnAction.MORE);
      moreActionCount = (newActionList.length - 4)
          .toString(); // -3 for because 3 action are there and  -1 for more ie, added by us
      actionsLimit++;
    }

    return Padding(
      padding: const EdgeInsets.only(top: Dimens.margin_12),
      child: SizedBox(
        height: Dimens.margin_60,
        width: double.infinity,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: actionsLimit,
          itemBuilder: (context, index) {
            String actionName = "";
            String actionIcon = "";
            switch (newActionList[index]) {
              case ColumnAction.WHATSAPP:
                actionName = 'whatsapp'.tr;
                actionIcon = 'assets/images/ic_whatsapp_violet.svg';
                break;
              case ColumnAction.CALL:
                actionName = 'call'.tr;
                actionIcon = 'assets/images/ic_call_violet.svg';
                break;
              case ColumnAction.BRIDGE_CALL:
                actionName = 'call_bridge'.tr;
                actionIcon = 'assets/images/ic_bridge_violet.svg';
                break;
              case ColumnAction.LOCATION:
                actionName = 'location'.tr;
                actionIcon = 'assets/images/ic_location_violet.svg';
                break;
              case ColumnAction.EMAIL:
                actionName = 'email'.tr;
                actionIcon = 'assets/images/ic_mail_violet.svg';
                break;
              case ColumnAction.MORE:
                actionName = 'more_action'.tr;
                actionIcon = 'assets/images/ic_mail_violet.svg';
            }
            return MyInkWell(
              onTap: () {
                if (newActionList[index] == ColumnAction.MORE) {
                  onMoreLeadActionTap(
                      newActionList[index],
                      lead,
                      _actionColumns,
                      newActionList.sublist(
                          lastActionPuttonPosition, newActionList.length));
                } else {
                  onLeadActionTap(newActionList[index], lead, _actionColumns);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundGrey300,
                      borderRadius: BorderRadius.all(
                        Radius.circular(Dimens.radius_20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: (newActionList[index] == ColumnAction.MORE)
                          ? Text("$moreActionCount+")
                          : SvgPicture.asset(actionIcon),
                    ),
                  ),
                  Text(actionName)
                ],
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: MediaQuery.of(context).size.width/15,
            );
          },
        ),
      ),
    );
  }

  List<String> getTotalActionCount(List<String> actionsToShowOnCard) {
    List<String> actionList = <String>[];
    if (actionsToShowOnCard.contains(ColumnAction.CALL)) {
      actionList.add(ColumnAction.CALL);
    }
    if (actionsToShowOnCard.contains(ColumnAction.WHATSAPP)) {
      actionList.add(ColumnAction.WHATSAPP);
    }
    if (actionsToShowOnCard.contains(ColumnAction.BRIDGE_CALL)) {
      actionList.add(ColumnAction.BRIDGE_CALL);
    }
    if (actionsToShowOnCard.contains(ColumnAction.EMAIL)) {
      actionList.add(ColumnAction.EMAIL);
    }
    if (actionsToShowOnCard.contains(ColumnAction.LOCATION)) {
      actionList.add(ColumnAction.LOCATION);
    }
    if (actionsToShowOnCard.contains(ColumnAction.MORE)) {
      actionList.add(ColumnAction.MORE);
    }
    return actionList;
  }

  Widget leadPopUpMenu()
  {
    return PopupMenuButton(
      padding:  const EdgeInsets.all(0),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<LeadOption>(
          value: LeadOption.Duplicate,
          child: Visibility(
            visible: _listView!.allowCloneLead!,
              child: Text('duplicate'.tr, style: Get.textTheme.bodyMedium)),
        ),
        PopupMenuItem<LeadOption>(
          value: LeadOption.Delete,
          child: Visibility(
              visible: _listView!.allowDeleteLead!,
              child: Text('delete'.tr, style: Get.textTheme.bodyMedium)),
        ),
      ],
      onSelected: (value) {
        if (onCloneOrDeleteTap != null) onCloneOrDeleteTap!(value as LeadOption,index,lead,_listView?.id ?? "");
      },
    );
  }
}
