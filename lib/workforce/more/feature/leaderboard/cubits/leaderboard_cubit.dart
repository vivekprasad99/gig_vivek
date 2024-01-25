import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/more/data/model/earning_response.dart';
import 'package:awign/workforce/more/data/model/user_certificate_response.dart';
import 'package:awign/workforce/more/data/model/user_earning_response.dart';
import 'package:awign/workforce/more/data/repository/leaderboard/leaderboard_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/remote/capture_event/capture_event_helper.dart';
import '../../../../core/data/remote/capture_event/logging_data.dart';
import '../data/model/leaderboard_widget_data.dart';

part 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  final LeaderBoardRemoteRepository _leaderBoardRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _navBarDataList = BehaviorSubject<List<NavBarData>>();
  Stream<List<NavBarData>> get navBarDataListStream => _navBarDataList.stream;
  List<NavBarData> get navBarDataList => _navBarDataList.value;
  Function(List<NavBarData>) get changeNavBarDataList =>
      _navBarDataList.sink.add;

  final _getMonth =
      BehaviorSubject<String?>.seeded(StringUtils.getMonthAndYear());
  Stream<String?> get getMonthStream => _getMonth.stream;
  String? get getMonthValue => _getMonth.value;
  Function(String?) get changeGetMonth => _getMonth.sink.add;

  final _userEarningResponse = BehaviorSubject<EarningResponse>();
  Stream<EarningResponse> get userEarningResponseResponseStream =>
      _userEarningResponse.stream;
  EarningResponse get userEarningResponse => _userEarningResponse.value;
  Function(EarningResponse) get changeUserEarningResponse =>
      _userEarningResponse.sink.add;

  final _userEarning = BehaviorSubject<UserEarningResponse>();
  Stream<UserEarningResponse> get userEarningStream => _userEarning.stream;
  UserEarningResponse get userEarning => _userEarning.value;
  Function(UserEarningResponse) get changeUserEarning => _userEarning.sink.add;

  final _userCertificate = BehaviorSubject<UserCertificateResponse>();
  Stream<UserCertificateResponse> get userCertificateStream =>
      _userCertificate.stream;
  UserCertificateResponse get userCertificate => _userCertificate.value;
  Function(UserCertificateResponse) get changeUserCertificate =>
      _userCertificate.sink.add;

  final _navBarItemSelected = BehaviorSubject<String?>.seeded(Constants.earning);
  Stream<String?> get navBarItemSelectedStream => _navBarItemSelected.stream;
  String? get navBarItemSelectedValue => _navBarItemSelected.value;
  Function(String?) get changeNavBarItemSelected =>
      _navBarItemSelected.sink.add;

  NavBarData? selectedLeaderBoardCategory;

  @override
  Future<void> close() {
    _uiStatus.close();
    _navBarDataList.close();
    _getMonth.close();
    _userEarningResponse.close();
    _userEarning.close();
    _userCertificate.close();
    _navBarItemSelected.close();
    return super.close();
  }

  LeaderboardCubit(this._leaderBoardRemoteRepository)
      : super(LeaderboardInitial()) {
    loadNavBarList();
  }

  void loadNavBarList() {
    var navBarItem = [
      "Earnings",
      // "Jobs onboarded",
      "Task completed"
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
      selectedLeaderBoardCategory = navBarData;
    }
    return;
  }

  void getNextMonth(String date) async {
    SPUtil? spUtil = await SPUtil.getInstance();
    UserData? user = spUtil?.getUserData();
    DateTime dateTime = convertStringToDate(date);
    var newDate = DateTime(dateTime.year, dateTime.month + 1, dateTime.day);
    String formattedDate = DateFormat(StringUtils.dateFormatMY).format(newDate);
    getTopEarnerList(
        "${newDate.year}", "${newDate.month}", _navBarItemSelected.value!);
    getUserEarning(
        newDate.year, newDate.month, user!.id, _navBarItemSelected.value!);
    getUserCertificate(
        newDate.year, newDate.month, user.id, _navBarItemSelected.value!);
    _getMonth.sink.add(formattedDate);
  }

  void getPreviousMonth(String date) async {
    SPUtil? spUtil = await SPUtil.getInstance();
    UserData? user = spUtil?.getUserData();
    DateTime dateTime = convertStringToDate(date);
    var newDate = DateTime(dateTime.year, dateTime.month - 1, dateTime.day);
    String formattedDate = DateFormat(StringUtils.dateFormatMY).format(newDate);
    getTopEarnerList(
        "${newDate.year}", "${newDate.month}", _navBarItemSelected.value!);
    getUserEarning(
        newDate.year, newDate.month, user!.id, _navBarItemSelected.value!);
    getUserCertificate(
        newDate.year, newDate.month, user.id, _navBarItemSelected.value!);
    _getMonth.sink.add(formattedDate);
  }

  DateTime convertStringToDate(String date) {
    DateFormat format = DateFormat.yMMM();
    return format.parse(date);
  }

  Future getTopEarnerList(String year, String month, String navBarItem) async {
    try {
      EarningResponse data = await _leaderBoardRemoteRepository
          .getTopEarnerList(year, month, navBarItem);
      if (!_userEarningResponse.isClosed) {
        _userEarningResponse.sink.add(data);
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('getTopEarnerList : ${e.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  Future getUserEarning(int year, int month, int? id, String navBarItem) async {
    try {
      UserEarningResponse data = await _leaderBoardRemoteRepository
          .getUserEarning(year, month, id, navBarItem);
      if (!_userEarning.isClosed) {
        _userEarning.sink.add(data);
      }
      if(data.rank! <= 5 && StringUtils.getMonthAndYear() == getMonthValue)
        {
          changeUIStatus(UIStatus(event: Event.success,data: data.rank));
        }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('getUserEarning : ${e.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  Future getUserCertificate(
      int year, int month, int? id, String navBarItem) async {
    try {
      if(userEarning.performance == Constants.good || userEarning.performance == Constants.excellent) {
        UserCertificateResponse data = await _leaderBoardRemoteRepository
            .getUserCertificate(year, month, id, navBarItem);
        if (!_userCertificate.isClosed) {
          _userCertificate.sink.add(data);
          if (navBarItem == Constants.earning && data.urls?.imageUrl != null) {
            if (userEarning.performance == Constants.good) {
              CaptureEventHelper.captureEvent(
                  loggingData: LoggingData(
                      event: LoggingEvents.usersReceivedGoodEarningsCertificate,
                      pageName: "Leaderboard",
                      sectionName: "Profile",
                      otherProperty: {
                        "monthID": month.toString(),
                        "yearID": year.toString()
                      })
              );
            } else if (userEarning.performance == Constants.excellent) {
              CaptureEventHelper.captureEvent(
                  loggingData: LoggingData(
                      event: LoggingEvents
                          .usersReceivedExcellentEarningsCertificate,
                      pageName: "Leaderboard",
                      sectionName: "Profile",
                      otherProperty: {
                        "monthID": month.toString(),
                        "yearID": year.toString()
                      })
              );
            }
          } else if (navBarItem == Constants.taskCompleted &&
              data.urls?.imageUrl != null) {
            if (userEarning.performance == Constants.good) {
              CaptureEventHelper.captureEvent(
                  loggingData: LoggingData(
                      event: LoggingEvents.usersReceivedGoodTasksCertificate,
                      pageName: "Leaderboard",
                      sectionName: "Profile",
                      otherProperty: {
                        "monthID": month.toString(),
                        "yearID": year.toString()
                      })
              );
            } else if (userEarning.performance == Constants.excellent) {
              CaptureEventHelper.captureEvent(
                  loggingData: LoggingData(
                      event: LoggingEvents
                          .usersReceivedExcellentTasksCertificate,
                      pageName: "Leaderboard",
                      sectionName: "Profile",
                      otherProperty: {
                        "monthID": month.toString(),
                        "yearID": year.toString()
                      })
              );
            }
          }
        }
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
      _userCertificate.sink.addError(e);
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('getUserCertificate : ${e.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
