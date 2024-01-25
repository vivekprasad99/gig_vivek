import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'category_application_state.dart';

class CategoryApplicationCubit extends Cubit<CategoryApplicationState> {
  final WosRemoteRepository _wosRemoteRepository;
  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _category = BehaviorSubject<Category>();
  Stream<Category> get category => _category.stream;

  final _currentUser = BehaviorSubject<UserData>();
  Stream<UserData> get currentUser => _currentUser.stream;
  Function(UserData) get changeCurrentUser => _currentUser.sink.add;

  CategoryApplicationCubit(this._wosRemoteRepository)
      : super(CategoryApplicaionInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _category.close();
    _currentUser.close();
    return super.close();
  }

  Future<List<CategoryApplication>?> getCategoryApplication(
      int pageIndex, String? searchTerm) async {
    AppLog.e('Page index.....$pageIndex');
    try {
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? _user = spUtil?.getUserData();
      Tuple2<CategoryApplicationResponse, String?> tuple2 =
          await _wosRemoteRepository.getCategoryApplicationList(
              pageIndex, _user!.id.toString());
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
          'getApplicationCategoryList : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
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
}
