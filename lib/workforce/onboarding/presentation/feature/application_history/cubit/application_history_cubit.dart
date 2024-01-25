import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'application_history_state.dart';

class ApplicationHistoryCubit extends Cubit<ApplicationHistoryState> {
  final WosRemoteRepository _wosRemoteRepository;
  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _currentUser = BehaviorSubject<UserData>();
  Stream<UserData> get currentUserStream => _currentUser.stream;
  Function(UserData) get changeCurrentUser => _currentUser.sink.add;

  ApplicationHistoryCubit(this._wosRemoteRepository)
      : super(ApplicationHistoryInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _currentUser.close();
    return super.close();
  }

  Future<List<WorkApplicationEntity>?> getApplicationHistory(
      int pageIndex, String? searchTerm) async {
    AppLog.e('Page index......$pageIndex');
    try {
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? _user = spUtil?.getUserData();
      Tuple2<WorkApplicationResponse, String?> tuple2 =
          await _wosRemoteRepository.getApplicationHistory(
              pageIndex, _user!.id);
      if (tuple2.item1.workApplicationList != null) {
        return tuple2.item1.workApplicationList;
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('getApplicationCategoryList : ${e.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
