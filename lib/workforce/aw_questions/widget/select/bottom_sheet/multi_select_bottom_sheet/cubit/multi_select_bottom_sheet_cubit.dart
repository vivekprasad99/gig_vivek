import 'package:awign/workforce/aw_questions/data/model/option.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'multi_select_bottom_sheet_state.dart';

class MultiSelectBottomSheetCubit extends Cubit<MultiSelectBottomSheetState> {
  MultiSelectBottomSheetCubit() : super(MultiSelectBottomSheetInitial());

  final _optionsListAll = BehaviorSubject<List<Option>>();

  final _optionsList = BehaviorSubject<List<Option>>();
  Stream<List<Option>> get optionsListStream => _optionsList.stream;
  List<Option> get optionsList => _optionsList.value;
  Function(List<Option>) get changeOptionsList => _optionsList.sink.add;

  final _selectedOption = BehaviorSubject<Option?>();
  Stream<Option?> get selectedOptionStream => _selectedOption.stream;

  @override
  Future<void> close() {
    _optionsListAll.close();
    _optionsList.close();
    _selectedOption.close();
    return super.close();
  }

  void addAllOptions(List<String> options) {
    List<Option> optionList = [];
    for (int i = 0; i < options.length; i++) {
      Option option = Option(index: i, name: options[i]);
      optionList.add(option);
    }
    if (!_optionsListAll.isClosed) {
      _optionsListAll.sink.add(optionList);
    }
    if (!_optionsList.isClosed) {
      _optionsList.sink.add(optionList);
    }
  }

  void addAllOptionEntities(List<Option> options) {
    if (!_optionsListAll.isClosed) {
      _optionsListAll.sink.add(options);
    }
    if (!_optionsList.isClosed) {
      _optionsList.sink.add(options);
    }
  }

  void searchOptions(String? query) {
    List<Option> allOptions = _optionsListAll.value;
    List<Option> tempOptions = [];
    if ((query ?? '').isNotEmpty) {
      for (Option option in allOptions) {
        if (option.name.toLowerCase().contains(query!.toLowerCase())) {
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

  void updateSelectedOption(Option option) {
    option.isSelected = !option.isSelected;
    List<Option> allOptions = _optionsListAll.value;
    allOptions[option.index] = option;
    if (!_optionsListAll.isClosed) {
      _optionsListAll.sink.add(allOptions);
    }
    List<Option> optionsList = _optionsList.value;
    List<Option> tempOptionsList = _optionsList.value;
    for (int i = 0; i < optionsList.length; i++) {
      if (optionsList[i].name.toLowerCase() == option.name.toLowerCase()) {
        tempOptionsList[i] = option;
        break;
      }
    }
    if (!_optionsList.isClosed) {
      _optionsList.sink.add(tempOptionsList);
    }
  }

  void setSelectedOptions(List<String> options) {
    List<Option> allOptions = _optionsListAll.value;
    List<Option> tempAllOptions = _optionsListAll.value;
    for (int i = 0; i < options.length; i++) {
      for (int j = 0; j < allOptions.length; j++) {
        if (options[i] == allOptions[j].name) {
          Option option = tempAllOptions[j];
          option.isSelected = true;
          tempAllOptions[j] = option;
          continue;
        }
      }
    }
    if (!_optionsListAll.isClosed) {
      _optionsListAll.sink.add(tempAllOptions);
    }
    if (!_optionsList.isClosed) {
      _optionsList.sink.add(tempAllOptions);
    }
  }

  void setSelectedOptionEntities(List<Option> options) {
    List<Option> allOptions = _optionsListAll.value;
    List<Option> tempAllOptions = _optionsListAll.value;
    for (int i = 0; i < allOptions.length; i++) {
      Option option = tempAllOptions[i];
      option.isSelected = false;
      for (int j = 0; j < options.length; j++) {
        if (allOptions[i].name == options[j].name) {
          option.isSelected = true;
          tempAllOptions[i] = option;
          continue;
        }
      }
    }
    if (!_optionsListAll.isClosed) {
      _optionsListAll.sink.add(tempAllOptions);
    }
    if (!_optionsList.isClosed) {
      _optionsList.sink.add(tempAllOptions);
    }
  }

  List<String> getSelectedOptions() {
    List<String> selectedOptions = [];
    List<Option> allOptions = _optionsListAll.value;
    for (int i = 0; i < allOptions.length; i++) {
      if (allOptions[i].isSelected) {
        selectedOptions.add(allOptions[i].name);
      }
    }
    return selectedOptions;
  }

  List<Option> getSelectedOptionsEntities() {
    List<Option> selectedOptions = [];
    List<Option> allOptions = _optionsListAll.value;
    for (int i = 0; i < allOptions.length; i++) {
      if (allOptions[i].isSelected) {
        selectedOptions.add(allOptions[i]);
      }
    }
    return selectedOptions;
  }
}
