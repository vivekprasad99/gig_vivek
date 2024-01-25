import 'dart:collection';

import 'package:awign/workforce/auth/data/model/pan_details_entity.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_range.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/coordinates.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/hash_answer.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/select/select_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/data_type.dart';
import 'package:awign/workforce/aw_questions/data/model/input_type.dart';
import 'package:awign/workforce/aw_questions/data/model/option.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';
import 'package:awign/workforce/aw_questions/data/model/uid.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';

import '../model/answer/trackable_data.dart';
import '../model/answer/trackable_data_holder.dart';

class AnswerUnitMapper {

  static const String trackableTimestamp = "_timestamp";
  static const String trackableLatLong = "_latlong";
  static const String trackableAccuracy = "_accuracy";
  static const String metaDataLatLng = "lat_lng";
  static const String metaDataCity = "city";
  static const String metaDataArea = "area";
  static const String metaDataAccuracy = "accuracy";
  static const String metaDataCountry = "country";
  static const String metaDataPinCode = "pincode";
  static const String metaDataAddress = "address";
  static const String metaDataTimestamp = "timestamp";
  static const String trackingData = "_tracking_data";
  static const String metaData = "_metadata";

  static dynamic transformAnswerUnit(AnswerUnit? answerUnit) {
    if (answerUnit == null) {
      return;
    }
    switch (answerUnit.dateType) {
      case DataType.single:
        switch (answerUnit.inputType?.getValue1()) {
          case ConfigurationType.text:
          case ConfigurationType.singleSelect:
          case ConfigurationType.dateTime:
          case ConfigurationType.file:
          case ConfigurationType.signature:
          case ConfigurationType.audioRecording:
            if (answerUnit.inputType?.getValue1() == ConfigurationType.text) {
              switch (answerUnit.inputType) {
                case InputType.float:
                  try {
                    return double.parse(answerUnit.stringValue!);
                  } catch (e, st) {
                    return answerUnit.stringValue;
                  }
                case InputType.number:
                  try {
                    return int.parse(answerUnit.stringValue!);
                  } catch (e, st) {
                    return answerUnit.stringValue;
                  }
                default:
                  return answerUnit.stringValue;
              }
            } else {
              return answerUnit.stringValue;
            }
          case ConfigurationType.multiSelect:
            return answerUnit.listValue;
          case ConfigurationType.dateTimeRange:
            return _convertRange(answerUnit.answerRange);
          case ConfigurationType.location:
            return _convertLocationAnswer(answerUnit.coordinates);
          case ConfigurationType.nested:
            return _convertHash(answerUnit.hashValue);
        }
        break;
      case DataType.array:
        return _convertArray(answerUnit.arrayValue);
      case DataType.hash:
        return _convertHash(answerUnit.hashValue);
    }
  }

  static dynamic transformAnswerUnitNew(AnswerUnit? answerUnit, {UID? uid}) {
    if (answerUnit == null) {
      return;
    }
    switch (answerUnit.dateType) {
      case DataType.single:
        switch (answerUnit.inputType?.getValue1()) {
          case ConfigurationType.text:
          case ConfigurationType.file:
            if (answerUnit.inputType?.getValue1() == ConfigurationType.text) {
              switch (answerUnit.inputType) {
                case InputType.float:
                  try {
                    return double.parse(answerUnit.stringValue!);
                  } catch (e, st) {
                    return answerUnit.stringValue;
                  }
                case InputType.number:
                  try {
                    return int.parse(answerUnit.stringValue!);
                  } catch (e, st) {
                    return answerUnit.stringValue;
                  }
                default:
                  return answerUnit.stringValue;
              }
            } else {
              switch (uid) {
                case UID.panCard:
                case UID.aadharCard:
                case UID.drivingLicense:
                  return answerUnit.documentDetailsData
                      ?.toJson(isFromAWQuestion: true);
                default:
                  return answerUnit.stringValue;
              }
            }
          case ConfigurationType.singleSelect:
            switch (answerUnit.inputType?.getValue2()) {
              case SubType.slider:
                return answerUnit.stringValue;
              default:
                if (answerUnit.optionValue?.uid != null) {
                  return answerUnit.optionValue?.uid;
                } else {
                  return answerUnit.stringValue;
                }
            }
          case ConfigurationType.dateTime:
            return answerUnit.stringValue;
          case ConfigurationType.multiSelect:
            return answerUnit.optionListValue?.map((e) => e.uid).toList();
          case ConfigurationType.location:
            if (uid == UID.yourLocation) {
              answerUnit.address?.addressType = AddressType.home.value;
            } else if (uid == UID.workLocation) {
              answerUnit.address?.addressType = AddressType.work.value;
            }
            return answerUnit.address?.toJson();
          case ConfigurationType.nested:
            return _convertHash(answerUnit.hashValue);
        }
        break;
      case DataType.array:
        return _convertArray(answerUnit.arrayValue);
      case DataType.hash:
        return _convertHash(answerUnit.hashValue);
    }
  }

