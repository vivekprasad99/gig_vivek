import 'package:awign/workforce/university/data/model/navbar_item.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'select_filter_state.dart';

class SelectFilterCubit extends Cubit<SelectFilterState> {

  final _radioTempItem = BehaviorSubject<String>.seeded("All");
  Stream<String> get radioTempItemStream => _radioTempItem.stream;
  String? get radioTempItemValue => _radioTempItem.value;
  Function(String) get changeRadioTempItem => _radioTempItem.sink.add;

  final _skillFilterDataList = BehaviorSubject<List<SkillFilterData>>();
  Stream<List<SkillFilterData>> get skillFilterDataListStream => _skillFilterDataList.stream;
  List<SkillFilterData> get skillFilterDataList => _skillFilterDataList.value;
  Function(List<SkillFilterData>) get changeSkillFilterDataList => _skillFilterDataList.sink.add;


  SelectFilterCubit() : super(SelectFilterInitial()){
    loadFilterList();
  }

  void loadFilterList()
  {
    var filterList = [
      "All",
      "Number Skills",
      "Time Management",
      "Team work",
      "Organizational Skills",
      "Negotiation Skills",
      "Persuasion Skills",
      "Basic Excel",
      "Making PPT",
      "Presentation skills",
      "Resume building",
      "How to crack interviews",
      "Decision Making",
      "Basic Photoshop",
      "Video Editing",
      "Data Cataloging",
      "How to be a good manager?",
      "Communication Skills",
      "Data Entry"
    ];

    var skillFilterDataList = <SkillFilterData>[];
    for (var name in filterList) {
      var skillFilterData = SkillFilterData(skillFilterItem: name);
      skillFilterDataList.add(skillFilterData);
    }
    if(!_skillFilterDataList.isClosed) {
      _skillFilterDataList.sink.add(skillFilterDataList);
    }
  }

  void onFilterRadioTap(String value) {
    _radioTempItem.sink.add(value);
  }
}
