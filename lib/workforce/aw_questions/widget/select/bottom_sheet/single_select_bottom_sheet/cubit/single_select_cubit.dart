import 'package:awign/workforce/aw_questions/data/model/option.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'single_select_state.dart';

class SingleSelectCubit extends Cubit<SingleSelectState> {
  SingleSelectCubit() : super(SingleSelectInitial());

  final _optionsListAll = BehaviorSubject<List<String>>();

  final _optionsList = BehaviorSubject<List<String>>();
  Stream<List<String>> get optionsListStream => _optionsList.stream;
  List<String> get optionsList => _optionsList.value;
  Function(List<String>) get changeOptionsList => _optionsList.sink.add;

  final _selectedOption = BehaviorSubject<int?>();
  Stream<int?> get selectedOptionStream => _selectedOption.stream;
  String get selectedOption => optionsList[_selectedOption.value! - 1];
  Function(int?) get changeSelectedOption => _selectedOption.sink.add;

  @override
  Future<void> close() {
    _optionsListAll.close();
    _optionsList.close();
    _selectedOption.close();
    return super.close();
  }

  void addAllOptions(List<String> options) {
    if (!_optionsListAll.isClosed) {
      _optionsListAll.sink.add(options);
    }
    if (!_optionsList.isClosed) {
      _optionsList.sink.add(options);
    }
  }

  void addAllOptionEntities(List<Option> options) {
    List<String> strOptions = [];
    for (var element in options) {
      strOptions.add(element.name);
    }
    if (!_optionsListAll.isClosed) {
      _optionsListAll.sink.add(strOptions);
    }
    if (!_optionsList.isClosed) {
      _optionsList.sink.add(strOptions);
    }
  }

  void searchOptions(String? query) {
    List<String> allOptions = _optionsListAll.value;
    List<String> tempOptions = [];
    if ((query ?? '').isNotEmpty) {
      for (String option in allOptions) {
        if (option.toLowerCase().contains(query!.toLowerCase())) {
          tempOptions.add(option);
        }
      }
    } else {
      tempOptions.addAll(allOptions);
    }
    if (!_optionsList.isClosed) {
      _optionsList.sink.add(tempOptions);
    }
  }

  void setSelectedOption(String option) {
    List<String> allOptions = _optionsListAll.value;
    for (int i = 0; i < allOptions.length; i++) {
      if (allOptions[i].toLowerCase() == option.toLowerCase()) {
        changeSelectedOption(i);
        break;
      }
    }
  }

  void setSelectedOptionEntity(Option option) {
    List<String> allOptions = _optionsListAll.value;
    for (int i = 0; i < allOptions.length; i++) {
      if (allOptions[i].toLowerCase() == option.name.toLowerCase()) {
        changeSelectedOption(i);
        break;
      }
    }
  }

  void setSelectedOptionEntityByStringValue(String answerValueOrUID) {
    List<String> allOptions = _optionsListAll.value;
    for (int i = 0; i < allOptions.length; i++) {
      if (allOptions[i].toLowerCase() == answerValueOrUID.toLowerCase()) {
        changeSelectedOption(i);
        break;
      }
    }
  }

  Option? getSelectedOption(List<Option>? options) {
    int? index = _selectedOption.value;
    if (options != null && index != null && options.length > index) {
      return options[index];
    }
    return null;
  }
}
