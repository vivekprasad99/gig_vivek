import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_view_config_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/summary_block_response.dart';
import 'package:awign/workforce/execution_in_house/data/model/summary_view_response.dart';
import 'package:awign/workforce/execution_in_house/data/repository/dashboaard_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/execution_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/lead/lead_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/data/repository/view_config/view_config_remote_repository.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/helper/lead_list_header_data.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'lead_list_state.dart';

class LeadListCubit extends Cubit<LeadListState> {
  final DashboardRemoteRepository _dashboardRemoteRepository;
  final ViewConfigRemoteRepository _viewConfigRemoteRepository;
  final LeadRemoteRepository _leadRemoteRepository;
  final ExecutionRemoteRepository _executionRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _listViewConfigData = BehaviorSubject<ListViewConfigData>();

  Stream<ListViewConfigData> get listViewConfigDataStream =>
      _listViewConfigData.stream;

  final _leadsAnalysis = BehaviorSubject<LeadsAnalysis>();

  Stream<LeadsAnalysis> get leadsAnalysisStream => _leadsAnalysis.stream;

  final _listViewConfigAndAnalyseData =
      BehaviorSubject<Tuple2<ListViewConfigData, LeadsAnalysis>>();

  Stream<Tuple2<ListViewConfigData, LeadsAnalysis>>
      get listViewConfigAndAnalyseDataStream =>
          _listViewConfigAndAnalyseData.stream;

  final _summaryBlockResponse = BehaviorSubject<SummaryBlockResponse?>();

  Stream<SummaryBlockResponse?> get summaryBlockResponseStream =>
      _summaryBlockResponse.stream;

  SummaryBlockResponse? get summaryBlockResponseValue => _summaryBlockResponse.valueOrNull;

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

  final _leadCount = BehaviorSubject<int?>();

  Stream<int?> get leadCountStream => _leadCount.stream;

  Function(int?) get changeLeadCount => _leadCount.sink.add;

  LeadListCubit(
      this._dashboardRemoteRepository,
      this._viewConfigRemoteRepository,
      this._leadRemoteRepository,
      this._executionRemoteRepository)
      : super(LeadListInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _listViewConfigData.close();
    _leadsAnalysis.close();
    _listViewConfigAndAnalyseData.close();
    _summaryBlockResponse.close();
    _leadCount.close();
    return super.close();
  }

  LeadListHeaderData getLeadListHeaderData() {
    return _leadListHeaderData.value;
  }

