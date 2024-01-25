import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/location_helper.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_screen_response.dart';
import 'package:awign/workforce/execution_in_house/data/repository/lead/lead_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/lead_screen/screen_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/helper/lead_list_header_data.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_screens/helper/lead_screen_rows_provider.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_screens/helper/lead_screens_data.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../../aw_questions/data/model/row/screen_row.dart';

part 'lead_screens_state.dart';

class LeadScreensCubit extends Cubit<LeadScreensState> {
  final LeadRemoteRepository _leadRemoteRepository;
  final ScreenRemoteRepository _screenRemoteRepository;
  final _awQuestionsCubit = sl<AwQuestionsCubit>();

  int currentTabPosition = 0;
  Map<String, Screen> screenMap = {};
  Screen? firstScreen;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _leadScreenResponse = BehaviorSubject<LeadScreenResponse>();

  Stream<LeadScreenResponse> get leadScreenResponseStream =>
      _leadScreenResponse.stream;

  final _lead = BehaviorSubject<Lead>();

  Stream<Lead> get leadStream => _lead.stream;

  final _tabList = BehaviorSubject<List<String>>.seeded([]);

  Stream<List<String>?> get tabListStream => _tabList.stream;

  final _leadRemoteRequest = BehaviorSubject<LeadRemoteRequest>();

  Stream<LeadRemoteRequest> get leadRemoteRequestStream =>
      _leadRemoteRequest.stream;

  Function(LeadRemoteRequest) get changeLeadRemoteRequest =>
      _leadRemoteRequest.sink.add;

  final _leadListHeaderData =
      BehaviorSubject<LeadListHeaderData>.seeded(LeadListHeaderData());

  Stream<LeadListHeaderData> get leadListHeaderDataStream =>
      _leadListHeaderData.stream;

  Function(LeadListHeaderData) get changeLeadListHeaderData =>
      _leadListHeaderData.sink.add;

  final _isSearchBarVisible = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isSearchBarVisibleStream => _isSearchBarVisible.stream;

  Function(bool) get changeIsSearchBarVisible => _isSearchBarVisible.sink.add;

  final _endActionList = BehaviorSubject<List<EndAction>?>();

  Stream<List<EndAction>?> get endActionListStream => _endActionList.stream;

  final _isShowLocationEnableDialog = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isShowLocationEnableDialogStream => _isShowLocationEnableDialog.stream;
  Function(bool) get changeIsShowLocationEnableDialog => _isShowLocationEnableDialog.sink.add;

  LeadScreensData? _leadScreensData;

  LeadScreensCubit(this._leadRemoteRepository, this._screenRemoteRepository)
      : super(LeadScreensInitial()) {
    Rx.zip2(
      leadScreenResponseStream,
      leadStream,
      (LeadScreenResponse leadScreenResponse, Lead lead) =>
          Tuple2(leadScreenResponse, lead),
    ).listen((tuple2) async {
      if (tuple2.item1.screen != null &&
          (_leadScreensData != null &&
              (_leadScreensData?.screenViewType == ScreenViewType.addLead ||
                  _leadScreensData?.screenViewType ==
                      ScreenViewType.sampleLead ||
                  tuple2.item1.screen?.screenType != ScreenType.end))) {
        currentTabPosition++;
        screenMap['${Constants.screen}$currentTabPosition'] =
            tuple2.item1.screen!;
      }
      addNewTab();
      if (tuple2.item1.screen?.endActions != null &&
          tuple2.item1.screen!.endActions!.isNotEmpty &&
          !_endActionList.isClosed) {
        _endActionList.sink.add(tuple2.item1.screen?.endActions);
      } else {
        _endActionList.sink.add(null);
      }
      Tuple2<List<ScreenRow>, bool> screenRowsTuple = LeadScreenRowsProvider.getScreenRows(
          tuple2.item1, tuple2.item2, _leadScreensData!.execution);
      _awQuestionsCubit.checkDBAndChangeScreenRowList(screenRowsTuple.item1);
      changeUIStatus(UIStatus(isOnScreenLoading: false));
      if(screenRowsTuple.item2) {
        bool isLocationEnabled = await LocationHelper.checkAndAskLocationPermission();
        if(!isLocationEnabled) {
          changeIsShowLocationEnableDialog(true);
        }
      }
    }).onError((e) {
      changeUIStatus(
          UIStatus(isOnScreenLoading: false, failedWithoutAlertMessage: e));
    });
  }

  @override
  Future<void> close() {
    _uiStatus.close();
    _leadScreenResponse.close();
    _lead.close();
    _tabList.close();
    _endActionList.close();
    return super.close();
  }

  LeadListHeaderData getLeadListHeaderData() {
    return _leadListHeaderData.value;
  }

  void fetchNextScreen(
      int userID, int position, LeadScreensData leadScreensData) async {
    _leadScreensData = leadScreensData;
    changeUIStatus(UIStatus(isOnScreenLoading: true));
    currentTabPosition = position;
    if (screenMap.isEmpty || position == 0) {
      if (position == 0) {
        getStartScreen(userID, leadScreensData);
      }
    } else {
      String key = '${Constants.screen}$currentTabPosition';
      Screen? lScreen = screenMap[key];
      if (lScreen == null) {
        return;
      }
      getNextScreen(userID, leadScreensData, lScreen.id ?? '');
    }
    getLead(leadScreensData);
  }

