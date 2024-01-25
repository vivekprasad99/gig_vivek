import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/execution_in_house/data/model/available_entity.dart';
import 'package:awign/workforce/execution_in_house/data/repository/availablity/availablity_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/exception/exception.dart';

part 'availablity_state.dart';

class AvailabilityCubit extends Cubit<AvailablityState> {
  final AvailabilityRemoteRepository _availablityRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _slotList = BehaviorSubject<List<Slot>>.seeded([Slot()]);

  Stream<List<Slot>> get slotListStream => _slotList.stream;

  List<Slot> get slotListValue => _slotList.value;

  Function(List<Slot>) get changeSlotRowList => _slotList.sink.add;

  final _availableSlots = BehaviorSubject<MemberTimeSlotResponse>();

  Stream<MemberTimeSlotResponse> get availableSlots => _availableSlots.stream;

  Function(MemberTimeSlotResponse) get changeAvailableSlots =>
      _availableSlots.sink.add;

  final _memberTimeSlotResponse =
      BehaviorSubject<MemberTimeSlotResponse>.seeded(
          MemberTimeSlotResponse(memberTimeSlot: MemberTimeSlot(slots: [])));

  MemberTimeSlotResponse get memberTimeSlotResponseValue =>
      _memberTimeSlotResponse.value;

  final _isChecked = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isChecked => _isChecked.stream;
  bool get isCheckedValue => _isChecked.value;
  Function(bool) get changeIsChecked => _isChecked.sink.add;

  final _isTodayChecked = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isTodayChecked => _isTodayChecked.stream;
  bool get isTodayCheckedValue => _isTodayChecked.value;
  Function(bool) get changeIsTodayChecked => _isTodayChecked.sink.add;

  List<Slot> allSlotList = [];
  static const String memberTimeSlot = 'member_time_slot';

  AvailabilityCubit(this._availablityRemoteRepository)
      : super(AvailablityInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _slotList.close();
    return super.close();
  }

  addSlot(Map<String, dynamic> cleverTapEvent) {
    if (!_slotList.isClosed && _slotList.hasValue) {
      List<Slot>? slotList = _slotList.value;
      if (slotList.isNullOrEmpty) {
        ClevertapHelper.instance().addCleverTapEvent(
            ClevertapHelper.addMoreSlotToday, cleverTapEvent);
      } else {
        ClevertapHelper.instance().addCleverTapEvent(
            ClevertapHelper.addMoreSlotTomorrow, cleverTapEvent);
      }
      slotList.add(Slot());
      changeSlotRowList(slotList);
      allSlotList = slotList;
    }
  }

  bool validateRequiredAnswers() {
    if (!_slotList.isClosed) {
      List<Slot>? slotList = _slotList.value;
      Slot slots = slotList[slotList.length - 1];
      if (slots.endTime.isNullOrEmpty || slots.startTime.isNullOrEmpty) {
        return false;
      }
    }
    return true;
  }

  deleteSlot(int index) {
    if (!_slotList.isClosed && _slotList.hasValue) {
      List<Slot>? slotList = _slotList.value;
      slotList.removeAt(index);
      changeSlotRowList(slotList);
      allSlotList.removeAt(index);
    }
  }

  updateSlotList(int index, Slot slots) {
    if (!_slotList.isClosed) {
      List<Slot>? slotList = _slotList.value;
      slotList[index] = slots;
      slotList[index].isUpdated = true;
      _slotList.sink.add(slotList);
      if (!slots.startTime.isNullOrEmpty && !slots.endTime.isNullOrEmpty) {
        MemberTimeSlotResponse memberTimeSlotResponse1 =
            _memberTimeSlotResponse.value;
        memberTimeSlotResponse1.memberTimeSlot?.slots.addAll(slotList);
        _memberTimeSlotResponse.sink.add(memberTimeSlotResponse1);
      }
      allSlotList = slotList;
    }
  }

