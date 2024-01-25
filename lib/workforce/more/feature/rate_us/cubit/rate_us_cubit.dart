import 'package:awign/workforce/auth/data/model/user_feedback_response.dart';
import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/utils/app_log.dart';

part 'rate_us_state.dart';

class RateUsCubit extends Cubit<RateUsState> {
  final AuthRemoteRepository _authRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _isRated = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isRated => _isRated.stream;
  Function(bool) get changeIsRated => _isRated.sink.add;

  RateUsCubit(this._authRemoteRepository) : super(RateUsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _isRated.close();
    return super.close();
  }

  Future<bool?> internalUserFeedback(
      UserFeedbackRequest userFeedbackRequest) async {
    try {
      UserFeedbackRequest data =
          await _authRemoteRepository.internalUserFeedback(userFeedbackRequest);
      if (data.supplyFeedback!.status == Status.submitted.name) {
        return true;
      } else {
        return false;
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('internalUserFeedback : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
