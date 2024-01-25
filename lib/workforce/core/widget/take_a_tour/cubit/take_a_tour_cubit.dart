import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'take_a_tour_state.dart';

class TakeATourCubit extends Cubit<TakeATourState> {
  final _isSelected = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isSelected => _isSelected.stream;
  Function(bool) get changeisSelected => _isSelected.sink.add;

  TakeATourCubit() : super(TakeATourInitial());
}
