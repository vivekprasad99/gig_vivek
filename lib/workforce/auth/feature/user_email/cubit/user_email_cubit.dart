import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

part 'user_email_state.dart';

class UserEmailCubit extends Cubit<UserEmailState> {
  final AuthRemoteRepository _authRemoteRepository;
  late GoogleSignInAccount _googleSignInAccount;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  UserEmailCubit(this._authRemoteRepository) : super(UserEmailInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    return super.close();
  }

  void googleSignIn() async {
    try {
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) return;
      _googleSignInAccount = googleAccount;
      AppLog.i(_googleSignInAccount.email);
      AppLog.i(_googleSignInAccount.id);
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? currUser = spUtil?.getUserData();
      currUser?.name = _googleSignInAccount.displayName;
      currUser?.email = _googleSignInAccount.email;
      currUser?.userProfile?.email = _googleSignInAccount.email;
      spUtil?.putUserData(currUser);
      if (currUser != null) {
        Map<String, dynamic> properties =
            await UserProperty.getUserProperty(currUser);
        ClevertapData clevertapData = ClevertapData(
            eventName: ClevertapHelper.googleSignup, properties: properties);
        CaptureEventHelper.captureEvent(clevertapData: clevertapData);
      }
      changeUIStatus(
          UIStatus(event: Event.success, successWithoutAlertMessage: ""));
    } catch (e) {
      AppLog.e('googleSignIn : ${e.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
