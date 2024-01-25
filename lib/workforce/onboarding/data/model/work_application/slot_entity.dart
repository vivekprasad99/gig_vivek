import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:intl/intl.dart';

class SlotsResponse {
  // Map<String, List<List<SlotEntity>>>? slots;
  List<DaySlotsEntity>? daySlotsEntityList;

  SlotsResponse(
      {this.daySlotsEntityList});

  SlotsResponse.fromJson(Map<String, dynamic> json) {
    if(json['slots'] != null) {
      // slots = {};
      daySlotsEntityList = [];
      Map<String, dynamic> slotsMap = json['slots'] as Map<String, dynamic>;
      bool isFirstDaySlotsEntity = true;
      slotsMap.forEach((key, value) {
        List<List<SlotEntity>> allTimeSlots = [];
        List<SlotEntity> morningSlots = [];
        List<SlotEntity> noonSlots = [];
        List<SlotEntity> eveningSlots = [];
        var valueJsonList = value as List<dynamic>;
        for (var element in valueJsonList) {
          try {
            SlotEntity slotEntity = SlotEntity.fromJson(element);
            var inputDateFormat = DateFormat(StringUtils.dateTimeFormatYMDTHMSS);
            var dateTime = inputDateFormat.parse(slotEntity.startTime ?? '');
            // DateTime dateTime = DateTime.parse(slotEntity.startTime ?? '');
            if(dateTime.hour >= 0 && dateTime.hour <= 11) {
              morningSlots.add(slotEntity);
            } else if(dateTime.hour >= 12 && dateTime.hour <= 15) {
              noonSlots.add(slotEntity);
            } else if(dateTime.hour >= 16 && dateTime.hour <= 23) {
              eveningSlots.add(slotEntity);
            }
          } catch (e) {
            AppLog.e('SlotsResponse.fromJson : ${e.toString()}');
          }
        }
        allTimeSlots.add(morningSlots);
        allTimeSlots.add(noonSlots);
        allTimeSlots.add(eveningSlots);
        // slots![key] = allTimeSlots;
        DaySlotsEntity daySlotsEntity = DaySlotsEntity(date: key, morningSlots: morningSlots, noonSlots: noonSlots, eveningSlots: eveningSlots, isSelected: isFirstDaySlotsEntity);
        isFirstDaySlotsEntity = false;
        daySlotsEntityList?.add(daySlotsEntity);
      });
    }
  }
}

class DaySlotsEntity {
  String date;
  List<SlotEntity> morningSlots;
  List<SlotEntity> noonSlots;
  List<SlotEntity> eveningSlots;
  bool isSelected;

  DaySlotsEntity(
      {required this.date,
        required this.morningSlots,
        required this.noonSlots,
        required this.eveningSlots,
      this.isSelected = false});
}

class SlotEntity {
  int? id;
  String? startTime;
  String? endTime;
  String? mobileNumber;
  late bool isSelected;

  SlotEntity(
      {this.id,
        this.startTime,
        this.endTime,
        this.mobileNumber,
        this.isSelected = false});

  SlotEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    mobileNumber = json['mobile_number'];
    isSelected = false;
  }
}

class SlotType<String> extends Enum1<String> {
  const SlotType(String val) : super(val);

  static const SlotType interview = SlotType('interview');
  static const SlotType pitch = SlotType('pitch');

  static SlotType? getStatus(dynamic status) {
    switch(status) {
      case 'interview':
        return  SlotType.interview;
      case 'pitch':
        return SlotType.pitch;
    }
    return null;
  }
}