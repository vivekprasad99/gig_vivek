import 'package:awign/workforce/core/data/firebase/remote_config/remote_config_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/nps_bottom_sheet/data/nps_entity.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:awign/workforce/onboarding/data/model/nudge/nudge_response.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:awign/workforce/payment/data/repository/payment_bff_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz_unsafe.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../../../auth/data/repository/auth_remote_repository.dart';

part 'category_listing_state.dart';

class CategoryListingCubit extends Cubit<CategoryState> {
  final WosRemoteRepository _wosRemoteRepository;
  final AuthRemoteRepository _authRemoteRepository;
  final PaymentBffRemoteRepository _paymentBffRemoteRepository;

  UserNudges? userNudges;
  String? profileCompletionPercentage;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _showProfileCompletionNudge = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get showProfileCompletionNudge =>
      _showProfileCompletionNudge.stream;

  bool get showProfileCompletionNudgeValue => _showProfileCompletionNudge.value;

  Function(bool) get changeShowProfileCompletionNudge =>
      _showProfileCompletionNudge.sink.add;

  final _currentUser = BehaviorSubject<UserData>();
  Stream<UserData> get currentUser => _currentUser.stream;
  Function(UserData) get changeCurrentUser => _currentUser.sink.add;

  CategoryListingCubit(this._wosRemoteRepository, this._authRemoteRepository,this._paymentBffRemoteRepository)
      : super(CategoryInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _showProfileCompletionNudge.close();
    _currentUser.close();
    return super.close();
  }

  void getUserNudge(int userID) async {
    try {
      NudgeResponse nudgeResponse =
          await _authRemoteRepository.getUserNudge(userID);
      userNudges = nudgeResponse.userNudges?.elementAt(0);
      profileCompletionPercentage =
          userNudges?.nudgeData?.profileCompletionPercentage;
      if (userNudges != null) {
        changeShowProfileCompletionNudge(true);
      }
    } catch (e, st) {
      AppLog.e('getUserNudge : ${e.toString()} \n${st.toString()}');
    }
  }

  List<Category>? sortCategory(List<Category> categories){
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

  Future<List<Category>?> getCategoryList(
      int pageIndex, String? searchTerm) async {
    AppLog.e('Page index.....$pageIndex');
    try {
      Tuple2<CategoryResponse, String?> tuple2 =
          await _wosRemoteRepository.getCategoryList(pageIndex);
      List<int> listOfId = [];
      for (Category categories in tuple2.item1.categories!) {
        listOfId.add(categories.id!);
      }
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? _user = spUtil?.getUserData();
      if(_user != null)
        {
          List<CategoryApplication>? categoryApplication = await getCategoryApplication(_user,categoryId: listOfId);
          List<Category> tempCategoryList = [];
          tempCategoryList.addAll(tuple2.item1.categories!);
          for (int i = 0; i < tuple2.item1.categories!.length; i++) {
            Category newCategory = tuple2.item1.categories![i];
            CategoryApplication? newCategoryApplication = getAndCheckCategoryApplication(tuple2.item1.categories![i].id,categoryApplication);
            newCategory.categoryApplication = newCategoryApplication;
            tempCategoryList[i] = newCategory;
          }
          if (tuple2.item1.categories != null) {
            return sortCategory(tempCategoryList);
          }
        }else{
        if (tuple2.item1.categories != null) {
          return sortCategory(tuple2.item1.categories ?? List.empty());
        }
      }

    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getCategoryList : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  CategoryApplication? getAndCheckCategoryApplication(int? categoryId,List<CategoryApplication>? categoryApplication)
  {
    for (int i = 0; i < categoryApplication!.length; i++) {
      if(categoryId == categoryApplication[i].categoryId)
        {
          return categoryApplication[i];
        }
    }
    return null;
  }

  void nudgeEvent(int userId, String eventName, String eventType) async {
    DateTime dateTime = DateTime.now().toUtc();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    await _authRemoteRepository.nudgeEvents(
        userId, eventName, eventType, formatter.format(dateTime));
  }

  void updateDeviceInfo(int userID, String? role, String fcmToken) async {
    try {
      ApiResponse apiResponse =
          await _authRemoteRepository.updateDeviceInfo(userID, role, fcmToken);
    } catch (e, st) {
      AppLog.e('updateDeviceInfo : ${e.toString()} \n${st.toString()}');
    }
  }

  void subscribeWhatsapp(int userID) async {
    try {
      ApiResponse apiResponse =
          await _authRemoteRepository.subscribeWhatsapp(userID);
      changeUIStatus(
          UIStatus(successWithoutAlertMessage: 'Successfully enabled!'));
    } catch (e, st) {
      AppLog.e('subscribeWhatsapp : ${e.toString()} \n${st.toString()}');
    }
  }

  Future<bool> shouldShow() async {
    int delay = RemoteConfigHelper.instance().delayWhatsappBottomSheet;
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    SPUtil? spUtil = await SPUtil.getInstance();
    UserData? _currentUser = spUtil?.getUserData();
    var previousShownTime =
        spUtil!.getPreviousWhatsappBottomSheetOpenTime() ?? 0;
    var shouldShow = (spUtil.getShouldShowBottomSheet() ?? false) &&
        ((currentTime - previousShownTime!) >= delay);
    return shouldShow &&
        _currentUser != null &&
        _currentUser.userProfile!.subscribedToWhatsapp == false;
  }

  void getUserProfile(UserData currentUser) async {
    try {
      UserProfileResponse userProfileResponse =
          await _authRemoteRepository.getUserProfile(currentUser.id ?? -1);
      if (!_currentUser.isClosed) {
        currentUser.userProfile = userProfileResponse.userProfile;
        SPUtil? spUtil = await SPUtil.getInstance();
        spUtil?.putUserData(currentUser);
        changeCurrentUser(currentUser);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_currentUser.isClosed) {
        _currentUser.sink.addError(e.message ?? '');
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_currentUser.isClosed) {
        _currentUser.sink.addError(e.message ?? '');
      }
    } catch (e, st) {
      AppLog.e('getUserProfile : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_currentUser.isClosed) {
        _currentUser.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  Future<List<CategoryApplication>?> getCategoryApplication(UserData? user,{List<int>? categoryId}) async {
    try {
      Tuple2<CategoryApplicationResponse, String?> tuple2 =
      await _wosRemoteRepository.getCategoryApplicationList(
          1, user!.id.toString(),listOfCategoryId: categoryId);
      if (tuple2.item1.categoryApplications != null) {
        return tuple2.item1.categoryApplications;
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e(
          'getCategoryApplication : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  Future<void> createApplicationInNotifyStatus(int index, int categoryId, int userId) async {
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

  void getNpsAction(String userId) async {
    try {
    Nps? nps = await _paymentBffRemoteRepository.getNpsAction(userId);
    if(nps.actions != null && nps.actions!.isNotEmpty)
      {
        for (Actions action in nps.actions!) {
              if(action.actionName == Constants.npsRatingShow && action.status == Constants.pending)
                {
                  changeUIStatus(UIStatus(event: Event.success,));
                }
        }
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getNpsAction : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
