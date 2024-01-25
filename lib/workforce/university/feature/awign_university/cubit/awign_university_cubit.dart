import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/university/data/model/navbar_item.dart';
import 'package:awign/workforce/university/data/model/university_request.dart';
import 'package:awign/workforce/university/data/repository/university/university_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:developer';

import '../../../data/model/university_entity.dart';

part 'awign_university_state.dart';

class AwignUniversityCubit extends Cubit<AwignUniversityState> {
  final UniversityRemoteRepository _universityRemoteRepository;
  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _courseSkillFilter = BehaviorSubject<String>.seeded("All");
  Stream<String> get courseSkillFilterStream => _courseSkillFilter.stream;
  String get courseSkillFilterValue => _courseSkillFilter.value;
  Function(String) get changeCourseSkillFilter => _courseSkillFilter.sink.add;

  final _navBarDataList = BehaviorSubject<List<NavBarData>>();
  Stream<List<NavBarData>> get navBarDataListStream => _navBarDataList.stream;
  List<NavBarData> get navBarDataList => _navBarDataList.value;
  Function(List<NavBarData>) get changeNavBarDataList =>
      _navBarDataList.sink.add;

  final _courseResponse = BehaviorSubject<CourseResponse>();
  Stream<CourseResponse> get courseResponseStream => _courseResponse.stream;
  CourseResponse get courseResponse => _courseResponse.value;
  Function(CourseResponse) get changeCourseResponse => _courseResponse.sink.add;

  final _currentUser = BehaviorSubject<UserData>();
  Stream<UserData> get currentUser => _currentUser.stream;
  Function(UserData) get changeCurrentUser => _currentUser.sink.add;

  NavBarData? selectedCourseCategory;

  AwignUniversityCubit(this._universityRemoteRepository)
      : super(AwignUniversityInitial()) {
    loadNavBarList();
  }

  void loadNavBarList() {
    var navBarItem = [
      "All",
      "Exam Invigilation",
      "Due Diligence",
      "Last Mile Ops",
      "Audits",
      "Online Proctoring",
      "Content & Data Operations",
      "Business Development",
      "Telecalling",
      "Others",
      "For Students"
    ];

    var navBarDataList = <NavBarData>[];
    for (int i = 0; i < navBarItem.length; i++) {
      if (i == 0) {
        var navBarData =
            NavBarData(navBarItem: navBarItem[i], isSelected: true);
        navBarDataList.add(navBarData);
      } else {
        var navBarData = NavBarData(navBarItem: navBarItem[i]);
        navBarDataList.add(navBarData);
      }
    }
    if (!_navBarDataList.isClosed) {
      _navBarDataList.sink.add(navBarDataList);
    }
  }

  void updateNavBar(int index, NavBarData navBarData) {
    var navBarDataList = _navBarDataList.value;
    var navBarData = navBarDataList[index];
    for (var name in navBarDataList) {
      name.isSelected = false;
    }
    if (!navBarDataList[index].isSelected) {
      navBarDataList[index].navBarItem = navBarData.navBarItem;
      navBarDataList[index].isSelected = true;
      _navBarDataList.sink.add(navBarDataList);
      selectedCourseCategory = navBarData;
    }
    return;
  }

  Future<List<CoursesEntity>?> getCourseList(
      int pageIndex, String? searchTerm) async {
    AppLog.e('Page index......$pageIndex');
    try {
      String? courseFilter =
          courseSkillFilterValue == "All" ? null : courseSkillFilterValue;
      UniversityData? data = await _universityRemoteRepository.getCourseList(
          UniversityRequest(
              courseCategoryFilter: selectedCourseCategory == null ||
                      selectedCourseCategory!.navBarItem == 'All'
                  ? null
                  : selectedCourseCategory!.navBarItem!,
              courseSkillFilter: courseFilter),
          pageIndex);
      return data!.courseList;
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('getCourseList : ${e.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  Future<CourseResponse?> getCourse(int courseId) async {
    try {
      CourseResponse? data =
          await _universityRemoteRepository.getCourse(courseId);
      _courseResponse.sink.add(data!);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('getCourse : ${e.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  Future<CourseResponse?> updateViews(int courseId) async {
    try {
      var data = await _universityRemoteRepository.updateViews(courseId);
      changeUIStatus(UIStatus(isDialogLoading: false, event: Event.success));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('updateViews : ${e.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
