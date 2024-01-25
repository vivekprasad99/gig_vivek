import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'code_scanner_state.dart';

class CodeScannerCubit extends Cubit<CodeScannerState> {

  final _delayedText = BehaviorSubject<String?>();
  Stream<String?> get delayedText => _delayedText.stream;
  Function(String?) get changeDelayedText => _delayedText.sink.add;

  CodeScannerCubit() : super(CodeScannerInitial());
}
