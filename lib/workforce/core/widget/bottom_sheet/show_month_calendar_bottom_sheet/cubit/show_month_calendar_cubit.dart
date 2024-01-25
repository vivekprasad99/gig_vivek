import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/more/feature/leaderboard/data/model/leaderboard_widget_data.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'show_month_calendar_state.dart';

class ShowMonthCalendarCubit extends Cubit<ShowMonthCalendarState> {

  final _monthDataList = BehaviorSubject<List<MonthData>>();
  Stream<List<MonthData>> get monthDataListStream => _monthDataList.stream;
  List<MonthData> get monthDataList => _monthDataList.value;
  Function(List<MonthData>) get changeMonthDataList => _monthDataList.sink.add;

  final _getMonth = BehaviorSubject<String?>.seeded(StringUtils.getMonth(DateTime.now()));
  Stream<String?> get getMonthStream => _getMonth.stream;
  String? get getMonthValue => _getMonth.value;
  Function(String?) get changeGetMonth => _getMonth.sink.add;

  ShowMonthCalendarCubit() : super(ShowMonthCalendarInitial()){
    loadMonthList();
  }

  void loadMonthList()
  {
    var monthList = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    var monthDataList = <MonthData>[];
    for (var name in monthList) {
      var monthData = MonthData(monthItem: name);
      monthDataList.add(monthData);
    }
    if(!_monthDataList.isClosed) {
      _monthDataList.sink.add(monthDataList);
    }
  }
}
