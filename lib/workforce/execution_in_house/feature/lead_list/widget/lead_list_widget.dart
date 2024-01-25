import 'dart:collection';

import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/debouncer.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/implicit_intent_utils.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/add_lead_and_request_for_work_bottom_sheet/widget/add_lead_and_request_for_work_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/circle_avatar/custom_circle_avatar.dart';
import 'package:awign/workforce/core/widget/common/data_not_found.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/shimmer/shimmer_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_map_view_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_view_config_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/summary_block_response.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/cubit/lead_list_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/helper/lead_constant.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/helper/lead_list_header_data.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/widget/bottomsheet/lead_card_action_bottomsheet.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/widget/tile/lead_tile.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_screens/helper/lead_screens_data.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_screens/widget/lead_screens_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'bottomsheet/call_bridge_bottom_sheet.dart';
import 'bottomsheet/more_action_bottomsheet.dart';

class LeadListWidget extends StatefulWidget {
  final Execution _execution;

  const LeadListWidget(this._execution, {Key? key}) : super(key: key);

  @override
  State<LeadListWidget> createState() => _LeadListWidgetState();
}

class _LeadListWidgetState extends State<LeadListWidget>
    with TickerProviderStateMixin {
  final LeadListCubit _leadListCubit = sl<LeadListCubit>();
  UserData? _currentUser;
  bool isSkipSaasOrgID = false;
  List<Widget> tabs = [];
  int tabsLength = 1;
  Map<String, List<String>> tabStatus = {};
  String currentStatus = '';
  Map<String, ListViews> listViewConfigMap = {};
  Map<String, int> statsCountMap = {};
  late LeadRemoteRequest leadRemoteRequest;
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();
  final _searchQuery = TextEditingController();
  final _fnSearchQuery = FocusNode();
  final _debouncer = Debouncer();
  TabController? _tabController;
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic> cleverTapEvent = {};

  @override
  void initState() {
    _searchQuery.addListener(_onSearchChanged);
    super.initState();
    tabs.add(const Tab(text: ''));
    _tabController = TabController(length: tabsLength, vsync: this);
    subscribeUIStatus();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (spUtil!.getSaasOrgID().isNullOrEmpty) {
      isSkipSaasOrgID = true;
    }
    _leadListCubit.fetchConfigAndAnalysis(widget._execution);
  }

  void subscribeUIStatus() {
    _leadListCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.success:
            Lead lead = uiStatus.data;
            LeadRemoteRequest? leadRemoteRequest =
                _leadListCubit.getLeadRemoteRequest();
            if (leadRemoteRequest != null &&
                _leadListCubit.getListViewConfigData() != null &&
                _leadListCubit.getListViewConfigData()?.statusAliases != null) {
              leadRemoteRequest.leadDataSourceParams.currentStatus =
                  lead.getStatus();
              leadRemoteRequest.leadDataSourceParams.screenViewType =
                  ScreenViewType.addLead;
              LeadScreensData leadScreensData = LeadScreensData(
                  widget._execution,
                  lead,
                  '',
                  ScreenViewType.addLead,
                  leadRemoteRequest.leadDataSourceParams,
                  _leadListCubit.getListViewConfigData()!.statusAliases!,
                  0,
                  cleverTapEvent);
              _openLeadScreenWidget(leadScreensData);
            }
            break;
          case Event.updated:
            Lead newlead = uiStatus.data;
            LeadRemoteRequest? leadRemoteRequest =
                _leadListCubit.getLeadRemoteRequest();
            if (leadRemoteRequest != null &&
                _leadListCubit.getListViewConfigData() != null &&
                _leadListCubit.getListViewConfigData()?.statusAliases != null) {
              leadRemoteRequest.leadDataSourceParams.screenViewType =
                  ScreenViewType.updateLead;
              LeadScreensData leadScreensData = LeadScreensData(
                  widget._execution,
                  newlead,
                  '',
                  ScreenViewType.updateLead,
                  leadRemoteRequest.leadDataSourceParams,
                  _leadListCubit.getListViewConfigData()!.statusAliases!,
                  0,
                  cleverTapEvent);
              _openLeadScreenWidget(leadScreensData);
            }
            break;
          case Event.deleted:
            Future.delayed(const Duration(milliseconds: 300), () {
              _leadListCubit.fetchConfigAndAnalysis(widget._execution);
            });
            break;
          case Event.none:
            break;
        }
      },
    );
    _leadListCubit.listViewConfigAndAnalyseDataStream.listen((tuple2) {
      if (tuple2.item1.tabs != null) {
        Map<String, dynamic> statues = tuple2.item2.status ?? {};
        List<String> tabStatues =
            tabStatus[widget._execution.selectedTab] ?? [];
        int count = 0;
        widget._execution.tabsMap?.forEach((key, value) {
          num total = 0;
          List<String> tabStatues = tabStatus[key] ?? [];
          statues.forEach((k, v) {
            if (tabStatus.containsKey(k)) {
              total = total + v;
            }
          });
          widget._execution.tabsMap?[key] = total;
          switch (count) {
            case 0:
              cleverTapEvent[CleverTapConstant.numLeadsWork] = value;
              break;
            case 1:
              cleverTapEvent[CleverTapConstant.numLeadsSubmitted] = value;
              break;
            case 2:
              cleverTapEvent[CleverTapConstant.numLeadsDone] = value;
              break;
          }
          count++;
        });

        for (Tabs tab in tuple2.item1.tabs!) {
          if (tab.name != null) {
            tabStatus[tab.name!] = tab.statuses ?? [];
          }
        }
      }

      onTabSelected(0);

      if (statsCountMap.isNotEmpty && tuple2.item2.status != null) {
        tabs.clear();
        statsCountMap.forEach((key, value) {
          tabs.add(Tab(
            text: '${tuple2.item1.statusAliases![key]} ($value)',
          ));
        });
        setState(() {
          tabsLength = tabs.length;
          _tabController =
              TabController(length: tabsLength, initialIndex: 0, vsync: this);
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          _scrollController.animateTo(
              _scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn);
        });
      } else {}
    });
  }

  void onTabSelected(int index) {
    if (tabStatus.containsKey(widget._execution.selectedTab)) {
      List<String> statuses = tabStatus[widget._execution.selectedTab] ?? [];
      if (statuses.isNotEmpty) {
        currentStatus = statuses[index];
      }
    }

    listViewConfigMap = {};
    if (_leadListCubit.getListViewConfigData() != null &&
        _leadListCubit.getListViewConfigData()!.listViews != null) {
      for (ListViews listViews
          in _leadListCubit.getListViewConfigData()!.listViews!) {
        if (listViews.workflowStatus == currentStatus) {
          listViewConfigMap[currentStatus] = listViews;
          break;
        }
      }
    }

    statsCountMap = {};
    if (_leadListCubit.getListViewConfigData() != null &&
        _leadListCubit.getListViewConfigData()!.tabs != null) {
      for (Tabs tab in _leadListCubit.getListViewConfigData()!.tabs!) {
        if (tab.name == widget._execution.selectedTab && tab.statuses != null) {
          for (String tabStatus in tab.statuses!) {
            if (_leadListCubit.getListViewConfigData()!.analyzeCounts != null &&
                _leadListCubit
                    .getListViewConfigData()!
                    .analyzeCounts!
                    .containsKey(tabStatus)) {
              statsCountMap[tabStatus] = _leadListCubit
                      .getListViewConfigData()!
                      .analyzeCounts![tabStatus] ??
                  0;
            }
          }
        }
      }
    }

    if (widget._execution.id != null &&
        widget._execution.selectedProjectRole != null &&
        listViewConfigMap.isNotEmpty &&
        listViewConfigMap[currentStatus]!.id != null) {
      _leadListCubit.fetchSummaryViews(
          widget._execution.id!,
          widget._execution.selectedProjectRole?.toLowerCase()
                  .replaceAll(' ', '_') ??
              '',
          listViewConfigMap[currentStatus]!.id!);
    } else {}
  }

  _onSearchChanged() {
    _debouncer(() {
      _paginationKey.currentState?.search(_searchQuery.text);
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
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
      backgroundColor: AppColors.primaryMain,
      topPadding: 0,
      bottomPadding: 0,
      body: DefaultTabController(
        length: tabsLength,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: buildAppBarWidgets(),
                pinned: true,
                floating: true,
                bottom: TabBar(
                  onTap: (index) {
                    onTabSelected(index);
                  },
                  controller: _tabController,
                  labelColor: AppColors.yellow,
                  unselectedLabelColor: AppColors.backgroundWhite,
                  indicatorColor: AppColors.yellow,
                  indicatorPadding:
                      const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
                  isScrollable: tabsLength > 2 ? true : false,
                  tabs: tabs,
                ),
              ),
            ];
          },
          body: buildBody(),
        ),
      ),
      floatingActionButton: buildAddLeadButton(),
    );
  }

  Widget buildAppBarWidgets() {
    if (widget._execution.selectedTab != null &&
        widget._execution.tabsMap != null) {
      var value = widget._execution.tabsMap![widget._execution.selectedTab];
      return StreamBuilder<bool>(
          stream: _leadListCubit.isSearchBarVisibleStream,
          builder: (context, isSearchBarVisibleStream) {
            if (isSearchBarVisibleStream.hasData &&
                !isSearchBarVisibleStream.data!) {
              return Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        buildLeadingIcon(),
                        StreamBuilder<int?>(
                            stream: _leadListCubit.leadCountStream,
                            builder: (context, leadCountStream) {
                              int? leadCount = value;
                              if (leadCountStream.hasData &&
                                  leadCountStream.data != null) {
                                leadCount = leadCountStream.data!;
                              }
                              return Flexible(
                                child: Text(
                                  '${widget._execution.selectedTab} ($leadCount)',
                                  overflow: TextOverflow.ellipsis,
                                  style: Get
                                      .context?.textTheme.headline6SemiBold
                                      ?.copyWith(
                                          color: AppColors.backgroundWhite),
                                ),
                              );
                            }),
                        MyInkWell(
                          onTap: () {},
                          child: const Icon(Icons.arrow_drop_down_outlined,
                              color: AppColors.backgroundWhite),
                        ),
                      ],
                    ),
                  ),
                  MyInkWell(
                      onTap: () {
                        _leadListCubit.changeIsSearchBarVisible(true);
                      },
                      child: const Icon(Icons.search,
                          color: AppColors.backgroundWhite)),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: buildSearchTextField(),
                  ),
                  const SizedBox(width: Dimens.padding_8),
                  MyInkWell(
                      onTap: () {
                        _leadListCubit.changeIsSearchBarVisible(false);
                      },
                      child: Text('cancel'.tr,
                          style: Get.textTheme.overline
                              ?.copyWith(color: AppColors.backgroundWhite))),
                ],
              );
            }
          });
    } else {
      return const SizedBox();
    }
  }

  Widget buildBackIcon() {
    return MyInkWell(
      onTap: () {
        MRouter.pop(null);
      },
      child: SvgPicture.asset('assets/images/arrow_left.svg',
          color: AppColors.backgroundWhite),
    );
  }

  Widget buildLeadingIcon() {
    if (widget._execution.projectIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(right: Dimens.padding_16),
        child: CustomCircleAvatar(
            url: widget._execution.projectIcon, radius: Dimens.radius_16),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildSearchTextField() {
    return Container(
      height: Dimens.etHeight_40,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Stack(
        children: [
          TextField(
            style: Get.textTheme.bodyText1,
            maxLines: 1,
            controller: _searchQuery,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            focusNode: _fnSearchQuery,
            autofocus: false,
            onSubmitted: (v) {
              _leadListCubit.getLeads(1, v);
            },
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_40,
                  Dimens.padding_8, Dimens.padding_40, Dimens.padding_8),
              fillColor: Get.theme.textFieldBackgroundColor,
              hintText: 'search'.tr,
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Get.theme.textFieldBackgroundColor),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Get.theme.textFieldBackgroundColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Get.theme.textFieldBackgroundColor),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: Dimens.padding_8),
                child: Icon(
                  Icons.search,
                  color: Get.theme.iconColorNormal,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: MyInkWell(
                onTap: () {
                  _searchQuery.text = '';
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: Dimens.padding_8),
                  child: Icon(
                    Icons.clear_rounded,
                    color: Get.theme.iconColorNormal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAddLeadButton() {
    return StreamBuilder<LeadListHeaderData>(
        stream: _leadListCubit.leadListHeaderDataStream,
        builder: (context, leadListHeaderDataStream) {
          bool addLeadReqWork = false;
          bool allowMapView = false;
          ListViews? listViews;
          if (leadListHeaderDataStream.hasData &&
              leadListHeaderDataStream.data!.statusListViewHash != null) {
            for (ListViews listView
                in leadListHeaderDataStream.data!.statusListViewHash!.values) {
              if (listView.allowAddLead ?? false) {
                addLeadReqWork = listView.allowAddLead!;
                listViews = listView;
                break;
              }
            }
            for (ListViews listView
                in leadListHeaderDataStream.data!.statusListViewHash!.values) {
              if (listView.enableMapView ?? false) {
                allowMapView = listView.enableMapView!;
                listViews = listView;
                break;
              }
            }
          }
          return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (allowMapView) ...[
              MyInkWell(
                onTap: () {
                  List<Lead>? listOfLeads =
                      _paginationKey.currentState?.getAllItems() as List<Lead>?;
                  List<Lead>? listOfLeadsWithMapAttribute = [];
                  if (listOfLeads == null) return;
                  int index = listOfLeads.length - 1;

                  while (true) {
                    Lead lead = listOfLeads[index];
                    if (lead.leadMap.containsKey(listViews?.mapViewAttribute) ==
                        true) {
                      listOfLeadsWithMapAttribute.add(lead);
                    }
                    if (index == 0) {
                      break;
                    }
                    index--;
                  }

                  if (listOfLeadsWithMapAttribute.isEmpty) {
                    Helper.showInfoToast('lead_not_found'.tr);
                    return;
                  }

                  MRouter.pushNamed(MRouter.leadMapViewWidget,
                      arguments: LeadMapViewEntity(listOfLeadsWithMapAttribute,
                          _leadListCubit.getLeadListHeaderData().statusListViewHash,
                          listViews?.mapViewAttribute ?? "",
                          widget._execution.id ?? "",
                          _leadListCubit.getLeadListHeaderData(),
                          _leadListCubit.summaryBlockResponseValue));
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      right: (addLeadReqWork)
                          ? MediaQuery.of(context).size.width / 4
                          : MediaQuery.of(context).size.width / 3),
                  child: Container(
                      padding: const EdgeInsets.all(Dimens.padding_8),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(Dimens.radius_16),
                          ),
                          color: AppColors.backgroundGrey800),
                      child: Row(
                        children: [
                          const Icon(Icons.map_rounded,
                              color: AppColors.backgroundWhite),
                          const SizedBox(
                            width: Dimens.margin_4,
                          ),
                          Text('map_view'.tr,
                              style: const TextStyle(
                                  color: AppColors.backgroundWhite)),
                        ],
                      )),
                ),
              )
            ],
            if (addLeadReqWork) ...[
              FloatingActionButton(
                onPressed: () {
                  showAddLeadAndRequestForWorkBottomSheet(context, listViews!,
                      addLeadReqWork, false, onAddLeadTap, onRequestForWorkTap);
                },
                backgroundColor: AppColors.primaryMain,
                child: const Icon(Icons.menu),
              ),
            ]
          ]);
        });
  }

  void onAddLeadTap(ListViews listView) {
    MRouter.pop(null);
    _leadListCubit.addLead(listView.id ?? '');
  }

  void onRequestForWorkTap(ListViews listView) {
    MRouter.pop(null);
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<SummaryBlockResponse?>(
            stream: _leadListCubit.summaryBlockResponseStream,
            builder: (context, summaryBlockResponseStream) {
              if (summaryBlockResponseStream.hasData &&
                  summaryBlockResponseStream.data != null) {
                LeadListHeaderData leadListHeaderData =
                    _leadListCubit.getLeadListHeaderData();
                if (listViewConfigMap.isNotEmpty) {
                  leadListHeaderData.statusListViewHash = listViewConfigMap;
                  _leadListCubit.changeLeadListHeaderData(leadListHeaderData);
                }

                SummaryBlock? summaryBlock = _leadListCubit
                    .getSummaryBlock(leadListHeaderData.selectedBlockList);

                LeadDataSourceParams leadDataSourceParams =
                    LeadDataSourceParams(
                        executionID: widget._execution.id,
                        projectID: widget._execution.projectId,
                        projectRoleUID: widget._execution.selectedProjectRole?.toLowerCase()
                                .replaceAll(' ', '_') ??
                            '',
                        statusAliases: _leadListCubit.getStatusAliasMap(),
                        projectRoleName: widget._execution.selectedProjectRole,
                        projectIcon: widget._execution.projectIcon);

                leadRemoteRequest = LeadRemoteRequest(
                    listViewID: listViewConfigMap[currentStatus]!.id!,
                    blockID: summaryBlock?.id,
                    filters: leadListHeaderData.filters,
                    leadDataSourceParams: leadDataSourceParams);
                _leadListCubit.changeLeadRemoteRequest(leadRemoteRequest);
                _leadListCubit.getLeads(1, null);
                return SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildSummaryBlockHeaderWidget(
                            summaryBlockResponseStream.data!.blocks),
                        buildLeadList(summaryBlockResponseStream.data!.blocks),
                      ],
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding:
                      const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_16),
                  child: buildShimmerWidgets(),
                );
              }
            }),
      ),
    );
  }

  Widget buildTitleText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text(widget._execution.projectName ?? '',
          style: Get.context?.textTheme.headline7Bold
              .copyWith(color: AppColors.backgroundBlack)),
    );
  }

  Widget buildLeadList(List<SummaryBlock>? summaryBlockList) {
    return PaginationView<Lead>(
      key: _paginationKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, Lead lead, int index) => LeadTile(
        index: index,
        lead: lead,
        leadListHeaderData: _leadListCubit.getLeadListHeaderData(),
        summaryBlockList: summaryBlockList,
        onLeadTap: _onLeadTap,
        onLeadActionTap: _onLeadActionTap,
        onMoreLeadActionTap: _onMoreLeadActionTap,
        onCloneOrDeleteTap: _onCloneOrDeleteTap,
      ),
      paginationViewType: PaginationViewType.listView,
      pageIndex: 1,
      pageFetch: _leadListCubit.getLeads,
      onError: (dynamic error) => Center(
        child: DataNotFound(),
      ),
      onEmpty: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/ic_no_task.png',
              width: Dimens.imageWidth_150, height: Dimens.imageHeight_200),
            DataNotFound(error: 'no_task'.tr),
          ],
        ),
      ),
      bottomLoader: const SizedBox(),
      initialLoader: buildShimmerWidgets(),
    );
  }

  _onCloneOrDeleteTap(
      LeadOption leadOption, int index, Lead lead, String listViewId) {
    if (leadOption == LeadOption.Duplicate) {
      Future<ConfirmAction?> cloneTap = Helper.asyncConfirmDialog(
          context, 'are_you_sure'.tr,
          heading: '', textOKBtn: 'yes'.tr, textCancelBtn: 'no'.tr);
      cloneTap.then((value) {
        if (value == ConfirmAction.OK) {
          _leadListCubit.cloneLead(lead.getLeadID(), listViewId);
        }
      });
    } else if (leadOption == LeadOption.Delete) {
      Future<ConfirmAction?> deleteTap = Helper.asyncConfirmDialog(
          context, 'are_you_sure'.tr,
          heading: '', textOKBtn: 'yes'.tr, textCancelBtn: 'no'.tr);
      deleteTap.then((value) {
        if (value == ConfirmAction.OK) {
          _leadListCubit.deleteLead(lead.getLeadID(), listViewId);
        }
      });
    }
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
        if (columns.uid != null &&
            _leadListCubit
                    .getLeadRemoteRequest()
                    ?.leadDataSourceParams
                    .executionID !=
                null) {
          showCallBridgeBottomSheet(
              context,
              columns.uid!,
              lead.getLeadID(),
              _leadListCubit
                  .getLeadRemoteRequest()!
                  .leadDataSourceParams
                  .executionID!);
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

  LinkedHashMap<String?, List<Columns>?>? getGroupedActions(
      List<Columns>? moreActions) {
    if (moreActions == null) return null;

    LinkedHashMap<String?, List<Columns>?> groupedActions =
        LinkedHashMap<String?, List<Columns>?>();
    for (Columns column in moreActions) {
      String? action = column.action;
      if (column.uid == null) continue;

      List<Columns>? actionColumns = groupedActions[action];
      actionColumns ??= <Columns>[];
      actionColumns.add(column);
      groupedActions[action] = actionColumns;
    }
    return groupedActions;
  }

  void _onLeadTap(int index, Lead lead) {
    LeadRemoteRequest? leadRemoteRequest =
        _leadListCubit.getLeadRemoteRequest();
    if (leadRemoteRequest != null &&
        _leadListCubit.getListViewConfigData() != null &&
        _leadListCubit.getListViewConfigData()?.statusAliases != null) {
      leadRemoteRequest.leadDataSourceParams.currentStatus = lead.getStatus();
      LeadScreensData leadScreensData = LeadScreensData(
          widget._execution,
          lead,
          '',
          ScreenViewType.updateLead,
          leadRemoteRequest.leadDataSourceParams,
          _leadListCubit.getListViewConfigData()!.statusAliases!,
          index,
          cleverTapEvent);
      _openLeadScreenWidget(leadScreensData);
    }
  }

  _openLeadScreenWidget(LeadScreensData leadScreensData) async {
    Map? map = await MRouter.pushNamedWithResult(
        context, LeadScreensWidget(leadScreensData), MRouter.leadScreensWidget);
    bool? doRefresh = map?[Constants.doRefresh];
    if (doRefresh != null && doRefresh) {
      _leadListCubit.fetchConfigAndAnalysis(widget._execution);
    }
  }

  Widget buildShimmerWidgets() {
    return ListView(
      padding:
          const EdgeInsets.fromLTRB(Dimens.padding_16, 0, Dimens.padding_16, 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        buildHomeShimmerWidget(),
        buildSummaryBlockShimmerWidget(),
        buildLeadTileShimmerWidget(),
        buildLeadTileShimmerWidget(),
        buildLeadTileShimmerWidget(),
        buildLeadTileShimmerWidget(),
        buildLeadTileShimmerWidget(),
        buildLeadTileShimmerWidget(),
      ],
    );
  }

  Widget buildHomeShimmerWidget() {
    return const Row(
      children: [
        ShimmerWidget.rectangular(
            width: Dimens.padding_24, height: Dimens.padding_24),
        SizedBox(width: Dimens.margin_16),
        ShimmerWidget.rectangular(
            width: Dimens.padding_60, height: Dimens.font_24),
      ],
    );
  }

  Widget buildSummaryBlockShimmerWidget() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: Dimens.margin_16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ShimmerWidget.rectangular(
                      width: Dimens.padding_150, height: Dimens.font_24),
                  SizedBox(width: Dimens.margin_16),
                  ShimmerWidget.rectangular(
                      width: Dimens.padding_60, height: Dimens.font_24),
                  SizedBox(width: Dimens.margin_16),
                  Expanded(
                      child: ShimmerWidget.rectangular(height: Dimens.font_24)),
                ],
              ),
              SizedBox(height: Dimens.margin_16),
              Row(
                children: [
                  ShimmerWidget.rectangular(
                      width: Dimens.padding_60, height: Dimens.font_24),
                  SizedBox(width: Dimens.margin_16),
                  ShimmerWidget.rectangular(
                      width: Dimens.padding_150, height: Dimens.font_24),
                  SizedBox(width: Dimens.margin_16),
                  Expanded(
                      child: ShimmerWidget.rectangular(height: Dimens.font_24)),
                ],
              ),
              SizedBox(height: Dimens.margin_16),
              Row(
                children: [
                  ShimmerWidget.rectangular(
                      width: Dimens.padding_80, height: Dimens.font_24),
                  SizedBox(width: Dimens.margin_16),
                  ShimmerWidget.rectangular(
                      width: Dimens.padding_60, height: Dimens.font_24),
                  SizedBox(width: Dimens.margin_16),
                  Expanded(
                      child: ShimmerWidget.rectangular(height: Dimens.font_24)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLeadTileShimmerWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radius_8),
        ),
        child: Container(
          padding: const EdgeInsets.all(Dimens.padding_16),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerWidget.rectangular(height: Dimens.padding_24),
              SizedBox(height: Dimens.margin_16),
              Row(
                children: [
                  ShimmerWidget.rectangular(
                      width: Dimens.padding_80, height: Dimens.font_16),
                  SizedBox(width: Dimens.margin_16),
                  Expanded(
                      child: ShimmerWidget.rectangular(height: Dimens.font_16)),
                ],
              ),
              SizedBox(height: Dimens.margin_16),
              Row(
                children: [
                  ShimmerWidget.rectangular(
                      width: Dimens.padding_80, height: Dimens.font_16),
                  SizedBox(width: Dimens.margin_16),
                  Expanded(
                      child: ShimmerWidget.rectangular(height: Dimens.font_16)),
                ],
              ),
              SizedBox(height: Dimens.margin_16),
              Row(
                children: [
                  ShimmerWidget.rectangular(
                      width: Dimens.padding_80, height: Dimens.font_16),
                  SizedBox(width: Dimens.margin_16),
                  Expanded(
                      child: ShimmerWidget.rectangular(height: Dimens.font_16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryBlockHeaderWidget(List<SummaryBlock>? summaryBlockList) {
    return StreamBuilder<LeadListHeaderData>(
        stream: _leadListCubit.leadListHeaderDataStream,
        builder: (context, leadListHeaderDataStream) {
          if (leadListHeaderDataStream.hasData) {
            List<Widget> blockTabs = [];
            List<Widget> selectedBlockTabs = [];
            selectedBlockTabs.add(buildHomeIcon());
            String? lastSelectedBlockId;
            LeadListHeaderData leadListHeaderData =
                _leadListCubit.getLeadListHeaderData();
            if (leadListHeaderData.selectedBlockList.isNotEmpty) {
              lastSelectedBlockId = leadListHeaderData
                  .selectedBlockList[
                      leadListHeaderData.selectedBlockList.length - 1]
                  .id;
            }
            if (!summaryBlockList.isNullOrEmpty) {
              for (SummaryBlock block in summaryBlockList!) {
                if (lastSelectedBlockId == null) {
                  for (SummaryBlock block1 in summaryBlockList) {
                    if (block1.parentBlockId == null) {
                      lastSelectedBlockId = block1.id;
                      break;
                    }
                  }
                }
                bool isBlockSelected = false;
                for (SummaryBlock selectedBlock
                    in leadListHeaderData.selectedBlockList) {
                  if (selectedBlock.id == block.id) {
                    isBlockSelected = true;
                    break;
                  }
                }
                if (isBlockSelected) {
                  continue;
                }

                if (block.parentBlockId == lastSelectedBlockId) {
                  blockTabs.add(MyInkWell(
                      onTap: () {
                        List<SummaryBlock> tempSummaryBlockList =
                            leadListHeaderData.selectedBlockList;
                        for (int i = 0;
                            i < leadListHeaderData.selectedBlockList.length;
                            i++) {
                          if (leadListHeaderData.selectedBlockList[i].id ==
                              block.id) {
                            tempSummaryBlockList.removeAt(i);
                            break;
                          }
                        }
                        leadListHeaderData.selectedBlockList =
                            tempSummaryBlockList;
                        leadListHeaderData.selectedBlockList.add(block);
                        _leadListCubit
                            .changeLeadListHeaderData(leadListHeaderData);
                        leadRemoteRequest.blockID = block.id;
                        _leadListCubit
                            .changeLeadRemoteRequest(leadRemoteRequest);
                        _paginationKey.currentState?.search(_searchQuery.text);
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(
                            Dimens.padding_16,
                            Dimens.padding_8,
                            Dimens.padding_16,
                            Dimens.padding_8),
                        margin: const EdgeInsets.fromLTRB(0, Dimens.margin_8,
                            Dimens.margin_16, Dimens.margin_8),
                        decoration: BoxDecoration(
                          color: context.theme.textFieldBackgroundColor,
                          borderRadius: const BorderRadius.all(
                              Radius.circular(Dimens.radius_8)),
                        ),
                        child: Text('${block.name} (${block.leadCount})',
                            style: Get.textTheme.bodyText2SemiBold),
                      )));
                }
              }
            }

            for (SummaryBlock block in leadListHeaderData.selectedBlockList) {
              selectedBlockTabs.add(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_right_outlined,
                    size: Dimens.iconSize_20,
                    color: Get.theme.iconColorNormal,
                  ),
                  const SizedBox(width: Dimens.padding_4),
                  Text('${block.name} (${block.leadCount})',
                      style: Get.textTheme.bodyText2SemiBold),
                ],
              ));
            }

            Widget backButton = const SizedBox();
            if (leadListHeaderData.selectedBlockList.isNotEmpty) {
              backButton = buildBackButton();
            }
            return AnimatedContainer(
              decoration: const BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimens.radius_16),
                  topRight: Radius.circular(Dimens.radius_16),
                ),
              ),
              padding: const EdgeInsets.all(Dimens.padding_16),
              duration: const Duration(milliseconds: Constants.duration_500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    children: selectedBlockTabs,
                  ),
                  const SizedBox(height: Dimens.padding_8),
                  HDivider(dividerColor: AppColors.backgroundGrey400),
                  const SizedBox(height: Dimens.padding_8),
                  Wrap(
                    children: blockTabs,
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildHomeIcon() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.home,
          size: Dimens.iconSize_16,
          color: Get.theme.iconColorNormal,
        ),
        const SizedBox(width: Dimens.padding_8),
        Text('home'.tr, style: Get.textTheme.bodyText2),
      ],
    );
  }

  Widget buildBackButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, Dimens.margin_16, 0),
      child: CustomTextButton(
        width: Dimens.btnWidth_64,
        height: Dimens.btnHeight_32,
        text: 'back'.tr,
        fontSize: Dimens.font_12,
        textColor: AppColors.black,
        backgroundColor: AppColors.transparent,
        borderColor: AppColors.backgroundGrey600,
        onPressed: () {
          LeadListHeaderData leadListHeaderData =
              _leadListCubit.getLeadListHeaderData();
          leadListHeaderData.selectedBlockList
              .removeAt(leadListHeaderData.selectedBlockList.length - 1);
          _leadListCubit.changeLeadListHeaderData(leadListHeaderData);
          leadRemoteRequest.blockID = _leadListCubit
              .getSummaryBlock(leadListHeaderData.selectedBlockList)
              ?.id;
          _leadListCubit.changeLeadRemoteRequest(leadRemoteRequest);
          _paginationKey.currentState?.search(_searchQuery.text);
        },
      ),
    );
  }
}
