import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:intl/intl.dart';

class BatchEntity {
  int? id;
  String? batchName;
  String? startTime;
  String? endTime;
  String? meetingId;
  int? applicationChannelId;
  int? trainerId;
  String? trainingPlatform;
  String? trainingLink;
  String? saasOrgId;
  late bool isSelected;

  BatchEntity(
      {required this.id,
      this.batchName,
      this.startTime,
      this.endTime,
      this.meetingId,
      this.isSelected = false});

  BatchEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    batchName = json['batch_name'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    meetingId = json['meeting_id'];
    applicationChannelId = json['application_channel_id'];
    trainerId = json['trainer_id'];
    trainingPlatform = json['training_platform'];
    trainingLink = json['training_link'];
    saasOrgId = json['saas_org_id'];
    isSelected = false;
  }
}

class BatchesResponse {
  List<DayBatchesEntity>? dayBatchesEntityList;

  BatchesResponse({this.dayBatchesEntityList});

  BatchesResponse.fromJson(Map<String, dynamic> json) {
    if (json['batches'] != null) {
      // slots = {};
      dayBatchesEntityList = [];
      Map<String, dynamic> slotsMap = json['batches'] as Map<String, dynamic>;
      bool isFirstDaySlotsEntity = true;
      slotsMap.forEach((key, value) {
        List<List<BatchEntity>> allTimeSlots = [];
        List<BatchEntity> allSlots = [];
        List<BatchEntity> morningSlots = [];
        List<BatchEntity> noonSlots = [];
        List<BatchEntity> eveningSlots = [];
        var valueJsonList = value as List<dynamic>;
        for (var element in valueJsonList) {
          try {
            BatchEntity slotEntity = BatchEntity.fromJson(element);
            allSlots.add(slotEntity);
            var inputDateFormat =
                DateFormat(StringUtils.dateTimeFormatYMDTHMSS);
            var dateTime = inputDateFormat.parse(slotEntity.startTime ?? '');
            if (dateTime.hour >= 0 && dateTime.hour <= 11) {
              morningSlots.add(slotEntity);
            } else if (dateTime.hour >= 12 && dateTime.hour <= 15) {
              noonSlots.add(slotEntity);
            } else if (dateTime.hour >= 16 && dateTime.hour <= 23) {
              eveningSlots.add(slotEntity);
            }
          } catch (e) {
            AppLog.e('BatchesResponse.fromJson : ${e.toString()}');
          }
        }
        allTimeSlots.add(morningSlots);
        allTimeSlots.add(noonSlots);
        allTimeSlots.add(eveningSlots);
        DayBatchesEntity dayBatchesEntity = DayBatchesEntity(
            date: key,
            morningBatches: morningSlots,
            noonBatches: noonSlots,
            eveningBatches: eveningSlots,
            allBatches: allSlots,
            isSelected: isFirstDaySlotsEntity);
        isFirstDaySlotsEntity = false;
        dayBatchesEntityList?.add(dayBatchesEntity);
      });
    }
  }
}

class DayBatchesEntity {
  String date;
  List<BatchEntity> morningBatches;
  List<BatchEntity> noonBatches;
  List<BatchEntity> eveningBatches;
  List<BatchEntity> allBatches;
  bool isSelected;

  DayBatchesEntity(
      {required this.date,
      required this.morningBatches,
      required this.noonBatches,
      required this.eveningBatches,
      required this.allBatches,
      this.isSelected = false});
}

class WebinarTrainingRequest {
  late int? batchID;

  WebinarTrainingRequest({this.batchID});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['webinar_training_batch_id'] = batchID;
    return _data;
  }
}

class BatchRequestEntity {
  late WebinarTrainingRequest? webinarTrainingRequest;

  BatchRequestEntity({this.webinarTrainingRequest});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['webinar_training'] = webinarTrainingRequest?.toJson();
    return _data;
  }
}
