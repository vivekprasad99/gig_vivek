import 'package:awign/workforce/aw_questions/data/model/answer/trackable_data.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/utils/string_utils.dart';

class TrackableDataHelper {
  static TrackableData getTrackableData(
      Position? location, bool locationTrackable, bool timeTrackable) {
    TrackableData trackableData = TrackableData();
    if (location != null && locationTrackable) {
      List<double> latLong = [];
      latLong.add(location.latitude);
      latLong.add(location.longitude);
      trackableData.latLong = latLong;
      trackableData.accuracy = location.accuracy;
    }
    if (timeTrackable) {
      trackableData.timeStamp = StringUtils.getDateTimeInYYYYMMDDHHMMSSFormat(
          DateTime.now()); //"yyyy-MM-dd HH:mm:ss"
    }
    return trackableData;
  }

  static TrackableData getTrackableMetaData(Position? location) {
    TrackableData trackableData = TrackableData();
    if (location != null) {
      List<double> latLong = [];
      latLong.add(location.latitude);
      latLong.add(location.longitude);
      trackableData.latLong = latLong;
      trackableData.accuracy = location.accuracy;
    }
    trackableData.timeStamp = StringUtils.getDateTimeInYYYYMMDDHHMMSSFormat(
        DateTime.now()); //"yyyy-MM-dd HH:mm:ss"

    return trackableData;
  }
}
