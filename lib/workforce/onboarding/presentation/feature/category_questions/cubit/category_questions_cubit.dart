import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/profile_attributes.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'category_questions_state.dart';

class CategoryQuestionsCubit extends Cubit<CategoryQuestionsState> {
  final WosRemoteRepository _wosRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  List<ProfileAttributes> userProfileAttributes = [];
  List<ScreenRow> answeredProfileQuestion = [];
  List<ScreenRow> unAnsweredProfileQuestion = [];

  CategoryQuestionsCubit(this._wosRemoteRepository)
      : super(CategoryQuestionsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    return super.close();
  }

  void submit(
      String supplyID, int categoryID, List<ScreenRow> screenRowList) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      CategoryApplication categoryApplication = await _wosRemoteRepository
          .createCategory(supplyID, categoryID, null, screenRowList);
      changeUIStatus(UIStatus(isDialogLoading: false, event: Event.success));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: e.message!,
          event: Event.failed));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: e.message!,
          event: Event.failed));
    } catch (e, st) {
      AppLog.e('getCategory : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr,
          event: Event.failed));
    }
  }
}
