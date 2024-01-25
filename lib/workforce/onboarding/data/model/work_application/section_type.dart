import 'package:awign/workforce/core/data/model/enum.dart';

class SectionType<String> extends Enum1<String> {
  const SectionType(String val) : super(val);

  static const SectionType smallImageWithText = SectionType('smallImageWithText');
  static const SectionType largeImageWithText = SectionType('largeImageWithText');
  static const SectionType singleCTA = SectionType('singleCTA');
  static const SectionType slotScheduled = SectionType('slotScheduled');
  static const SectionType batchScheduled = SectionType('batchScheduled');
  static const SectionType slotSupplyConfirm = SectionType('slotSupplyConfirm');
  static const SectionType batchSupplyConfirm = SectionType('batchSupplyConfirm');
  static const SectionType status = SectionType('status');
  static const SectionType timeline = SectionType('timeline');
  static const SectionType note = SectionType('note');
  static const SectionType resource = SectionType('resource');
  static const SectionType empty = SectionType('empty');
  static const SectionType scenarios = SectionType('scenarios');
  static const SectionType scheduleInterview = SectionType('scheduleInterview');
  static const SectionType scheduleTraining = SectionType('scheduleTraining');
  static const SectionType description = SectionType('description');
  static const SectionType dataPoint = SectionType('dataPoint');
  static const SectionType bulletPoint = SectionType('bulletPoint');

  static SectionType? getStatus(dynamic status) {
    switch(status) {
      case 'smallImageWithText':
        return  SectionType.smallImageWithText;
      case 'largeImageWithText':
        return SectionType.largeImageWithText;
      case 'singleCTA':
        return SectionType.singleCTA;
      case 'slotScheduled':
        return SectionType.slotScheduled;
      case 'batchScheduled':
        return SectionType.batchScheduled;
      case 'slotSupplyConfirm':
        return SectionType.slotSupplyConfirm;
      case 'batchSupplyConfirm':
        return SectionType.batchSupplyConfirm;
      case 'status':
        return SectionType.status;
      case 'timeline':
        return SectionType.timeline;
      case 'note':
        return SectionType.note;
      case 'resource':
        return SectionType.resource;
      case 'empty':
        return SectionType.empty;
      case 'scenarios':
        return SectionType.scenarios;
      case 'scheduleInterview':
        return SectionType.scheduleInterview;
      case 'scheduleTraining':
        return SectionType.scheduleTraining;
      case 'description':
        return SectionType.description;
      case 'dataPoint':
        return SectionType.dataPoint;
      case 'bulletPoint':
        return SectionType.bulletPoint;
    }
    return null;
  }
}