import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'location_captured_bottom_sheet_state.dart';

class LocationCapturedBottomSheetCubit extends Cubit<LocationCapturedBottomSheetState> {

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());
  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  LocationCapturedBottomSheetCubit() : super(LocationCapturedBottomSheetInitial());
}
