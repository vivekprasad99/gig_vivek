import 'package:awign/workforce/auth/data/model/profile_attributes_and_application_questions.dart';
import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/data/model/profile_attributes.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../../core/data/local/shared_preference_utils.dart';

part 'my_profile_state.dart';

class MyProfileCubit extends Cubit<MyProfileState> {
  final AuthRemoteRepository _authRemoteRepository;
  final WosRemoteRepository _wosRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _userProfileResponse = BehaviorSubject<UserProfileResponse>();
  Stream<UserProfileResponse> get userProfileResponse =>
      _userProfileResponse.stream;

  final _profileAttributesResponse =
      BehaviorSubject<ProfileAttributesResponse>();
  Stream<ProfileAttributesResponse> get profileAttributesResponse =>
      _profileAttributesResponse.stream;

  final _questionList = BehaviorSubject<List<Question>>();
  Stream<List<Question>> get questionList => _questionList.stream;

  final _profileAttributesAndApplicationQuestions =
      BehaviorSubject<ProfileAttributesAndApplicationQuestions>();
  Stream<ProfileAttributesAndApplicationQuestions>
      get profileAttributesAndApplicationQuestions =>
          _profileAttributesAndApplicationQuestions.stream;

  final _nudgePercentage = BehaviorSubject<int>();
  Stream<int> get nudgePercentage => _nudgePercentage.stream;
  Function(int) get changenudgePercentage => _nudgePercentage.sink.add;

  MyProfileCubit(this._authRemoteRepository, this._wosRemoteRepository)
      : super(MyProfileInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _userProfileResponse.close();
    _nudgePercentage.close();
    return super.close();
  }

  void getProfileAndAttributes(int? userID) async {
    Rx.combineLatest3(
      _userProfileResponse.stream,
      _profileAttributesResponse.stream,
      _questionList.stream,
      (UserProfileResponse userProfileResponse,
          ProfileAttributesResponse profileAttributesResponse,
          List<Question> questions) {
        return Tuple3(
            userProfileResponse, profileAttributesResponse, questions);
      },
    ).listen((tuple3) async {
      if (tuple3.item2.profileAttributes != null &&
          !_profileAttributesAndApplicationQuestions.isClosed) {
        ProfileAttributesAndApplicationQuestions
            profileAttributesAndApplicationQuestions =
            ProfileAttributesAndApplicationQuestions(
                questions: tuple3.item3,
                userProfileAttributes: tuple3.item2.profileAttributes!);
        _profileAttributesAndApplicationQuestions.sink
            .add(profileAttributesAndApplicationQuestions);
        changenudgePercentage(
            tuple3.item1.userProfile?.profileCompletionPercentage ?? 20);
      }
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    });
    getUserProfile(userID);
    searchProfileAttributes(userID);
    getApplicationQuestions(userID);
  }

  void getUserProfile(int? userID) async {
    try {
      changeUIStatus(UIStatus(isOnScreenLoading: true));
      UserProfileResponse userProfileResponse =
          await _authRemoteRepository.getUserProfile(userID);
      if (!_userProfileResponse.isClosed) {
        SPUtil? spUtil = await SPUtil.getInstance();
        UserData? currentUser = spUtil?.getUserData();
        currentUser?.userProfile?.profileCompletionPercentage =
            userProfileResponse.userProfile?.profileCompletionPercentage;
        spUtil?.putUserData(currentUser);
        userProfileResponse.currentUser = currentUser;
        _userProfileResponse.sink.add(userProfileResponse);
      }
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

  void searchProfileAttributes(int? userID) async {
    try {
      changeUIStatus(UIStatus(isOnScreenLoading: true));
      Tuple2<ProfileAttributesResponse, String?> tuple2 =
          await _authRemoteRepository.searchProfileAttributes(userID);
      if (!_profileAttributesResponse.isClosed) {
        _profileAttributesResponse.sink.add(tuple2.item1);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('searchProfileAttributes : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void getApplicationQuestions(int? userID) async {
    try {
      changeUIStatus(UIStatus(isOnScreenLoading: true));
      List<Question> questions =
          await _wosRemoteRepository.getApplicationQuestions(userID);
      if (!_questionList.isClosed) {
        _questionList.sink.add(questions);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('getApplicationQuestions : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  bool isProfileSectionComplete(UserProfile? userProfile) {
    if (userProfile == null) return false;
    return (userProfile.name.isNullOrEmpty &&
        userProfile.mobileNumber.isNullOrEmpty &&
        userProfile.email.isNullOrEmpty &&
        userProfile.gender != null &&
        userProfile.dob.isNullOrEmpty &&
        userProfile.languages.isNullOrEmpty);
  }

  bool isAddressSectionComplete(UserProfile? userProfile) {
    if (userProfile == null) return false;
    if (userProfile.addresses == null) return false;
    for (int i = 0; i < userProfile.addresses!.length; i++) {
      if (userProfile.addresses![i].area.isNullOrEmpty &&
          userProfile.addresses![i].city.isNullOrEmpty &&
          userProfile.addresses![i].state.isNullOrEmpty &&
          userProfile.addresses![i].pincode.isNullOrEmpty) {
        return true;
      }
    }
    return false;
  }

  bool isCollegeSectionComplete(UserProfile? userProfile) {
    if (userProfile == null) return false;
    if (userProfile.education == null) return false;
    return (userProfile.education!.collegeName.isNullOrEmpty &&
        userProfile.education!.fieldOfStudy.isNullOrEmpty &&
        userProfile.education!.fromYear.isNullOrEmpty &&
        userProfile.education!.toYear.isNullOrEmpty);
  }

  bool isProfessionalDetailSectionComplete(UserProfile? userProfile) {
    if (userProfile == null) return false;
    return (userProfile.educationLevel.isNullOrEmpty &&
        userProfile.professionalExperiences.isNullOrEmpty);
  }

  bool isOtherDetailsSectionComplete(
      ProfileAttributesAndApplicationQuestions? data) {
    if (data == null) return false;
    var profileQuestionAnsweredCount = 0;
    var profileQuestionCount = 0;
    for (int i = 0; i < data.questions.length; i++) {
      Question question = data.questions[i];
      if (question.configuration?.attributeName != null) {
        profileQuestionCount++;
      }
    }
    for (int i = 0; i < data.questions.length; i++) {
      Question question = data.questions[i];
      if (question.configuration?.attributeName == null) {
        continue;
      } else {
        ProfileAttributes? profileAttributes =
            ProfileAttributes.getProfileAttribute(
                question.configuration?.attributeName,
                data.userProfileAttributes);
        if (profileAttributes?.attributeName.isNullOrEmpty == false) {
          profileQuestionAnsweredCount++;
        }
      }
    }
    return !(profileQuestionCount == profileQuestionAnsweredCount);
  }

  bool isCollegeDetailsVisible(UserProfile? userProfile) {
    if (userProfile == null) return false;
    return !(userProfile.educationLevel == "Below 10th" ||
        userProfile.educationLevel == "10th Pass" ||
        userProfile.educationLevel == "12th Pass");
  }
}
