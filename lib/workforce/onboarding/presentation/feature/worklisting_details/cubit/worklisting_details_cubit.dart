import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/interector/application_event_interector.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/application_status.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_action.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing/work_listing.dart';
import 'package:awign/workforce/onboarding/data/repository/work_application/work_application_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/work_listing/work_listing_remote_repository.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'worklisting_details_state.dart';

class WorkListingDetailsCubit extends Cubit<WorklistingDetailsState> {
  final WorkListingRemoteRepository _workListingRemoteRepository;
  final WosRemoteRepository _wosRemoteRepository;
  final WorkApplicationRemoteRepository _workApplicationRemoteRepository;
  final ApplicationEventInterector _applicationEventInterector;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _workListing = BehaviorSubject<WorkListing?>();

  Stream<WorkListing?> get workListingStream => _workListing.stream;

  final _categoryApplicationList = BehaviorSubject<List<CategoryApplication>>();

  Stream<List<CategoryApplication>> get categoryApplicationListStream =>
      _categoryApplicationList.stream;

  final _applicationList = BehaviorSubject<List<WorkApplicationEntity>>();

  Stream<List<WorkApplicationEntity>> get applicationListStream =>
      _applicationList.stream;

  final _workApplicationForCategory = BehaviorSubject<
      Tuple2<List<CategoryApplication>, List<WorkApplicationEntity>>?>();

  Stream<Tuple2<List<CategoryApplication>, List<WorkApplicationEntity>>?>
      get workApplicationForCategoryStream =>
          _workApplicationForCategory.stream;

  Tuple2<List<CategoryApplication>, List<WorkApplicationEntity>>? get workApplicationForCategoryValue
  {
    if(_workApplicationForCategory.hasValue)
      {
        return _workApplicationForCategory.value;
      }
    return null;
  }

  final _category = BehaviorSubject<Category>();

  Stream<Category> get category => _category.stream;

  final _isCategoryDetailVisible = BehaviorSubject<bool>();
  Stream<bool> get isCategoryDetailVisible => _isCategoryDetailVisible.stream;
  Function(bool) get changeIsCategoryDetailVisible => _isCategoryDetailVisible.sink.add;

  final _workApplicationEntity = BehaviorSubject<WorkApplicationEntity>();
  Stream<WorkApplicationEntity> get workApplicationEntityStream =>
      _workApplicationEntity.stream;
  WorkApplicationEntity get workApplicationEntityValue =>
      _workApplicationEntity.value;
  Function(WorkApplicationEntity) get changeWorkApplicationEntity =>
      _workApplicationEntity.sink.add;

  final _categoryApplication = BehaviorSubject<CategoryApplication?>();
  Function(CategoryApplication?) get changeCategoryApplication =>
      _categoryApplication.sink.add;
  CategoryApplication? get categoryApplicationValue =>
      _categoryApplication.value;

  WorkListingDetailsCubit(this._workListingRemoteRepository,
      this._wosRemoteRepository, this._workApplicationRemoteRepository,this._applicationEventInterector)
      : super(WorklistingDetailsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _workListing.close();
    _categoryApplicationList.close();
    _applicationList.close();
    _workApplicationForCategory.close();
    _category.close();
    return super.close();
  }

  WorkListing? getWorkListing() {
    if (!_workListing.isClosed && _workListing.hasValue) {
      return _workListing.value;
    } else {
      return null;
    }
  }

  WorkApplicationEntity? getWorkApplicationEntity() {
    if (!_workApplicationForCategory.isClosed && _workApplicationForCategory.hasValue
        && _workApplicationForCategory.value!.item2.isNotEmpty) {
      return _workApplicationForCategory.value?.item2[0];
    } else {
      return null;
    }
  }