  void getStartScreen(int userID, LeadScreensData leadScreensData) async {
    try {
      LeadScreenResponse leadScreenResponse = await _screenRemoteRepository
          .getStartScreen(userID, leadScreensData.leadDataSourceParams);
      if (!_leadScreenResponse.isClosed) {
        _leadScreenResponse.sink.add(leadScreenResponse);
      } else {
        _leadScreenResponse.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_leadScreenResponse.isClosed) {
        _leadScreenResponse.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_leadScreenResponse.isClosed) {
        _leadScreenResponse.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getStartScreen : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_leadScreenResponse.isClosed) {
        _leadScreenResponse.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void getNextScreen(
      int userID, LeadScreensData leadScreensData, String screenID) async {
    try {
      LeadScreenResponse leadScreenResponse =
          await _screenRemoteRepository.getNextScreen(
              userID,
              leadScreensData.leadDataSourceParams.executionID ?? '',
              leadScreensData.lead.getLeadID() ?? '',
              screenID);
      if (!_leadScreenResponse.isClosed) {
        _leadScreenResponse.sink.add(leadScreenResponse);
      } else {
        _leadScreenResponse.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_leadScreenResponse.isClosed) {
        _leadScreenResponse.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_leadScreenResponse.isClosed) {
        _leadScreenResponse.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getNextScreen : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_leadScreenResponse.isClosed) {
        _leadScreenResponse.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void getLead(LeadScreensData leadScreensData) async {
    try {
      Lead lead = await _leadRemoteRepository.getLead(
          leadScreensData.leadDataSourceParams.executionID ?? '',
          leadScreensData.leadDataSourceParams.projectRoleUID ?? '',
          leadScreensData.lead.getLeadID());
      if (!_lead.isClosed) {
        _lead.sink.add(lead);
      } else {
        _lead.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_lead.isClosed) {
        _lead.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_lead.isClosed) {
        _lead.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getLead : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_lead.isClosed) {
        _lead.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  String getScreenName(Screen screen) {
    String? screenName = (screen.name != null) ? screen.name : screen.uID;
    if (screenName != null) {
      return screenName.replaceAll('_', ' ').toCapitalized();
    } else {
      int newTabIndex = _tabList.value.length + 1;
      return '${Constants.screen}$newTabIndex';
    }
  }

  void addNewTab() {
    if (!_leadScreenResponse.isClosed &&
        _leadScreenResponse.hasValue &&
        !_tabList.isClosed) {
      LeadScreenResponse leadScreenResponse = _leadScreenResponse.value;
      if (leadScreenResponse.screen != null) {
        List<String> tabList = _tabList.value;
        if (!tabList.contains(getScreenName(leadScreenResponse.screen!))) {
          tabList.add(getScreenName(leadScreenResponse.screen!));
        }
        _tabList.sink.add(tabList);
      }
    }
  }

  bool hasNextScreen() {
    bool hasNext = false;
    if (!_leadScreenResponse.isClosed && _leadScreenResponse.hasValue) {
      LeadScreenResponse leadScreenResponse = _leadScreenResponse.value;
      if (leadScreenResponse.screen?.next == null) {
        hasNext = false;
      } else if (leadScreenResponse.screen?.next?.hasNextScreen ?? false) {
        hasNext = true;
      }
    }
    return hasNext;
  }

  bool isEndScreen() {
    bool isEnd = false;
    if (!_leadScreenResponse.isClosed && _leadScreenResponse.hasValue) {
      LeadScreenResponse leadScreenResponse = _leadScreenResponse.value;
      if (leadScreenResponse.screen?.screenType == ScreenType.end) {
        isEnd = true;
      }
    }
    return isEnd;
  }

  int getNextTabPosition() {
    if (!_tabList.isClosed && _tabList.hasValue) {
      return _tabList.value.length;
    } else {
      return 0;
    }
  }

  void updateLead(LeadScreensData leadScreensData) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      Lead lead = await _leadRemoteRepository.updateLead(
          leadScreensData.leadDataSourceParams.executionID ?? '',
          getCurrentScreen()?.id ?? '',
          leadScreensData.lead.getLeadID(),
          _awQuestionsCubit.screenRowListValue);
      changeUIStatus(UIStatus(isDialogLoading: false, event: Event.updated));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('updateLead : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  Screen? getCurrentScreen() {
    if (screenMap.isNotEmpty) {
      String key = '${Constants.screen}$currentTabPosition';
      return screenMap[key];
    } else if (!_leadScreenResponse.isClosed &&
        _leadScreenResponse.hasValue &&
        _leadScreenResponse.value.screen != null) {
      return _leadScreenResponse.value.screen;
    } else {
      return null;
    }
  }

  void goToNextScreen(int userID, LeadScreensData leadScreensData) {
    if (hasNextScreen()) {
      fetchNextScreen(userID, getNextTabPosition(), leadScreensData);
    } else {
      MRouter.pop(null);
    }
  }

  void updateLeadStatus(
      LeadScreensData leadScreensData, EndAction endAction) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      ApiResponse apiResponse = await _leadRemoteRepository.updateLeadStatus(
          leadScreensData.leadDataSourceParams,
          getCurrentScreen()?.id ?? '',
          leadScreensData.lead.getLeadID(),
          endAction.status ?? '');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          successWithoutAlertMessage: apiResponse.message ?? '',
          event: Event.success));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('updateLeadStatus : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
