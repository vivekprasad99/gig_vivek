import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/notification_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/repository/core_remote_repository.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final CoreRemoteRepository _coreRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _unReadCount = BehaviorSubject<int>();

  Stream<int> get unReadCount => _unReadCount.stream;

  Function(int) get changeUnReadCount => _unReadCount.sink.add;

  NotificationCubit(this._coreRemoteRepository) : super(NotificationInitial());

  Future<List<Notifications>?> fetchNotificationList(
      int pageIndex, String? searchTerm) async {
    AppLog.e('Page index......$pageIndex');
    try {
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? _user = spUtil?.getUserData();
      List<Notifications>? data =
          await _coreRemoteRepository.fetchNotificationList(
              NotificationPageRequest(userID: _user!.id), pageIndex);
      return data;
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('fetchNotificationList : ${e.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void updateNotificationsStatus(int userID, String createdAt) async {
    try {
      await _coreRemoteRepository.updateNotificationsStatus(userID, createdAt);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e(
          'updateNotificationsStatus : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void updateSingleNotificationStatus(int notificationId) async {
    try {
      await _coreRemoteRepository
          .updateSingleNotificationStatus(notificationId);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e(
          'updateSingleNotificationStatus : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void updateUnReadCount() {
    _unReadCount.sink.add(0);
  }
}
