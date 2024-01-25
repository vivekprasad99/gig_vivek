import 'package:awign/workforce/core/data/local/database/boxes.dart';
import 'package:hive/hive.dart';

part 'trackable_entity_ho.g.dart';

@HiveType(typeId: Boxes.trackableEntityHoTypeID)
class TrackableDataHO extends HiveObject {
  @HiveField(0)
  double? accuracy;
  @HiveField(1)
  String? address;
  @HiveField(2)
  String? area;
  @HiveField(3)
  String? city;
  @HiveField(4)
  String? countryName;
  @HiveField(5)
  List<double>? latLong;
  @HiveField(6)
  String? pinCode;
  @HiveField(7)
  String? timeStamp;

  TrackableDataHO(
      {this.accuracy,
      this.address,
      this.area,
      this.city,
      this.countryName,
      this.latLong,
      this.pinCode,
      this.timeStamp});
}