  static dynamic _convertRange(AnswerRange? answerRange) {
    if (answerRange != null) {
      List<String> list = [];
      list.add(answerRange.from ?? '');
      list.add(answerRange.to ?? '');
      return list;
    } else {
      return null;
    }
  }

  static dynamic _convertLocationAnswer(Coordinates? coordinates) {
    if (coordinates != null) {
      List<double> list = [];
      list.add(coordinates.latitude);
      list.add(coordinates.longitude);
      return list;
    } else {
      return null;
    }
  }

  static dynamic _convertHash(List<HashAnswer>? hashValue) {
    if (hashValue == null) {
      return null;
    }
    Map<String, dynamic> answerMap = {};
    for (HashAnswer hashAnswer in hashValue) {
      answerMap[hashAnswer.kay] = transformAnswerUnit(hashAnswer.value);
    }
    if (answerMap.isNotEmpty) {
      return answerMap;
    } else {
      return null;
    }
  }

  static dynamic _convertArray(List<AnswerUnit>? arrayValue) {
    if (arrayValue == null) {
      return null;
    }
    List<dynamic> answerList = [];
    for (AnswerUnit answerUnit in arrayValue) {
      dynamic answerValue = transformAnswerUnit(answerUnit);
      if (answerValue == null) {
        continue;
      }
      answerList.add(answerValue);
    }
    if (answerList.isNotEmpty) {
      return answerList;
    } else {
      return null;
    }
  }

  static Map<String, dynamic> transformScreenRowForUpdateLead(
      List<ScreenRow> screenRowList) {
    Map<String, dynamic> answerMap = {};
    for (ScreenRow screenRow in screenRowList) {
      if (screenRow.rowType == ScreenRowType.category) {
        List<Question> questionList = screenRow.groupData?.questions ?? [];
        for (Question question in questionList) {
          dynamic answerValue =
              AnswerUnitMapper.transformAnswerUnit(question.answerUnit);
          if (answerValue != null && question.configuration?.uid != null) {
            answerMap[question.configuration!.uid!] = answerValue;
          }
        }
      } else {
        if (screenRow.question != null) {
          dynamic answerValue = AnswerUnitMapper.transformAnswerUnit(
              screenRow.question!.answerUnit);
          if (answerValue != null &&
              screenRow.question!.configuration?.uid != null) {
            answerMap[screenRow.question!.configuration!.uid!] = answerValue;
          }
          if(screenRow.question?.answerUnit != null) {
            transformTrackableDataList(answerMap, screenRow.question!.answerUnit!, screenRow.question!.configuration!.uid!);
          }
        }
      }
    }
    return answerMap;
  }

