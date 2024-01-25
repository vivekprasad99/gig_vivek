import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'select_month_year_state.dart';

class SelectMonthYearCubit extends Cubit<SelectMonthYearState> {
  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _monthYearList = BehaviorSubject<List<String>>();

  Stream<List<String>> get monthYearList => _monthYearList.stream;

  SelectMonthYearCubit() : super(SelectMonthYearInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _monthYearList.close();
    return super.close();
  }

  loadMonthYearList() {
    List<String> monthYearList = [];
    DateTime now = DateTime.now();
    int curDate = now.day;
    int curTime = now.hour;
    var myDateFormat = DateFormat(StringUtils.dateFormatMY);
    for (int i = 0; i < 12; i++) {
      DateTime dateTime =
          DateTime(now.year, now.month - i, now.day, now.hour, now.minute);
      var monthYear = myDateFormat.format(dateTime);
      if (i != 0) {
        monthYearList.add(monthYear);
      }
    }
    if (curDate == 1 && curTime < 12) {
      monthYearList.removeAt(0);
    }
    if (!_monthYearList.isClosed) {
      _monthYearList.sink.add(monthYearList);
    }
  }
}