  void getUpcomingSlots(String memberId, String date) async {
    try {
      changeUIStatus(UIStatus(isDialogLoading: true));
      MemberTimeSlotResponse data =
          await _availablityRemoteRepository.getUpcomingSlots(memberId, date);
      if (data.memberTimeSlot != null) {
        _memberTimeSlotResponse.sink.add(data);
        changeUIStatus(UIStatus(event: Event.success));
        if (data.memberTimeSlot!.slots.isNotEmpty &&
            data.memberTimeSlot!.slots.isNotEmpty) {
          List<Slot>? slotList = [];
          for (var i = 0; i < data.memberTimeSlot!.slots.length; i++) {
            DateTime startDate = DateFormat(StringUtils.dateTimeFormatYMDHMS)
                .parse(data.memberTimeSlot!.slots[i].startTime ?? "", true);
            DateTime startTime = startDate.toLocal();
            String stringStartTime =
                DateFormat(StringUtils.dateTimeFormatYMDHMS).format(startTime);
            DateTime endDate = DateFormat(StringUtils.dateTimeFormatYMDHMS)
                .parse(data.memberTimeSlot!.slots[i].endTime ?? "", true);
            DateTime endTime = endDate.toLocal();
            String stringEndTime =
                DateFormat(StringUtils.dateTimeFormatYMDHMS).format(endTime);
            Slot slot =
                Slot(startTime: stringStartTime, endTime: stringEndTime);
            slotList.add(slot);
            allSlotList.add(slot);
          }
          _slotList.add(slotList);
        }
        if (data.memberTimeSlot!.slots.isEmpty) {
          _slotList.add([Slot()]);
        }
      }
    } on ServerException catch (e) {
      if (e.data[memberTimeSlot] == null) {
        _slotList.add([Slot()]);
        changeUIStatus(UIStatus(event: Event.failed));
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e(
          'internalFeedbackEventSearch : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void updateAvailabilitySlots(
      String memberId,
      String slotId,
      MemberTimeSlotResponse memberTimeSlotResponse,
      Map<String, dynamic> cleverTapEvent) async {
    try {
      MemberTimeSlotResponse data = await _availablityRemoteRepository
          .updateAvailabilitySlots(memberId, slotId, memberTimeSlotResponse);
      if (data.memberTimeSlot != null) {
        _memberTimeSlotResponse.sink.add(data);
        allSlotList = _slotList.value;
        changeUIStatus(UIStatus(event: Event.updated));
      }
      _addConfirmAvailabilityEvent(cleverTapEvent);
    } on ServerException catch (e) {
      // if (e.data[memberTimeSlot] == null) {
      //   changeUIStatus(UIStatus(event: Event.updateError));
      // }
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e(
          'internalFeedbackEventSearch : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  void createAvailabilitySlots(
      String memberId,
      MemberTimeSlotResponse memberTimeSlotResponse,
      Map<String, dynamic> cleverTapEvent) async {
    try {
      MemberTimeSlotResponse data = await _availablityRemoteRepository
          .createAvailabilitySlots(memberId, memberTimeSlotResponse);
      if (data.memberTimeSlot != null) {
        _memberTimeSlotResponse.sink.add(data);
      }
      _addConfirmAvailabilityEvent(cleverTapEvent);
    } on ServerException catch (e) {
      // if (e.data[memberTimeSlot] == null) {
      //   changeUIStatus(UIStatus(event: Event.createError));
      // }
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e(
          'internalFeedbackEventSearch : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

  _addConfirmAvailabilityEvent(Map<String, dynamic> cleverTapEvent) {
    if (!_slotList.isClosed && _slotList.hasValue) {
      List<Slot>? slotList = _slotList.value;
      if (slotList.isNullOrEmpty) {
        ClevertapHelper.instance().addCleverTapEvent(
            ClevertapHelper.confirmTodaysAvailability, cleverTapEvent);
      } else {
        ClevertapHelper.instance().addCleverTapEvent(
            ClevertapHelper.confirmTomorrowsAvailability, cleverTapEvent);
      }
    }
  }

  void showTodaySchedule(bool value) {
    if (value) {
      List<Slot> tempList = [];
      _slotList.value.clear();
      for (var i = 0; i < allSlotList.length; i++) {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd");
        if (dateFormat.parse(allSlotList[i].startTime!).isAtSameMomentAs(
            DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day))) {
          tempList.add(Slot(
              startTime: allSlotList[i].startTime,
              endTime: allSlotList[i].endTime));
        }
      }
      _slotList.sink.add(tempList.toSet().toList());
      tempList.clear();
    } else {
      List<Slot> tempList = [];
      _slotList.value.clear();
      for (var i = 0; i < allSlotList.length; i++) {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd");
        // String name  = allSlotList[i].startTime!;
        if (dateFormat.parse(allSlotList[i].startTime!).isAtSameMomentAs(
            DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 1))) {
          tempList.add(Slot(
              startTime: allSlotList[i].startTime,
              endTime: allSlotList[i].endTime));
        }
      }
      if (tempList.isEmpty) {
        _slotList.add([Slot()]);
      } else {
        _slotList.sink.add(tempList.toSet().toList());
      }
      tempList.clear();
    }
  }

  void onCheckBoxTap(bool value, Map<String, dynamic> cleverTapEvent) {
    _isChecked.sink.add(value);
    if (!_slotList.isClosed && _slotList.hasValue) {
      Map<String, dynamic> properties = {};
      properties.addAll(cleverTapEvent);
      if (value) {
        properties[CleverTapConstant.available] = Constants.yes;
      } else {
        properties[CleverTapConstant.available] = Constants.no;
      }
      List<Slot>? slotList = _slotList.value;
      if (slotList.isNullOrEmpty) {
        ClevertapHelper.instance()
            .addCleverTapEvent(ClevertapHelper.notAvailableToday, properties);
      } else {
        ClevertapHelper.instance().addCleverTapEvent(
            ClevertapHelper.notAvailableTomorrow, properties);
      }
    }
  }

  void onTodayCheckBoxTap(bool value) {
    _isTodayChecked.sink.add(value);
  }
}
