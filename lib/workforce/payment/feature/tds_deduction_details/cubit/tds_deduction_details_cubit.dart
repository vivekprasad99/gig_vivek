import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'tds_deduction_details_state.dart';

class TdsDeductionDetailsCubit extends Cubit<TdsDeductionDetailsState> {
  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _tdsRuleListWithoutPAN = BehaviorSubject<List<String>>();

  Stream<List<String>> get tdsRuleListWithoutPAN =>
      _tdsRuleListWithoutPAN.stream;

  Function(List<String>) get changeTdsRuleListWithoutPAN =>
      _tdsRuleListWithoutPAN.sink.add;

  final _tdsRuleListWithPAN = BehaviorSubject<List<String>>();

  Stream<List<String>> get tdsRuleListWithPAN => _tdsRuleListWithPAN.stream;

  Function(List<String>) get changeTdsRuleListWithPAN =>
      _tdsRuleListWithPAN.sink.add;

  final _tdsNote = BehaviorSubject<String>();

  Stream<String> get tdsNote => _tdsNote.stream;

  Function(String) get changeTdsNote => _tdsNote.sink.add;

  TdsDeductionDetailsCubit() : super(TdsDeductionDetailsInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _tdsRuleListWithoutPAN.close();
    _tdsRuleListWithPAN.close();
    _tdsNote.close();
    return super.close();
  }
}
