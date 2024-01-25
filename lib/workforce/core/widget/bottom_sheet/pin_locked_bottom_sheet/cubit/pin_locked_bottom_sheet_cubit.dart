import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'pin_locked_bottom_sheet_state.dart';

class PinLockedBottomSheetCubit extends Cubit<PinLockedBottomSheetState> {
  final _duration = BehaviorSubject<Duration>.seeded(Duration());

  Stream<Duration> get duration => _duration.stream;

  Duration get durationValue => _duration.value;

  Function(Duration) get changeDuration => _duration.sink.add;

  final _currentUser = BehaviorSubject<UserData>();

  Stream<UserData> get currentUser => _currentUser.stream;

  Function(UserData) get changeCurrentUser => _currentUser.sink.add;

  PinLockedBottomSheetCubit() : super(PinLockedBottomSheetInitial());

  @override
  Future<void> close() {
    _duration.close();
    _currentUser.close();
    return super.close();
  }
}
