import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/questions_validation_error.dart';
import 'package:awign/workforce/aw_questions/data/model/render_type.dart';
import 'package:awign/workforce/aw_questions/data/model/result.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/aw_questions/widget/tile/question_shimmer_tile.dart';
import 'package:awign/workforce/aw_questions/widget/tile/question_tile.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/circle_avatar/custom_circle_avatar.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_view_config_entity.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_screens/cubit/lead_screens_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_screens/helper/lead_screens_data.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_screens/widget/tile/end_action_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_actions.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';
import '../../../../core/data/model/widget_result.dart';
import '../../../../core/widget/bottom_sheet/enable_location_service_bottom_sheet/enable_location_service_botom_sheet.dart';

class LeadScreensWidget extends StatefulWidget {
  final LeadScreensData _leadScreensData;

  const LeadScreensWidget(this._leadScreensData, {Key? key}) : super(key: key);

  @override
  State<LeadScreensWidget> createState() => _LeadScreensWidgetState();
}

class _LeadScreensWidgetState extends State<LeadScreensWidget>
    with TickerProviderStateMixin {
  final LeadScreensCubit _leadScreensCubit = sl<LeadScreensCubit>();
  final _awQuestionsCubit = sl<AwQuestionsCubit>();
  UserData? _currentUser;
  bool isSkipSaasOrgID = false;
  List<Widget> tabs = [];
  int tabsLength = 1;
  Map<String, List<String>> tabStatus = {};
  String currentStatus = '';
  Map<String, ListViews> listViewConfigMap = {};
  Map<String, int> statsCountMap = {};
  late LeadRemoteRequest leadRemoteRequest;
  TabController? _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    tabs.add(const Tab(text: ''));
    _tabController = TabController(length: tabsLength, vsync: this);
    subscribeUIStatus();
    getCurrentUser();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (spUtil!.getSaasOrgID().isNullOrEmpty) {
      isSkipSaasOrgID = true;
    }
    _leadScreensCubit.fetchNextScreen(
        _currentUser!.id ?? -1, 0, widget._leadScreensData);
    if (widget._leadScreensData.cleverTapEvent != null) {
      Map<String, dynamic> properties = await getEventProperty();
      ClevertapData clevertapData = ClevertapData(
          eventName: ClevertapHelper.singleLeadViewApened,
          properties: properties);
      CaptureEventHelper.captureEvent(clevertapData: clevertapData);
    }
  }

  void subscribeUIStatus() {
    _leadScreensCubit.uiStatus.listen(
      (uiStatus) async {
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
          case Event.updated:
            _leadScreensCubit.goToNextScreen(
                _currentUser?.id ?? -1, widget._leadScreensData);
            break;
          case Event.success:
            LoggingData loggingData = LoggingData(
                event: LoggingEvents.firstLeadSubmitted,
                action: LoggingActions.clicked,
                pageName: LoggingPageNames.dashboard,
                otherProperty: getLoggingEvents());
            CaptureEventHelper.captureEvent(loggingData: loggingData);
            MRouter.popNamedWithResult(
                MRouter.leadListWidget, Constants.doRefresh, true);
            break;
        }
      },
    );
    _leadScreensCubit.tabListStream.listen((tabList) {
      if (tabList != null) {
        setState(() {
          tabs.clear();
          for (String name in tabList) {
            tabs.add(Tab(text: name));
          }
          tabsLength = tabs.length;
          int initialIndex = _leadScreensCubit.currentTabPosition - 1;

          if (initialIndex < 0 || initialIndex >= tabsLength) {
            initialIndex = 0;
          }

          _tabController = TabController(
              length: tabsLength,
              initialIndex: initialIndex,
              vsync: this);
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          _scrollController.animateTo(
              _scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn);
        });
      }
    });
    _leadScreensCubit.isShowLocationEnableDialogStream.listen((isShowLocationEnableDialog) {
      if(isShowLocationEnableDialog) {
        showEnableLocationServiceBottomSheet(context, () {
          MRouter.pop(null);
        });
      }
    });
  }

  void onTabSelected(int index) async {
    ConfirmAction? result = await Helper.asyncConfirmDialog(
        context, 'are_you_sure_you_want_to_change_screen'.tr,
        heading: 'change_screen'.tr,
        textOKBtn: 'yes'.tr,
        textCancelBtn: 'cancel'.tr);
    if (result == ConfirmAction.OK) {
      _leadScreensCubit.fetchNextScreen(
          _currentUser!.id ?? -1, index, widget._leadScreensData);
    } else {
      setState(() {
        _tabController = TabController(
            length: tabsLength,
            initialIndex: _leadScreensCubit.currentTabPosition - 1,
            vsync: this);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => onBackTap(),
      child: ScreenTypeLayout(
        mobile: buildMobileUI(),
        desktop: const DesktopComingSoonWidget(),
      ),
    );
  }

  bool onBackTap() {
    Future<ConfirmAction?> yesTap = Helper.asyncConfirmDialog(
        context, 'any_unsaved_data'.tr,
        heading: 'close_screen'.tr, textOKBtn: 'yes'.tr, textCancelBtn: 'cancel'.tr);
    yesTap.then((value) {
      if (value == ConfirmAction.OK) {
        MRouter.popNamedWithResult(
            MRouter.leadListWidget, Constants.doRefresh, false);
      }
    });
    return true;
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
                  controller: _tabController,
                  onTap: (index) {
                    onTabSelected(index);
                  },
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
    );
  }

  Widget buildAppBarWidgets() {
    String title = '';
    if (widget._leadScreensData.screenViewType == ScreenViewType.addLead) {
      title = 'add_lead'.tr;
    } else if (widget._leadScreensData.screenViewType ==
        ScreenViewType.sampleLead) {
      title = 'sample_lead'.tr;
    } else if (widget._leadScreensData.screenViewType ==
        ScreenViewType.duplicateLead) {
      title = 'duplicate_lead'.tr;
    } else {
      title = 'update_lead'.tr;
    }
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              buildLeadingIcon(),
              Text(
                title,
                style: Get.context?.textTheme.headline6SemiBold
                    ?.copyWith(color: AppColors.backgroundWhite),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLeadingIcon() {
    if (widget._leadScreensData.execution.projectIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(right: Dimens.padding_16),
        child: CustomCircleAvatar(
            url: widget._leadScreensData.execution.projectIcon,
            radius: Dimens.radius_16),
      );
    } else {
      return const SizedBox();
    }
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
        child: StreamBuilder<UIStatus>(
            stream: _leadScreensCubit.uiStatus,
            builder: (context, uiStatus) {
              if (uiStatus.hasData &&
                  !(uiStatus.data?.isOnScreenLoading ?? true)) {
                return Column(
                  children: [
                    buildScreenQuestionList(),
                    if(_leadScreensCubit.isEndScreen())... [
                      buildEndActionList()
                    ],
                    buildSubmitButton(),
                    const SizedBox(height: Dimens.padding_16),
                  ],
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0, Dimens.padding_16, 0, Dimens.padding_16),
                  child: buildShimmerWidgets(),
                );
              }
            }),
      ),
    );
  }

  Widget buildScreenQuestionList() {
    return StreamBuilder<List<ScreenRow>>(
      stream: _awQuestionsCubit.screenRowListStream,
      builder: (context, screenRowListStream) {
        if (screenRowListStream.hasData &&
            screenRowListStream.data!.isNotEmpty) {
          return Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, 0, Dimens.padding_16, 0),
              itemCount: screenRowListStream.data?.length,
              itemBuilder: (_, i) {
                ScreenRow screenRow = screenRowListStream.data![i];
                return QuestionTile(
                  screenRow: screenRow,
                  renderType: RenderType.DEFAULT,
                  onAnswerUpdate: _onAnswerUpdate,
                  key: Key(screenRowListStream.data![i].question?.uuid ?? ''),
                );
              },
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  _onAnswerUpdate(Question question, {WidgetResult? widgetResult}) {
    _awQuestionsCubit.updateScreenRowList(question);
  }

  Widget buildEndActionList() {
    return StreamBuilder<List<EndAction>?>(
      stream: _leadScreensCubit.endActionListStream,
      builder: (context, endActionListStream) {
        if (endActionListStream.hasData && endActionListStream.data != null) {
          return Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
              itemCount: endActionListStream.data?.length,
              itemBuilder: (_, i) {
                EndAction endAction = endActionListStream.data![i];
                return EndActionTile(
                  index: i,
                  endAction: endAction,
                  onEndActionTap: _onEndActionTap,
                );
              },
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  _onEndActionTap(int index, EndAction endAction) {
    _leadScreensCubit.updateLeadStatus(widget._leadScreensData, endAction);
  }

  Widget buildSubmitButton() {
    String text = 'save_and_exit'.tr;
    if (_leadScreensCubit.hasNextScreen()) {
      text = 'next'.tr;
    }
    if (_leadScreensCubit.isEndScreen()) {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_16,
            Dimens.margin_16, Dimens.margin_16),
        child: RaisedRectButton(
          text: text,
          onPressed: () {
            submitAnswer();
          },
        ),
      );
    }
  }

  void submitAnswer() {
    Helper.hideKeyBoard(context);
    Result result = _awQuestionsCubit.validateRequiredAnswers();
    if (result.success) {
      _leadScreensCubit.updateLead(widget._leadScreensData);
    } else {
      Helper.showErrorToast(
          (result.error as QuestionsValidationError).error ?? '');
    }
  }

  Widget buildShimmerWidgets() {
    return ListView(
      padding:
          const EdgeInsets.fromLTRB(Dimens.padding_16, 0, Dimens.padding_16, 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        QuestionShimmerTile(),
        QuestionShimmerTile(),
        QuestionShimmerTile(),
        QuestionShimmerTile(),
        QuestionShimmerTile(),
        QuestionShimmerTile(),
        QuestionShimmerTile(),
      ],
    );
  }

  Future<Map<String, dynamic>> getEventProperty() async {
    Map<String, dynamic> eventProperty = {};
    eventProperty[CleverTapConstant.availability] =
        widget._leadScreensData.execution.strAvailability;
    eventProperty[CleverTapConstant.projectName] =
        widget._leadScreensData.execution.projectName;
    eventProperty[CleverTapConstant.projectId] =
        widget._leadScreensData.execution.projectId;
    eventProperty[CleverTapConstant.roleName] = widget
        ._leadScreensData.execution.selectedProjectRole
        ?.replaceAll('_', ' ');
    if (widget._leadScreensData.cleverTapEvent != null) {
      eventProperty.addAll(widget._leadScreensData.cleverTapEvent!);
    }
    return eventProperty;
  }

  Map<String, String> getProjectProperty() {
    Map<String, String> eventProperty = {};
    eventProperty[CleverTapConstant.availability] =
        widget._leadScreensData.execution.strAvailability ?? '';
    eventProperty[CleverTapConstant.projectName] =
        widget._leadScreensData.execution.projectName ?? '';
    eventProperty[CleverTapConstant.projectId] =
        widget._leadScreensData.execution.projectId ?? '';
    eventProperty[CleverTapConstant.roleName] = widget
            ._leadScreensData.execution.selectedProjectRole
            ?.replaceAll('_', ' ') ??
        '';
    return eventProperty;
  }

  Map<String, String> getLoggingEvents() {
    Map<String, String> eventProperty = {};
    eventProperty[CleverTapConstant.availability] =
        widget._leadScreensData.execution.strAvailability ?? '';
    eventProperty[CleverTapConstant.projectId] =
        widget._leadScreensData.execution.projectId ?? '';
    eventProperty[CleverTapConstant.roleName] = widget
            ._leadScreensData.execution.selectedProjectRole
            ?.replaceAll('_', ' ') ??
        '';
    return eventProperty;
  }
}