  static AnswerUnit getAnswerUnit(InputType? inputType, DataType? dataType,
      dynamic value, List<Question>? nestedQuestionList,
      {Configuration? configuration, UID? uid}) {
    AnswerUnit answerUnit =
        AnswerUnit(inputType: inputType, dateType: dataType);
    if (value == null) {
      return answerUnit;
    }
    switch (dataType) {
      case DataType.single:
        switch (inputType?.getValue1()) {
          case ConfigurationType.text:
          case ConfigurationType.dateTime:
          case ConfigurationType.singleSelect:
          case ConfigurationType.file:
          case ConfigurationType.signature:
          case ConfigurationType.audioRecording:
            switch (inputType) {
              case InputType.pdf:
              case InputType.image:
              case InputType.file:
              case InputType.video:
              case InputType.audio:
                switch (uid) {
                  case UID.panCard:
                  case UID.aadharCard:
                  case UID.drivingLicense:
                    answerUnit.documentDetailsData =
                        DocumentDetailsData.fromJson(value);
                    break;
                  default:
                    answerUnit.stringValue = value?.toString();
                }
                break;
              case InputType.float:
                answerUnit.stringValue =
                    value != null ? (value as double).toString() : null;
                break;
              case InputType.number:
                answerUnit.stringValue =
                    value != null ? (value as int).toString() : null;
                break;
              case InputType.date:
              case InputType.time:
              case InputType.dateTime:
                answerUnit.stringValue =
                    value != null ? (value as String).toString() : null;
                break;
              default:
                if (configuration != null &&
                    configuration is SelectConfiguration) {
                  SelectConfiguration selectConfiguration = configuration;
                  answerUnit.optionValue = getOptionValue(
                      value, selectConfiguration.optionEntities ?? []);
                }
                answerUnit.stringValue = value?.toString();
            }
            break;
          case ConfigurationType.multiSelect:
            if (configuration != null) {
              SelectConfiguration selectConfiguration =
                  configuration as SelectConfiguration;
              answerUnit.optionListValue = getOptionListValue(
                  value, selectConfiguration.optionEntities ?? []);
            } else {
              answerUnit.listValue = getListValue(value);
            }
            break;
          case ConfigurationType.dateTimeRange:
            answerUnit.answerRange = getAnswerRange(value);
            break;
          case ConfigurationType.location:
            if (value != null) {
              if (value is List) {
                if(value[0] is Map)
                  {
                    answerUnit.address =
                        Address.fromJson(value[0] as Map<String, dynamic>);
                    if (answerUnit.address != null) {
                      answerUnit.coordinates = Coordinates(
                          latitude: answerUnit.address?.latitude ?? 0.0,
                          longitude: answerUnit.address?.longitude ?? 0.0);
                    }
                  }else{
                  answerUnit.coordinates = Coordinates(
                      latitude: value[0] ?? 0.0, longitude: value[1] ?? 0.0);
                }

              } else {
                answerUnit.address =
                    Address.fromJson(value as Map<String, dynamic>);
                if (answerUnit.address != null) {
                  answerUnit.coordinates = Coordinates(
                      latitude: answerUnit.address?.latitude ?? 0.0,
                      longitude: answerUnit.address?.longitude ?? 0.0);
                }
              }
            }
            break;
          case ConfigurationType.nested:
            answerUnit.hashValue =
                _getHashValue(value, answerUnit, nestedQuestionList);
            break;
        }
        break;
      case DataType.array:
        answerUnit.arrayValue = answerUnit.arrayValue ?? [];
        _transformToAnswerUnitArray(value, answerUnit, nestedQuestionList);
        break;
      case DataType.hash:
        answerUnit.hashValue = [];
        break;
    }
    return answerUnit;
  }

  static List<String>? getListValue(dynamic value) {
    List<String>? valueList;
    if (value is List<dynamic>) {
      for (int i = 0; i < value.length; i++) {
        if (value[i] is String) {
          valueList ??= [];
          valueList.add(value[i] as String);
        }
      }
    }
    return valueList;
  }

  static List<Option>? getOptionListValue(
      dynamic value, List<Option> optionEntities) {
    List<Option>? valueList;
    if (value is List<dynamic>) {
      for (int i = 0; i < value.length; i++) {
        for (int j = 0; j < optionEntities.length; j++) {
          if (value[i] is String && value[i] == optionEntities[j].uid) {
            valueList ??= [];
            valueList.add(optionEntities[j]);
          }
        }
      }
    }
    return valueList;
  }

