import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'category_details_state.dart';

class CategoryDetailsCubit extends Cubit<CategoryDetailsState> {
  final WosRemoteRepository _wosRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _isAlreadyApplied = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get isAlreadyApplied => _isAlreadyApplied.stream;

  Function(UIStatus) get changeIsAlreadyApplied => _isAlreadyApplied.sink.add;

  final _category = BehaviorSubject<Category>();

  Stream<Category> get category => _category.stream;

  CategoryDetailsCubit(this._wosRemoteRepository)
      : super(CategoryDetailsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _category.close();
    _isAlreadyApplied.close();
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

  void getCategoryApplicationDetails(String supplyID, int categoryID) async {
    try {
      changeIsAlreadyApplied(UIStatus(isOnScreenLoading: true));
      WorkApplicationResponse workApplicationResponse =
          await _wosRemoteRepository.getCategoryApplicationDetails(
              supplyID, categoryID.toString(), null);
      changeIsAlreadyApplied(
          UIStatus(isOnScreenLoading: false, event: Event.success));
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
}
