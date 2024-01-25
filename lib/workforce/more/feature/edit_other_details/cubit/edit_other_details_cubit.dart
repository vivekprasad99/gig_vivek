import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/profile_attributes.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'edit_other_details_state.dart';

class EditOtherDetailsCubit extends Cubit<EditOtherDetailsState> {
  final AuthRemoteRepository _authRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  EditOtherDetailsCubit(this._authRemoteRepository)
      : super(EditOtherDetailsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    return super.close();
  }

  void updateProfileAttribute(
      int? userID, ProfileAttributes? profileAttributes) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      ApiResponse apiResponse =
          await _authRemoteRepository.updateProfileAttributes(
              userID, profileAttributes?.id, profileAttributes!);
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          event: Event.updated,
          successWithoutAlertMessage: apiResponse.message ?? ''));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('updateProfileAttribute : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void createProfileAttribute(
      int? userId, String? attributeName, String? value) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      List<ProfileAttributes> profileAttributeList = await _authRemoteRepository
          .createProfileAttribute(userId, attributeName, value);
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          event: Event.created,
          data: profileAttributeList));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('createProfileAttribute : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
