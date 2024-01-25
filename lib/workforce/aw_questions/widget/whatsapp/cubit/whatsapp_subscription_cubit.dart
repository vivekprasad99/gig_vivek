import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:bloc/bloc.dart';
import 'package:get/utils.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'whatsapp_subscription_state.dart';

class WhatsappSubscriptionCubit extends Cubit<WhatsappSubscriptionState> {
  final AuthRemoteRepository _authRemoteRepository;

  final _isWhatsappSubscribed = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isWhatsappSubscribed => _isWhatsappSubscribed.stream;
  bool get isWhatsappSubscribedValue => _isWhatsappSubscribed.value;
  Function(bool) get changeIsWhatsappSubscribed =>
      _isWhatsappSubscribed.sink.add;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  WhatsappSubscriptionCubit(this._authRemoteRepository)
      : super(WhatsappSubscriptionInitial());

  void subscribeWhatsapp(UserData userData,bool? isNotComingFromCancel) async {
    try {
      ApiResponse apiResponse =
          await _authRemoteRepository.subscribeWhatsapp(userData.id);
      SPUtil? spUtil = await SPUtil.getInstance();
      await spUtil!.putWhatsappSubscribe(true);
      _isWhatsappSubscribed.sink.add(true);
      if(isNotComingFromCancel ?? false)
        {
          changeUIStatus(
              UIStatus(successWithoutAlertMessage: 'successfully_enabled'.tr));
        }

    } catch (e, st) {
      AppLog.e('subscribeWhatsapp : ${e.toString()} \n${st.toString()}');
    }
  }

  void unSubscribeWhatsapp(UserData userData) async {
    try {
      ApiResponse apiResponse =
          await _authRemoteRepository.unSubscribeWhatsapp(userData.id);
      changeUIStatus(
          UIStatus(successWithoutAlertMessage: apiResponse.message ?? ''));
    } catch (e, st) {
      AppLog.e('unSubscribeWhatsapp : ${e.toString()} \n${st.toString()}');
    }
  }
}