  void fetchConfigAndAnalysis(Execution execution) async {
    Rx.combineLatest2(
      listViewConfigDataStream,
      leadsAnalysisStream,
      (ListViewConfigData listViewConfigData, LeadsAnalysis leadsAnalysis) {
        Map<String, int> analyzeCounts = {};
        if (!listViewConfigData.listViews.isNullOrEmpty) {
          for (ListViews listView in listViewConfigData.listViews!) {
            analyzeCounts[listView.workflowStatus!] =
                leadsAnalysis.status?[listView.workflowStatus] ?? 0;
          }
        }
        listViewConfigData.analyzeCounts = analyzeCounts;
        return Tuple2(listViewConfigData, leadsAnalysis);
      },
    ).listen((tuple2) {
      if (!_listViewConfigAndAnalyseData.isClosed) {
        _listViewConfigAndAnalyseData.sink.add(tuple2);
      }
    }).onError((e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e));
    });
    fetchListView(execution);
    fetchLeadAnalyze(execution);
  }

  void fetchListView(Execution execution) async {
    try {
      ListViewConfigData listViewConfigData =
          await _viewConfigRemoteRepository.fetchListView(
              execution.id ?? '',
              execution.selectedProjectRole
                      ?.toLowerCase()
                      .replaceAll(' ', '_') ??
                  '');
      if (!_listViewConfigData.isClosed) {
        _listViewConfigData.sink.add(listViewConfigData);
      } else {
        _listViewConfigData.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_listViewConfigData.isClosed) {
        _listViewConfigData.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_listViewConfigData.isClosed) {
        _listViewConfigData.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('fetchListView : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_listViewConfigData.isClosed) {
        _listViewConfigData.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  ListViewConfigData? getListViewConfigData() {
    return _listViewConfigData.valueOrNull;
  }

  void fetchLeadAnalyze(Execution execution) async {
    try {
      LeadsAnalysis leadsAnalysis =
          await _leadRemoteRepository.fetchLeadAnalyze(
              execution.id ?? '',
              execution.selectedProjectRole
                      ?.toLowerCase()
                      .replaceAll(' ', '_') ??
                  '');
      if (!_leadsAnalysis.isClosed) {
        _leadsAnalysis.sink.add(leadsAnalysis);
      } else {
        _leadsAnalysis.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_leadsAnalysis.isClosed) {
        _leadsAnalysis.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_leadsAnalysis.isClosed) {
        _leadsAnalysis.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('fetchLeadAnalyze : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_leadsAnalysis.isClosed) {
        _leadsAnalysis.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void fetchSummaryViews(
      String executionId, String projectRoleUid, String listViewId) async {
    try {
      if (!_summaryBlockResponse.isClosed) {
        _summaryBlockResponse.sink.add(null);
      }
      SummaryViewResponse summaryViewResponse = await _executionRemoteRepository
          .fetchSummaryView(executionId, projectRoleUid);
      if (!summaryViewResponse.summaryViews.isNullOrEmpty &&
          summaryViewResponse.summaryViews![0].id != null) {
        fetchLeadBlock(executionId, projectRoleUid, listViewId,
            summaryViewResponse.summaryViews![0].id!);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_summaryBlockResponse.isClosed) {
        _summaryBlockResponse.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_summaryBlockResponse.isClosed) {
        _summaryBlockResponse.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('fetchSummaryViews : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_summaryBlockResponse.isClosed) {
        _summaryBlockResponse.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void fetchLeadBlock(String executionId, String projectRoleUid,
      String listViewId, String summaryViewID) async {
    try {
      SummaryBlockResponse summaryBlockResponse =
          await _executionRemoteRepository.fetchLeadBlock(
              executionId, projectRoleUid, listViewId, summaryViewID);
      if (!_summaryBlockResponse.isClosed) {
        _summaryBlockResponse.sink.add(summaryBlockResponse);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_summaryBlockResponse.isClosed) {
        _summaryBlockResponse.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_summaryBlockResponse.isClosed) {
        _summaryBlockResponse.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('fetchLeadBlock : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_summaryBlockResponse.isClosed) {
        _summaryBlockResponse.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  SummaryBlock? getSummaryBlock(List<SummaryBlock> selectedBlocks) {
    if (_summaryBlockResponse.value != null &&
        !_summaryBlockResponse.value!.blocks.isNullOrEmpty) {
      for (SummaryBlock summaryBlock in _summaryBlockResponse.value!.blocks!) {
        if (summaryBlock.parentBlockId == null && selectedBlocks.isEmpty) {
          return summaryBlock;
        } else {
          for (SummaryBlock selectedBlock in selectedBlocks) {
            if (summaryBlock.id == selectedBlock.id) {
              return summaryBlock;
            }
          }
        }
      }
    } else {
      return null;
    }
    return null;
  }

  Map<String, dynamic>? getStatusAliasMap() {
    if (!_leadsAnalysis.isClosed && _leadsAnalysis.hasValue) {
      return _leadsAnalysis.value.status;
    } else {
      return null;
    }
  }

  LeadRemoteRequest? getLeadRemoteRequest() {
    if (!_leadRemoteRequest.isClosed && _leadRemoteRequest.hasValue) {
      return _leadRemoteRequest.value;
    } else {
      return null;
    }
  }

  Future<List<Lead>?> getLeads(int pageIndex, String? searchTerm) async {
    try {
      if (!_leadRemoteRequest.isClosed && _leadRemoteRequest.hasValue) {
        LeadRemoteRequest leadRemoteRequest = _leadRemoteRequest.value;
        leadRemoteRequest.searchTerm = searchTerm;
        _leadRemoteRequest.sink.add(leadRemoteRequest);
      }
      LeadSearchResponse leadSearchResponse = await _leadRemoteRepository
          .searchLeads(_leadRemoteRequest.value, pageIndex);
      if (leadSearchResponse.leads != null) {
        int? previousLeadCount = 0;
        if (!_leadCount.isClosed && _leadCount.hasValue) {
          previousLeadCount = _leadCount.value;
        }
        if (pageIndex == 1) {
          previousLeadCount = 0;
        }
        int updatedLeadCount =
            (previousLeadCount! + leadSearchResponse.leads!.length);
        changeLeadCount(updatedLeadCount);
        return leadSearchResponse.leads;
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getLeads : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
    return null;
  }

  void addLead(String listViewID) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      LeadDataSourceParams? leadDataSourceParams =
          getLeadRemoteRequest()?.leadDataSourceParams;
      Lead lead =
          await _leadRemoteRepository.addLead(leadDataSourceParams, listViewID);
      changeUIStatus(
          UIStatus(isDialogLoading: false, event: Event.success, data: lead));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('addLead : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void cloneLead(String leadId,String listViewId) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      LeadDataSourceParams? leadDataSourceParams =
          getLeadRemoteRequest()?.leadDataSourceParams;
      Lead lead = await _leadRemoteRepository.cloneLead(
          leadId,leadDataSourceParams, listViewId);
      changeUIStatus(UIStatus(isDialogLoading: false,event: Event.updated, data: lead));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('cloneLead : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void deleteLead(String leadId,String listViewId) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      LeadDataSourceParams? leadDataSourceParams =
          getLeadRemoteRequest()?.leadDataSourceParams;
       await _leadRemoteRepository.deleteLead(
          leadId,leadDataSourceParams, listViewId);
      changeUIStatus(UIStatus(isDialogLoading: false,event: Event.deleted));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('cloneLead : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
