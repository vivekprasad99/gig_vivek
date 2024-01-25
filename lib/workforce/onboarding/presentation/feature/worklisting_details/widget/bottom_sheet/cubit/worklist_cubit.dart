import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing_fetch_locations/address_entity.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../../../core/data/model/advance_search/advance_search_request.dart';
import '../../../../../../data/repository/work_listing/work_listing_remote_repository.dart';

part 'worklist_state.dart';

class WorklistCubit extends Cubit<WorklistState> {
  final WorkListingRemoteRepository _workListingRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _workList = BehaviorSubject<List<Education>>();

  Stream<List<Education>> get collageListStream => _workList.stream;

  List<Education> get collageList => _workList.value;

  Function(List<Education>) get changeCollageList => _workList.sink.add;

  WorklistCubit(this._workListingRemoteRepository)
      : super(SelectWorkListInitial());

  final _title = BehaviorSubject<String>.seeded("");

  Stream<String> get title => _title.stream;

  var searchTerm = "";

  @override
  Future<void> close() {
    _workList.close();
    _uiStatus.close();
    _title.close();
    return super.close();
  }

  setBottomSheetTitle(String columnName) {
    if (columnName == "all_india") {
      _title.add("All India");
    }
    if (columnName == "cities") {
      _title.add("City");
    }
    if (columnName == "pincodes") {
      _title.add("Pincode");
    }
    if (columnName == "states") {
      _title.add("State");
    }
  }

  dynamic getItemBottomSheetTitle(
      String columnName, WorklistingLocations workListItem) {
    if (columnName == "all_india") {
      return workListItem.state ??"";
    }
    if (columnName == "cities") {
      return workListItem.city ??"";
    }
    if (columnName == "pincodes") {
      return workListItem.pincode ?? 0;
    }
    if (columnName == "states") {
      return workListItem.state ?? "";
    }

    return "";
  }


  String getColumnForApi(
      String columnName) {

    if (columnName == "cities") {
      return "city";
    }
    if (columnName == "pincodes") {
      return "pincode";
    }
    if (columnName == "states") {
      return "state";
    }
    return "";
  }

  Future<List<WorklistingLocations>?> searchWorkList(
      int pageIndex, String workListingId, String columnName) async {
    try {
      var requestBuilder = AdvanceSearchRequestBuilder();
      requestBuilder.setPage(pageIndex);
      requestBuilder.setSearchTerm(searchTerm ?? '');
      requestBuilder.setSearchColumn(getColumnForApi(columnName));
      requestBuilder.setLimit(10);

      var result = await _workListingRemoteRepository.fetchLocationsList(
          workListingId, requestBuilder.build());

      changeUIStatus(UIStatus(isDialogLoading: false));
      return result.worklistingLocations;
    } on ServerException catch (e) {

      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {

      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
