import 'package:awign/workforce/core/data/model/enum.dart';

class LocationType<T1, T2> extends Enum2<String, String> {
  const LocationType(String val1, String val2) : super(val1, val2);

  static const LocationType allIndia = LocationType('all_india', 'All India');
  static const LocationType cities = LocationType('cities', 'Multiple Cities');
  static const LocationType pincodes = LocationType('pincodes', 'Multiple Pincodes');
  static const LocationType states = LocationType('states', 'Multiple States');
  static const LocationType multipleLocations = LocationType('multiple_locations', 'Multiple Locations');

  static LocationType? getType(dynamic status) {
    switch(status) {
      case 'remote':
      case 'all_india':
        return  LocationType.allIndia;
      case 'cities':
        return LocationType.cities;
      case 'pincodes':
        return LocationType.pincodes;
      case 'states':
        return LocationType.states;
      case 'multiple_locations':
        return LocationType.multipleLocations;
    }
    return null;
  }

  @override
  String getValue1() {
    return value1;
  }

  @override
  String getValue2() {
    return value2;
  }
}