  static Option? getOptionValue(dynamic value, List<Option> optionEntities) {
    Option? optionValue;
    if (value is String) {
      for (int i = 0; i < optionEntities.length; i++) {
        if (value == optionEntities[i].uid) {
          optionValue = optionEntities[i];
          break;
        }
      }
    }
    return optionValue;
  }

  static AnswerRange getAnswerRange(dynamic value) {
    if (value is List<dynamic>) {
      for (int i = 0; i < value.length; i++) {
        if (value.length >= 2 && value[0] is String && value[1] is String) {
          return AnswerRange(from: value[0], to: value[1]);
        }
      }
    }
    return AnswerRange();
  }

  static _transformToAnswerUnitArray(dynamic value, AnswerUnit answerUnit,
      List<Question>? nestedQuestionList) {
    if (value is List<dynamic>) {
      for (int i = 0; i < value.length; i++) {
        answerUnit.arrayValue?.add(getAnswerUnit(answerUnit.inputType,
            DataType.single, value[i], nestedQuestionList));
      }
    }
  }

  static List<HashAnswer> _getHashValue(dynamic value, AnswerUnit answerUnit,
      List<Question>? nestedQuestionList) {
    List<HashAnswer> hashAnswerList = [];
    if (value is Map<dynamic, dynamic>) {
      value.forEach((k, v) {
        InputType? inputType = answerUnit.inputType;
        DataType? dataType = answerUnit.dateType;
        for (Question question in nestedQuestionList ?? []) {
          if (question.configuration?.uid == k) {
            inputType = question.inputType;
            dataType = question.dataType;
          }
        }
        hashAnswerList.add(HashAnswer(
            kay: k, value: getAnswerUnit(inputType, dataType, v, null)));
      });
    }
    return hashAnswerList;
  }

  static Coordinates? _getCoordinates(List? values) {
    if (values != null && values.length >= 2) {
      return Coordinates(latitude: values[0], longitude: values[1]);
    } else {
      return null;
    }
  }

  static setMetaDataInAnswerUnit(dynamic trackableServerList, AnswerUnit answerUnit) {
    if (trackableServerList != null) {
      List<TrackableData> metadataList = [];
      for (var item in trackableServerList as List) {
        LinkedHashMap<String, dynamic> hashMap;
        if (item is LinkedHashMap) {
          hashMap = item as LinkedHashMap<String, dynamic>;
        } else {
          hashMap = convertHashIntoLinkedTreemap(item as Map<String, dynamic>);
        }

        TrackableData trackable = TrackableData();
        if (hashMap.containsKey(metaDataAccuracy)) {
          trackable.accuracy = (hashMap[metaDataAccuracy] as double);
        }
        if (hashMap.containsKey(metaDataAddress)) {
          trackable.address = hashMap[metaDataAddress].toString();
        }
        if (hashMap.containsKey(metaDataArea)) {
          trackable.area = hashMap[metaDataArea].toString();
        }
        if (hashMap.containsKey(metaDataCity)) {
          trackable.city = hashMap[metaDataCity].toString();
        }
        if (hashMap.containsKey(metaDataCountry)) {
          trackable.countryName = hashMap[metaDataCountry].toString();
        }
        if (hashMap.containsKey(metaDataLatLng)) {
          trackable.latLong = hashMap[metaDataLatLng] as List<double>;
        }
        if (hashMap.containsKey(metaDataTimestamp)) {
          trackable.timeStamp = hashMap[metaDataTimestamp].toString();
        }
        if (hashMap.containsKey(metaDataPinCode)) {
          trackable.pinCode = hashMap[metaDataPinCode].toString();
        }
        metadataList.add(trackable);
      }
      if (metadataList.isNotEmpty) {
        if (answerUnit.trackableDataHolder != null) {
          answerUnit.trackableDataHolder?.metaDataList = metadataList;
        } else {
          answerUnit.trackableDataHolder = TrackableDataHolder(metaDataList: metadataList);
        }
      }
    }
  }

