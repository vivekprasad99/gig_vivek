import 'package:awign/workforce/aw_questions/data/model/answer/trackable_data.dart';

class TrackableDataHolder {
  late TrackableData? trackableData;
  late TrackableData? metadataData;
  late List<TrackableData>? metaDataList;
  late List<TrackableData>? trackableList;
  late bool isUserEditingAnswer;

  TrackableDataHolder(
      {this.trackableData,
      this.metadataData,
      this.metaDataList,
      this.trackableList,
      this.isUserEditingAnswer = false});
}
