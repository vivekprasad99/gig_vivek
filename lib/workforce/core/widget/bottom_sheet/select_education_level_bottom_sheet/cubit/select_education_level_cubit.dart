import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'select_education_level_state.dart';

class SelectEducationLevelCubit extends Cubit<SelectEducationLevelState> {
  SelectEducationLevelCubit() : super(SelectEducationLevelInitial());

  final _selectedEducationLevel = BehaviorSubject<int?>();
  Stream<int?> get selectedEducationLevel => _selectedEducationLevel.stream;
  String get educationLevel => levelArray[_selectedEducationLevel.value! - 1];

  Function(int?) get changeSelectedEducationLevel =>
      _selectedEducationLevel.sink.add;
  var levelArray = [
    'below_10th'.tr,
    '10th_pass'.tr,
    '12th_pass'.tr,
    'pursuing_graduation'.tr,
    'graduate'.tr,
    'post_graduate'.tr
  ];

  void updateSelectedEducationLevel(String educationLevel) {
    for(int i = 0; i < levelArray.length; i++) {
      if(levelArray[i] == educationLevel) {
        changeSelectedEducationLevel(i + 1);
        break;
      }
    }
  }

  @override
  Future<void> close() {
    _selectedEducationLevel.close();
    return super.close();
  }
}