  static LinkedHashMap<String, dynamic> convertHashIntoLinkedTreemap(Map<String, dynamic> item) {
    LinkedHashMap<String, dynamic> linkedTreeMap = LinkedHashMap<String, dynamic>();

    for (var entry in item.entries) {
      linkedTreeMap[entry.key] = entry.value;
    }
    return linkedTreeMap;
  }

  static Map<String, dynamic> transform(Map<String, AnswerUnit?>? hashMap) {
    final finalHashMap = <String, dynamic>{};
    if (hashMap == null) {
      return finalHashMap;
    }
    for (var entry in hashMap.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value == null) {
        continue;
      }
      final answerValue = transformAnswerUnit(value);

      finalHashMap[key] = answerValue ?? <String>[];
      transformTrackableDataList(finalHashMap, value, key);
    }
    return finalHashMap;
  }


  static void transformTrackableDataList(Map<String, dynamic> hashMap, AnswerUnit answerUnit, String key) {
    if (answerUnit.trackableDataHolder == null) {
      return;
    }

    List<TrackableData>? trackableDataList = answerUnit.trackableDataHolder!.trackableList;

    if (answerUnit.trackableDataHolder!.trackableData != null) {
      trackableDataList ??= [];
      trackableDataList.add(answerUnit.trackableDataHolder!.trackableData!);
      answerUnit.trackableDataHolder!.trackableList = trackableDataList;
      answerUnit.trackableDataHolder!.trackableData = null;
    }

    final trackableKey = key + trackingData;
    if (trackableDataList?.isNotEmpty == true) {
      final mappedTrackableDataList = <dynamic>[];
      for (var trackableData in trackableDataList!) {
        final trackableMap = transformTrackableData(trackableData, key);
        if (trackableMap.isNotEmpty) {
          mappedTrackableDataList.add(transformTrackableData(trackableData, key));
        }
      }

      hashMap[trackableKey] = mappedTrackableDataList;
    } else if (trackableDataList != null) {
      hashMap[trackableKey] = <String>[];
    }

    List<TrackableData>? metadataList = answerUnit.trackableDataHolder!.metaDataList;

    if (answerUnit.trackableDataHolder!.metadataData != null) {
      metadataList ??= [];
      metadataList.add(answerUnit.trackableDataHolder!.metadataData!);
      answerUnit.trackableDataHolder!.metaDataList = metadataList;
      answerUnit.trackableDataHolder!.metadataData = null;
    }

    final metadataKey = key + metaData;
    if (metadataList?.isNotEmpty == true) {
      final mappedMetadataList = <dynamic>[];
      for (var metadata in metadataList!) {
        final metadataMap = transformMetaData(metadata);
        if (metadataMap.isNotEmpty) {
          mappedMetadataList.add(metadataMap);
        }
      }
      hashMap[metadataKey] = mappedMetadataList;
    } else if (metadataList != null) {
      hashMap[metadataKey] = <String>[];
    }
  }

  static Map<String, dynamic> transformTrackableData(TrackableData trackableData, String key) {
    final hashMap = <String, dynamic>{};
    hashMap[key + trackableAccuracy] = trackableData.accuracy;
    hashMap[key + trackableLatLong] = trackableData.latLong;
    hashMap[key + trackableTimestamp] = trackableData.timeStamp;
    return hashMap;
  }

  static Map<String, dynamic> transformMetaData(TrackableData trackableData) {
    final hashMap = <String, dynamic>{};
    hashMap[metaDataAccuracy] = trackableData.accuracy;
    hashMap[metaDataAddress] = trackableData.address;
    hashMap[metaDataArea] = trackableData.area;
    hashMap[metaDataCity] = trackableData.city;
    hashMap[metaDataCountry] = trackableData.countryName;
    hashMap[metaDataLatLng] = trackableData.latLong;
    hashMap[metaDataPinCode] = trackableData.pinCode;
    hashMap[metaDataTimestamp] = trackableData.timeStamp;
    return hashMap;
  }
}
