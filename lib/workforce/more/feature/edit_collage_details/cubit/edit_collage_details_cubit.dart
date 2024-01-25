import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/validator.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'edit_collage_details_state.dart';

class EditCollageDetailsCubit extends Cubit<EditCollageDetailsState>
    with Validator {
  final AuthRemoteRepository _authRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _collageName = BehaviorSubject<String?>();

  Stream<String?> get collageName =>
      _collageName.stream.transform(validCollageName);

  Function(String?) get changeCollageName => _collageName.sink.add;

  final _fieldOfStudy = BehaviorSubject<String?>();

  Stream<String?> get fieldOfStudy =>
      _fieldOfStudy.stream.transform(validFieldOfStudy);

  Function(String?) get changeFieldOfStudy => _fieldOfStudy.sink.add;

  final _isOtherStream = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isOtherStream => _isOtherStream.stream;

  Function(bool) get changeIsOtherStream => _isOtherStream.sink.add;

  final _otherStream = BehaviorSubject<String?>();

  Stream<String?> get otherStream =>
      _otherStream.stream.transform(validOtherStream);

  Function(String?) get changeOtherStream => _otherStream.sink.add;

  final _startYear = BehaviorSubject<String?>();

  Stream<String?> get startYear => _startYear.stream.transform(validStartYear);

  Function(String?) get changeStartYear => _startYear.sink.add;

  final _endYear = BehaviorSubject<String?>();

  Stream<String?> get endYear => _endYear.stream.transform(validEndYear);

  Function(String?) get changeEndYear => _endYear.sink.add;

  final _selectedEducationLevel = BehaviorSubject<String?>();

  Stream<String?> get selectedEducationLevel => _selectedEducationLevel.stream;

  Function(String?) get changeSelectedEducationLevel =>
      _selectedEducationLevel.sink.add;

  EditCollageDetailsCubit(this._authRemoteRepository)
      : super(EditCollageDetailsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    return super.close();
  }

  void createOrUpdateEducation(int? userID, Education? education) async {
    try {
      if (Validator.checkCollageName(
              _collageName.hasValue ? _collageName.value : '') !=
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: Validator.checkCollageName(
                _collageName.hasValue ? _collageName.value : '')!));
        return;
      }
      if (Validator.checkFieldOfStudy(
              _fieldOfStudy.hasValue ? _fieldOfStudy.value : '') !=
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: Validator.checkFieldOfStudy(
                _fieldOfStudy.hasValue ? _fieldOfStudy.value : '')!));
        return;
      }
      if (_isOtherStream.value) {
        if (Validator.checkOtherStream(
                _otherStream.hasValue ? _otherStream.value : '') !=
            null) {
          changeUIStatus(UIStatus(
              failedWithoutAlertMessage: Validator.checkOtherStream(
                  _otherStream.hasValue ? _otherStream.value : '')!));
          return;
        }
      }
      if (Validator.checkStartYear(
              _startYear.hasValue ? _startYear.value : '') !=
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: Validator.checkStartYear(
                _startYear.hasValue ? _startYear.value : '')!));
        return;
      }
      if (Validator.checkEndYear(_endYear.hasValue ? _endYear.value : '') !=
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: Validator.checkEndYear(
                _endYear.hasValue ? _endYear.value : '')!));
        return;
      }
      if (Validator.checkStartYearAndEndYear(
              _startYear.value!, _endYear.value!) !=
          null) {
        changeUIStatus(UIStatus(
            failedWithoutAlertMessage: Validator.checkStartYearAndEndYear(
                _startYear.value!, _endYear.value!)!));
        return;
      }
      if (education?.id == null) {
        education = Education(
            collegeName: _collageName.value,
            fieldOfStudy: _fieldOfStudy.value,
            fromYear: _startYear.value,
            toYear: _endYear.value);
        changeUIStatus(
            UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
        Tuple2<ApiResponse, String?> tuple2 =
            await _authRemoteRepository.createEducation(userID, education);
        changeUIStatus(UIStatus(
            isDialogLoading: false,
            event: Event.created,
            successWithoutAlertMessage: tuple2.item2 ?? ''));
      } else {
        education ??= Education(
            collegeName: _collageName.value,
            fieldOfStudy: _fieldOfStudy.value,
            fromYear: _startYear.value,
            toYear: _endYear.value);
        education.collegeName = _collageName.value;
        education.fieldOfStudy = _fieldOfStudy.value;
        education.fromYear = _startYear.value;
        education.toYear = _endYear.value;
        changeUIStatus(
            UIStatus(isDialogLoading: true, loadingMessage: 'please_wait'.tr));
        Tuple2<ApiResponse, String?> tuple2 = await _authRemoteRepository
            .updateEducation(userID, education.id, education);
        changeUIStatus(UIStatus(
            isDialogLoading: false,
            event: Event.updated,
            successWithoutAlertMessage: tuple2.item2 ?? ''));
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isDialogLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('createEducation : ${e.toString()}');
      changeUIStatus(UIStatus(
          isDialogLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