  void fetchWorkListing(int userID, String workListingID, String? saasOrgID,
      bool isSkipSaasOrgID) async {
    try {
      if (!_workListing.isClosed && _workListing.hasValue) {
        _workListing.sink.add(null);
      }
      if (!_workApplicationForCategory.isClosed &&
          _workApplicationForCategory.hasValue) {
        _workApplicationForCategory.sink.add(null);
      }
      WorkListing workListing =
          await _workListingRemoteRepository.fetchWorkListing(workListingID);
      if (!saasOrgID.isNullOrEmpty && saasOrgID != workListing.saasOrgId) {
        _workListing.sink.addError('listing_unavailable'.tr);
      } else {
        if (userID != -1) {
          getCategoryApplication(
              userID, workListing.categoryId?.toString() ?? '', workListing);
        }
        if (workListing.urlStatus == UrlStatus.inactive) {
          _workListing.sink.addError('listing_unavailable'.tr);
        } else {
          if (!_workListing.isClosed) {
            _workListing.sink.add(workListing);
          }
        }
      }
      fetchWorkApplicationForCategory(
          userID,
          workListing.categoryId?.toString() ?? '',
          workListing.id.toString(),
          isSkipSaasOrgID);
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
    } catch (e) {
      AppLog.e('fetchWorkListing : ${e.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_workListing.isClosed) {
        _workListing.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void fetchWorkApplicationForCategory(int userID, String categoryID,
      String workListingID, bool isSkipSaasOrgID) async {
    Rx.combineLatest2(
      _categoryApplicationList.stream,
      _applicationList.stream,
      (List<CategoryApplication> categoryApplicationList,
          List<WorkApplicationEntity> applicationList) {
        return Tuple2(categoryApplicationList, applicationList);
      },
    ).listen((tuple2) async {
      if (!_workApplicationForCategory.isClosed) {
        _workApplicationForCategory.sink.add(tuple2);
      }
    }).onError((e) {
      getCategory(int.parse(categoryID));
    });
    if(userID != -1)
      {
        getCategoryApplicationDetails(
            userID, categoryID, workListingID, isSkipSaasOrgID);
      }
  }

  void getCategoryApplication(
      int userID, String categoryID, WorkListing workListing) async {
    try {
      Tuple2<CategoryApplicationResponse, String?> tuple2 =
          await _wosRemoteRepository.getCategoryApplicationList(
              1, userID.toString(),
              categoryID: categoryID);
      if (tuple2.item1.categoryApplications != null &&
          !_categoryApplicationList.isClosed) {
        _categoryApplicationList.sink.add(tuple2.item1.categoryApplications!);
        if (tuple2.item1.categoryApplications!.isNotEmpty) {
          if (!_workListing.isClosed) {
            _workListing.sink.add(workListing);
          }
        }
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_categoryApplicationList.isClosed) {
        _categoryApplicationList.sink.addError(e.message ?? "");
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_categoryApplicationList.isClosed) {
        _categoryApplicationList.sink.addError(e.message ?? "");
      }
    } catch (e, st) {
      AppLog.e(
          'getApplicationCategoryList : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_categoryApplicationList.isClosed) {
        _categoryApplicationList.sink
            .addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void getCategoryApplicationDetails(int userID, String categoryID,
      String workListingID, bool isSkipSaasOrgID) async {
    try {
      Tuple2<WorkApplicationResponse, String?> tuple2 =
          await _wosRemoteRepository.getCategoryApplicationSearch(
              categoryID, userID.toString(), isSkipSaasOrgID,
              workListingID: workListingID);
      if (tuple2.item1.workApplicationList != null &&
          !_applicationList.isClosed) {
        _applicationList.sink.add(tuple2.item1.workApplicationList!);
      } else if (!_applicationList.isClosed) {
        _applicationList.sink.addError(tuple2.item1);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_applicationList.isClosed) {
        _applicationList.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_applicationList.isClosed) {
        _applicationList.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e(
          'getCategoryApplicationDetails : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_applicationList.isClosed) {
        _applicationList.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void getCategory(int categoryID) async {
    try {
      Category category = await _wosRemoteRepository.getCategory(categoryID);
      if (!_category.isClosed && !_uiStatus.isClosed) {
        _category.sink.add(category);
        changeUIStatus(UIStatus(event: Event.success, data: category));
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

  void reApply(String categoryID, int userID, String workListingID) async {
    try {
      Map<String, dynamic> apiResponse = await _workApplicationRemoteRepository
          .applicationCreate(categoryID, userID.toString(), workListingID);
      changeUIStatus(UIStatus(
          event: Event.created, successWithoutAlertMessage: 'applied'.tr));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('reApply : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
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
}
