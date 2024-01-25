import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_education_level_bottom_sheet/cubit/select_education_level_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/cubit/select_working_domain_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/model/working_domain.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'edit_professional_details_state.dart';

class EditProfessionalDetailsCubit extends Cubit<EditProfessionalDetailsState>
    with Validator {
  final AuthRemoteRepository _authRemoteRepository;
  final _selectEducationLevelCubit = sl<SelectEducationLevelCubit>();
  final _selectWorkingDomainCubit = sl<SelectWorkingDomainCubit>();

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _selectedEducationLevel = BehaviorSubject<String?>();

  Stream<String?> get selectedEducationLevel => _selectedEducationLevel.stream;

  // Function(String?) get changeSelectedEducationLevel => _selectedEducationLevel.sink.add;

  void changeSelectedEducationLevel(String selectedEducationLevel) {
    _selectedEducationLevel.sink.add(selectedEducationLevel);
    _selectEducationLevelCubit
        .updateSelectedEducationLevel(selectedEducationLevel);
  }

  final _selectedWorkingDomainList = BehaviorSubject<List<WorkingDomain>?>();

  Stream<List<WorkingDomain>?> get selectedWorkingDomainList =>
      _selectedWorkingDomainList.stream;

  Function(List<WorkingDomain>?) get changeSelectedWorkingDomainList =>
      _selectedWorkingDomainList.sink.add;

  EditProfessionalDetailsCubit(this._authRemoteRepository)
      : super(EditProfessionalDetailsInitial());

  void updateSelectedWorkingDomainList(
      List<ProfessionalExperiences> professionalExperiences) {
    var list = <WorkingDomain>[];
    for (int i = 0; i < professionalExperiences.length; i++) {
      var item = WorkingDomain(
          name: (professionalExperiences[i].skill ?? '').toCapitalized(),
          isSelected: true);
      list.add(item);
    }
    changeSelectedWorkingDomainList(list);
    _selectWorkingDomainCubit.updateSelectedWorkingDomainList(list);
  }

  @override
  Future<void> close() {
    _uiStatus.close();
    return super.close();
  }

  void updateProfessionalDetails(int? userID, UserProfile userProfile) async {
    try {
      if ((_selectedEducationLevel.hasValue
              ? _selectedEducationLevel.value
              : null) ==
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: 'please_select_education_level'.tr));
        return;
      }

      if ((_selectedWorkingDomainList.valueOrNull == null ||
          _selectedWorkingDomainList.value!.isEmpty)) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: 'please_select_your_domain'.tr));
        return;
      }
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      _updateProfessionalExperiences(userID);
      ApiResponse apiResponse = await _authRemoteRepository.updateUserProfile(
          userID,
          userProfile.name,
          userProfile.email,
          userProfile.gender,
          _selectedEducationLevel.value,
          userProfile.dob,
          null,
          null,
          _selectedWorkingDomainList.value!.isNotEmpty);
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
    } catch (e) {
      AppLog.e('updateProfessionalDetails : ${e.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void _updateProfessionalExperiences(int? userID) async {
    try {
      ApiResponse apiResponse =
          await _authRemoteRepository.updateProfessionalExperiences(
              userID, _selectedWorkingDomainList.value ?? []);
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
}
