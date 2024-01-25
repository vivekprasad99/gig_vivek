import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/auth/helper/auth_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_education_level_bottom_sheet/cubit/select_education_level_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/cubit/select_working_domain_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/model/working_domain.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'education_details_state.dart';

class EducationDetailsCubit extends Cubit<EducationDetailsState>
    with Validator {
  final _selectWorkingDomainCubit = sl<SelectWorkingDomainCubit>();
  final _selectEducationLevelCubit = sl<SelectEducationLevelCubit>();
  final AuthRemoteRepository _authRemoteRepository;

  final _selectedEducationLevel = BehaviorSubject<String?>();

  Stream<String?> get selectedEducationLevel => _selectedEducationLevel.stream;

  Function(String?) get changeSelectedEducationLevel =>
      _selectedEducationLevel.sink.add;

  final _selectedWorkedBefore = BehaviorSubject<int?>.seeded(2);

  Stream<int?> get selectedWorkedBefore => _selectedWorkedBefore.stream;

  Function(int?) get changeSelectedWorkedBefore =>
      _selectedWorkedBefore.sink.add;

  final _selectedWorkingDomainList = BehaviorSubject<List<WorkingDomain>?>();

  Stream<List<WorkingDomain>?> get selectedWorkingDomainList =>
      _selectedWorkingDomainList.stream;

  Function(List<WorkingDomain>?) get changeSelectedWorkingDomainList =>
      _selectedWorkingDomainList.sink.add;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _validateTokenResponse = BehaviorSubject<ValidateTokenResponse>();

  Stream<ValidateTokenResponse> get validateTokenResponse =>
      _validateTokenResponse.stream;

  final _userProfileResponse = BehaviorSubject<UserProfileResponse>();

  Stream<UserProfileResponse> get userProfileResponse =>
      _userProfileResponse.stream;

  final _validTokenWithProfile = BehaviorSubject<ValidateTokenResponse>();

  Stream<ValidateTokenResponse> get validTokenWithProfile =>
      _validTokenWithProfile.stream;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  EducationDetailsCubit(this._authRemoteRepository)
      : super(EducationDetailsInitial()) {
    _selectedEducationLevel.listen((value) {
      _checkValidation();
    });
    _selectedWorkedBefore.listen((value) {
      _checkValidation();
    });
    _selectedWorkingDomainList.listen((value) {
      _checkValidation();
    });
  }

  _checkValidation() {
    if (!_selectedEducationLevel.isClosed &&
        _selectedEducationLevel.hasValue &&
        !_selectedWorkedBefore.isClosed &&
        _selectedWorkedBefore.hasValue) {
      if (_selectedWorkedBefore.value == 1 &&
          !_selectedWorkingDomainList.isClosed &&
          _selectedWorkingDomainList.hasValue &&
          _selectedWorkingDomainList.value!.isNotEmpty) {
        changeButtonStatus(ButtonStatus(isEnable: true));
      } else if (_selectedWorkedBefore.value == 2) {
        changeButtonStatus(ButtonStatus(isEnable: true));
      } else {
        changeButtonStatus(ButtonStatus(isEnable: false));
      }
    } else {
      changeButtonStatus(ButtonStatus(isEnable: false));
    }
  }

  @override
  Future<void> close() {
    _selectedEducationLevel.close();
    _selectedWorkedBefore.close();
    _selectedWorkingDomainList.close();
    _uiStatus.close();
    buttonStatus.close();
    return super.close();
  }

  void updateProfile(UserData userData) async {
    try {
      if ((_selectedEducationLevel.hasValue
              ? _selectedEducationLevel.value
              : null) ==
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: 'please_select_education_level'.tr));
        return;
      }

      if (_selectedWorkedBefore.value == 1 &&
          (_selectedWorkingDomainList.valueOrNull == null ||
              _selectedWorkingDomainList.value!.isEmpty)) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: 'please_select_your_domain'.tr));
        return;
      }
      changeButtonStatus(
          ButtonStatus(isLoading: true, message: 'please_wait'.tr));
      ApiResponse apiResponse = await _authRemoteRepository.updateUserProfile(
          userData.userProfile?.userId,
          userData.name,
          userData.email,
          userData.userProfile?.gender,
          _selectedEducationLevel.value,
          userData.userProfile?.dob,
          AuthHelper.done,
          null,
          _selectedWorkedBefore.value == 1);
      Map<String, dynamic> properties =
          await UserProperty.getUserProperty(userData);
      properties[CleverTapConstant.educationLevel] =
          _selectedEducationLevel.value;
      properties[CleverTapConstant.professionalExperience] =
          _selectedWorkingDomainList.value ?? [];
      ClevertapHelper.instance()
          .addCleverTapEvent(ClevertapHelper.onboardingComplete, properties);
      _updateProfessionalExperiences(userData.userProfile?.userId);
      validateTokenAndGetUserProfile(userData.id, apiResponse);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
    } catch (e) {
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
    }
  }

  void _updateProfessionalExperiences(int? userID) async {
    try {
      List<WorkingDomain> selectedWorkingDomainList = [];
      if (_selectedWorkingDomainList.hasValue &&
          _selectedWorkingDomainList.value != null) {
        selectedWorkingDomainList = _selectedWorkingDomainList.value ?? [];
      }
      ApiResponse apiResponse = await _authRemoteRepository
          .updateProfessionalExperiences(userID, selectedWorkingDomainList);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('updateProfessionalExperiences : ${e.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void validateTokenAndGetUserProfile(
      int? userID, ApiResponse apiResponse) async {
    Rx.combineLatest2(
      _validateTokenResponse.stream,
      _userProfileResponse.stream,
      (ValidateTokenResponse validateTokenResponse,
          UserProfileResponse userProfileResponse) {
        validateTokenResponse.user?.userProfile =
            userProfileResponse.userProfile;
        return validateTokenResponse;
      },
    ).listen((validateTokenResponse) async {
      SPUtil? spUtil = await SPUtil.getInstance();
      spUtil?.putUserData(validateTokenResponse.user);
      spUtil?.putAccessToken(validateTokenResponse.headers!.accessToken);
      spUtil?.putClient(validateTokenResponse.headers!.client);
      spUtil?.putUID(validateTokenResponse.headers!.uid);
      spUtil?.putSaasOrgID(validateTokenResponse.headers!.saasOrgID != null
          ? validateTokenResponse.headers!.saasOrgID!
          : '');
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.add(validateTokenResponse);
      }
      changeButtonStatus(
          ButtonStatus(isSuccess: true, message: apiResponse.message));
      await Future.delayed(const Duration(milliseconds: 500));
      changeUIStatus(UIStatus(
          event: Event.updated,
          successWithoutAlertMessage: apiResponse.message ?? ''));
    });
    validateToken();
    getUserProfile(userID);
  }

  void validateToken() async {
    try {
      Tuple2<ValidateTokenResponse, String?> tuple2 =
          await _authRemoteRepository.validateToken();
      if (!_validateTokenResponse.isClosed) {
        _validateTokenResponse.sink.add(tuple2.item1);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      changeButtonStatus(
          ButtonStatus(isLoading: false, isEnable: true, message: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } catch (e, st) {
      AppLog.e('validateToken : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink
            .addError('we_regret_the_technical_error'.tr);
      }
    }
  }

  void getUserProfile(int? userID) async {
    try {
      UserProfileResponse userProfileResponse =
          await _authRemoteRepository.getUserProfile(userID);
      if (!_userProfileResponse.isClosed) {
        _userProfileResponse.sink.add(userProfileResponse);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink.addError(e.message ?? '');
      }
    } catch (e, st) {
      AppLog.e('getUserProfile : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      changeButtonStatus(ButtonStatus(isLoading: false, isEnable: true));
      if (!_validTokenWithProfile.isClosed) {
        _validTokenWithProfile.sink
            .addError('we_regret_the_technical_error'.tr);
      }
    }
  }
}
