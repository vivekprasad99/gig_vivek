import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/interector/application_event_interector.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing/work_listing_response.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/model/category/category_application_response.dart';

part 'category_detail_and_job_state.dart';

class CategoryDetailAndJobCubit extends Cubit<CategoryDetailAndJobState> {
  final WosRemoteRepository _wosRemoteRepository;
  final ApplicationEventInterector _applicationEventInterector;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _isAlreadyApplied = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get isAlreadyApplied => _isAlreadyApplied.stream;

  Function(UIStatus) get changeIsAlreadyApplied => _isAlreadyApplied.sink.add;

  final _category = BehaviorSubject<Category>();
  Stream<Category> get category => _category.stream;

  final _workListing = BehaviorSubject<List<Worklistings>?>();
  Stream<List<Worklistings>?> get workListingStream => _workListing.stream;
  List<Worklistings>? get workListing => _workListing.value;
  Function(List<Worklistings>?) get changeWorkListing => _workListing.sink.add;

  final _workApplicationEntity = BehaviorSubject<WorkApplicationEntity>();
  Stream<WorkApplicationEntity> get workApplicationEntityStream =>
      _workApplicationEntity.stream;
  WorkApplicationEntity get workApplicationEntityValue =>
      _workApplicationEntity.value;
  Function(WorkApplicationEntity) get changeWorkApplicationEntity =>
      _workApplicationEntity.sink.add;

  CategoryDetailAndJobCubit(this._wosRemoteRepository,this._applicationEventInterector)
      : super(CategoryDetailAndJobInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _category.close();
    return super.close();
  }

  void getCategory(int categoryID) async {
    try {
      Category category = await _wosRemoteRepository.getCategory(categoryID);
      if (!_category.isClosed) {
        _category.sink.add(category);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_category.isClosed) {
        _category.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_category.isClosed) {
        _category.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getCategory : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_category.isClosed) {
        _category.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  List<ScreenRow> getCategoryQuestions(int? userID) {
    Category category = _category.value;
    return category.getCategoryQuestions(userID);
  }

  Future<WorkApplicationResponse?> getCategoryApplicationDetails(
      int categoryID) async {
    try {
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? _user = spUtil?.getUserData();
      changeIsAlreadyApplied(UIStatus(isOnScreenLoading: true));
      WorkApplicationResponse workApplicationResponse =
          await _wosRemoteRepository.getCategoryApplicationDetails(
              _user!.id.toString(), categoryID.toString(), null);
      changeIsAlreadyApplied(
          UIStatus(isOnScreenLoading: false, event: Event.success));
      return workApplicationResponse;
    } on ServerException catch (e) {
      changeIsAlreadyApplied(
          UIStatus(isOnScreenLoading: false, event: Event.failed));
    } on FailureException catch (e) {
      changeIsAlreadyApplied(
          UIStatus(isOnScreenLoading: false, event: Event.failed));
    } catch (e, st) {
      AppLog.e(
          'getCategoryApplicationDetails : ${e.toString()} \n${st.toString()}');
      changeIsAlreadyApplied(
          UIStatus(isOnScreenLoading: false, event: Event.failed));
    }
  }

  List<Worklistings>? sortCategory(List<Worklistings> categories) {
    categories.sort((a, b) {
      if (a.highlightTag?.name != null) {
        return -1;
      } else if (b.highlightTag?.name != null) {
        return 1;
      } else {
        return 0;
      }
    });
    return categories;
  }

  void getWorkListing(int categoryID) async {
    try {
      WorkListingResponse workListingResponse =
          await _wosRemoteRepository.getWorkListing(categoryID);
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? _user = spUtil?.getUserData();
      if (_user != null) {
        WorkApplicationResponse? workApplicationResponse =
            await getCategoryApplicationDetails(categoryID);
        List<Worklistings>? tempWorkList = [];
        tempWorkList.addAll(workListingResponse.worklistings!);
        for (int i = 0; i < workListingResponse.worklistings!.length; i++) {
          Worklistings newWorkList = workListingResponse.worklistings![i];
          if (workApplicationResponse != null) {
            WorkApplicationEntity? newWorkApplication =
                getAndCheckWorkApplication(
                    workListingResponse.worklistings![i].id,
                    workApplicationResponse.workApplicationList);
            newWorkList.workApplicationEntity = newWorkApplication;
            tempWorkList[i] = newWorkList;
          }
        }
        if (!_workListing.isClosed) {
          _workListing.sink.add(sortCategory(tempWorkList));
        }
      } else {
        if (!_workListing.isClosed) {
          _workListing.sink.add(workListingResponse.worklistings);
        }
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_workListing.isClosed) {
        _workListing.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_workListing.isClosed) {
        _workListing.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getWorkListing : ${e.toString()} \n${st.toString()}');
    }
  }

  WorkApplicationEntity? getAndCheckWorkApplication(
      int? workListingId, List<WorkApplicationEntity>? workApplicationEntity) {
    for (int i = 0; i < workApplicationEntity!.length; i++) {
      if (workListingId == workApplicationEntity[i].workListingId) {
        return workApplicationEntity[i];
      }
    }
    return null;
  }

  void executeApplicationEvent(int userID, int listingID, int applicationID,
      ApplicationAction applicationAction) async {
    try {
      WorkApplicationEntity? workApplicationEntity =
      await _applicationEventInterector.handleApplicationEvent(
          userID, applicationID, applicationAction);
      if (workApplicationEntity != null && !_workApplicationEntity.isClosed) {
        _workApplicationEntity.sink.add(workApplicationEntity);
        switch (workApplicationEntity.applicationStatus) {
          case ApplicationStatus.genericSelected:
            changeUIStatus(UIStatus(event: Event.selected));
            break;
          default:
            changeUIStatus(UIStatus(event: Event.success));
        }
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('executeApplicationEvent : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  Future<void> createApplicationInNotifyStatus(int categoryId, int userId) async {
    try {
      CategoryApplication categoryApplication = await _wosRemoteRepository.createCategoryInNotifyStatus(userId, categoryId);
      changeUIStatus(UIStatus(
          event: Event.created, data: categoryApplication
      ));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e(
          'createApplicationInNotifyStatus : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
