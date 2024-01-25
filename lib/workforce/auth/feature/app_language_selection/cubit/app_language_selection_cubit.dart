import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:rxdart/rxdart.dart';

part 'app_language_selection_state.dart';

class AppLanguageSelectionCubit extends Cubit<AppLanguageSelectionState> {
  final AuthRemoteRepository _authRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _selectedLanguage = BehaviorSubject<String?>();
  Stream<String?> get selectedLanguage => _selectedLanguage.stream;
  Function(String?) get changeSelectedLanguage => _selectedLanguage.sink.add;

  AppLanguageSelectionCubit(this._authRemoteRepository) : super(AppLanguageSelectionInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    return super.close();
  }

  void setAppLanguage(String langCode) async {
    try {
      changeUIStatus(
          UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
      SPUtil? spUtil = await SPUtil?.getInstance();
      spUtil?.putAppLanguage(langCode);
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          event: Event.updated,
          successWithoutAlertMessage: ''));
    } catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}