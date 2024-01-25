import 'package:awign/workforce/core/widget/bottom_sheet/select_language_bottom_sheet/model/language.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'select_language_state.dart';

class SelectLanguageCubit extends Cubit<SelectLanguageState> {
  SelectLanguageCubit() : super(SelectLanguageInitial()) {
    loadLanguageList();
  }

  final _languageList = BehaviorSubject<List<Languages>>();
  Stream<List<Languages>> get languageListStream => _languageList.stream;
  List<Languages> get languageList => _languageList.value;
  Function(List<Languages>) get changeLanguageList => _languageList.sink.add;

  @override
  Future<void> close() {
    _languageList.close();
    return super.close();
  }

  void loadLanguageList() {
    var languageArray = [
      'hindi'.tr,
      'english'.tr,
      'bengali'.tr,
      'marathi'.tr,
      'tamil'.tr,
      'gujarati'.tr,
      'urdu'.tr,
      'telugu'.tr,
      'kannada'.tr,
      'odia'.tr,
      'malayalam'.tr,
      'panjabi'.tr,
      'assamese'.tr,
      'maithili'.tr,
      'sanskrit'.tr
    ];
    var languageList = <Languages>[];
    for (var name in languageArray) {
      var language = Languages(name: name);
      languageList.add(language);
    }
    if(!_languageList.isClosed) {
      _languageList.sink.add(languageList);
    }
  }

  void updateLanguageList(int index, Languages language) {
    if(!_languageList.isClosed) {
      var languageList = _languageList.value;
      var language = languageList[index];
      if (language.isSelected) {
        language.isSelected = false;
      } else {
        language.isSelected = true;
      }
      languageList[index] = language;
      _languageList.sink.add(languageList);
    }
  }

  void updateSelectedLanguageList(List<Languages>? languages) {
    if(!_languageList.isClosed && languages != null) {
      var languageList = _languageList.value;
      var tempLanguageList = _languageList.value;
      for(var language in languages) {
        for(int i = 0; i < languageList.length; i++) {
          if(language.name == languageList[i].name) {
            tempLanguageList[i] = language;
          }
        }
      }
      _languageList.sink.add(tempLanguageList);
    }
  }
}
