import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/cubit/select_language_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/model/language.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'edit_personal_info_state.dart';

class EditPersonalInfoCubit extends Cubit<EditPersonalInfoState>
    with Validator {
  final AuthRemoteRepository _authRemoteRepository;
  final _selectLanguageCubit = sl<SelectLanguageCubit>();

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _name = BehaviorSubject<String?>();

  Stream<String?> get name => _name.stream.transform(validName);

  Function(String?) get changeName => _name.sink.add;

  final _selectedGender = BehaviorSubject<Gender?>();

  Stream<Gender?> get selectedGender => _selectedGender.stream;

  Function(Gender?) get changeSelectedGender => _selectedGender.sink.add;

  final _date = BehaviorSubject<String?>();

  Stream<String?> get date => _date.stream;

  Function(String?) get changeDate => _date.sink.add;

  final _month = BehaviorSubject<String?>();

  Stream<String?> get month => _month.stream;

  Function(String?) get changeMonth => _month.sink.add;

  final _year = BehaviorSubject<String?>();

  Stream<String?> get year => _year.stream;

  Function(String?) get changeYear => _year.sink.add;

  final _isWhatsappSubscribed = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isWhatsappSubscribed => _isWhatsappSubscribed.stream;

  bool get isWhatsappSubscribedValue => _isWhatsappSubscribed.value;

  Function(bool) get changeIsWhatsappSubscribed =>
      _isWhatsappSubscribed.sink.add;

  final _selectedLanguages = BehaviorSubject<List<Languages>?>();

  Stream<List<Languages>?> get selectedLanguages => _selectedLanguages.stream;

  final _userProfile = BehaviorSubject<UserProfile>();

  Stream<UserProfile> get userProfile => _userProfile.stream;

  Function(UserProfile) get changeUserProfile => _userProfile.sink.add;

  EditPersonalInfoCubit(this._authRemoteRepository)
      : super(EditPersonalInfoInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _name.close();
    _selectedGender.close();
    _date.close();
    _month.close();
    _year.close();
    _isWhatsappSubscribed.close();
    _userProfile.close();
    return super.close();
  }

  void updateSelectedLanguage() {
    var languageList = _selectLanguageCubit.languageList;
    var tempLanguageList = <Languages>[];
    for (var language in languageList) {
      if (language.isSelected) {
        tempLanguageList.add(language);
      }
    }
    if (!_selectedLanguages.isClosed) {
      _selectedLanguages.sink.add(tempLanguageList);
    }
  }

  void changeSelectedLanguages(List<Languages>? languages) {
    if (!_selectedLanguages.isClosed) {
      _selectedLanguages.sink.add(languages);
    }
    _selectLanguageCubit.updateSelectedLanguageList(languages);
  }

  void updateUserProfile(int? userID, String? email) async {
    try {
      if (Validator.checkName(_name.hasValue ? _name.value : '') != null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage:
                Validator.checkName(_name.hasValue ? _name.value : '')!));
        return;
      }
      if (_selectedGender.value == null) {
        changeUIStatus(
            UIStatus(failedWithoutAlertMessage: 'please_select_gender'.tr));
        return;
      }
      if (Validator.checkDateOfBirth(_date.value, _month.value, _year.value) !=
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: Validator.checkDateOfBirth(
                _date.value, _month.value, _year.value)!));
        return;
      }
      if (_selectedLanguages.value == null) {
        changeUIStatus(
            UIStatus(failedWithoutAlertMessage: 'please_select_language'.tr));
        return;
      }
      if (_selectedLanguages.value!.isEmpty) {
        changeUIStatus(
            UIStatus(failedWithoutAlertMessage: 'please_select_language'.tr));
        return;
      }
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      String? dayMonth = _date.value;
      if (dayMonth!.length == 1) {
        dayMonth = '0$dayMonth';
      }
      String? month = _month.value;
      if (month!.length == 1) {
        month = '0$month';
      }
      String date = '${_year.value}-$month-$dayMonth';
      ApiResponse apiResponse = await _authRemoteRepository.updateUserProfile(
          userID,
          _name.value,
          email,
          _selectedGender.value,
          null,
          date,
          null,
          null,
          null);
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
      AppLog.e('updateUserProfile : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void subscribeWhatsapp(int userID) async {
    try {
      ApiResponse apiResponse =
          await _authRemoteRepository.subscribeWhatsapp(userID);
      changeUIStatus(
          UIStatus(successWithoutAlertMessage: 'successfully_enabled'.tr));
    } catch (e, st) {
      AppLog.e('subscribeWhatsapp : ${e.toString()} \n${st.toString()}');
    }
  }

  void unSubscribeWhatsapp(int userID) async {
    try {
      ApiResponse apiResponse =
          await _authRemoteRepository.unSubscribeWhatsapp(userID);
      changeUIStatus(
          UIStatus(successWithoutAlertMessage: apiResponse.message ?? ''));
    } catch (e, st) {
      AppLog.e('unSubscribeWhatsapp : ${e.toString()} \n${st.toString()}');
    }
  }

  void updateLanguages(int? userID) async {
    try {
      ApiResponse apiResponse = await _authRemoteRepository.updateLanguages(
          userID, _selectedLanguages.value);
    } catch (e) {
      AppLog.e('updateLanguages : ${e.toString()}');
    }
  }

  void getUserProfile(int? userID) async {
    try {
      changeUIStatus(UIStatus(isOnScreenLoading: true));
      UserProfileResponse userProfileResponse =
          await _authRemoteRepository.getUserProfile(userID);
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? currentUser = spUtil?.getUserData();
      currentUser?.userProfile = userProfileResponse.userProfile;
      spUtil?.putUserData(currentUser);
      if (currentUser != null && currentUser.userProfile != null) {
        changeUserProfile(currentUser.userProfile!);
      }
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getUserProfile : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
