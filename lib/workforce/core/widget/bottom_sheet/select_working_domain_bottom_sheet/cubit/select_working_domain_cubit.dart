import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/model/working_domain.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

part 'select_working_domain_state.dart';

class SelectWorkingDomainCubit extends Cubit<SelectWorkingDomainState> {
  SelectWorkingDomainCubit() : super(SelectWorkingDomainInitial()) {
    loadWorkingDomainList();
  }

  final _workingDomainList = BehaviorSubject<List<WorkingDomain>>();

  Stream<List<WorkingDomain>> get workingDomainListStream =>
      _workingDomainList.stream;

  List<WorkingDomain> get workingDomainList => _workingDomainList.value;

  Function(List<WorkingDomain>) get changeWorkingDomainList =>
      _workingDomainList.sink.add;

  @override
  Future<void> close() {
    _workingDomainList.close();
    return super.close();
  }

  void loadWorkingDomainList() {
    var domainArray = [
      'calling'.tr,
      'data_entry'.tr,
      'field_job'.tr,
      'delivery_job'.tr,
      'sales'.tr,
      'marketing'.tr,
      'business_development'.tr,
      'others'.tr,
    ];
    var list = <WorkingDomain>[];
    for (var name in domainArray) {
      var item = WorkingDomain(name: name);
      list.add(item);
    }
    if (!_workingDomainList.isClosed) {
      _workingDomainList.sink.add(list);
    }
  }

  void updateWorkingDomainList(int index, WorkingDomain workingDomain) {
    if (!_workingDomainList.isClosed) {
      var list = _workingDomainList.value;
      var domain = list[index];
      if (domain.isSelected) {
        domain.isSelected = false;
      } else {
        domain.isSelected = true;
      }
      list[index] = domain;
      _workingDomainList.sink.add(list);
    }
  }

  void updateSelectedWorkingDomainList(List<WorkingDomain> workingDomainList) {
    if (!_workingDomainList.isClosed) {
      var list = _workingDomainList.value;
      var tempList = _workingDomainList.value;
      for(int i = 0; i < list.length; i++) {
        for(int j = 0; j < workingDomainList.length; j++) {
          if(list[i].name == workingDomainList[j].name) {
            tempList[i] = workingDomainList[j];
            continue;
          }
        }
      }
      _workingDomainList.sink.add(tempList);
    }
  }

  List<WorkingDomain> getSelectedWorkingDomainList() {
    var list = workingDomainList;
    var tempList = <WorkingDomain>[];
    for (var item in list) {
      if (item.isSelected) {
        tempList.add(item);
      }
    }
    return tempList;
  }
}
