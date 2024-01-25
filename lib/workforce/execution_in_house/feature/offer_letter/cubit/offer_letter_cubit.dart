import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/execution_in_house/data/repository/execution_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'offer_letter_state.dart';

class OfferLetterCubit extends Cubit<OfferLetterState> {
  final ExecutionRemoteRepository _executionRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  OfferLetterCubit(this._executionRemoteRepository)
      : super(OfferLetterInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    return super.close();
  }
}
