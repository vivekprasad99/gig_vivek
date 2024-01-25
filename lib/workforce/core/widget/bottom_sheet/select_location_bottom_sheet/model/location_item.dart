import 'package:awign/workforce/core/data/model/enum.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';

class LocationItem {
  LocationItem({
    this.name = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.isSelected = false,
  });

  late String? name;
  late String? createdAt;
  late String? updatedAt;
  late bool isSelected;
}

class LocationType<String> extends Enum1<String> {
  const LocationType(String val) : super(val);

  static const LocationType allIndia = LocationType('allIndia');
  static const LocationType city = LocationType('city');
  static const LocationType pincode = LocationType('pincode');
  static const LocationType state = LocationType('state');
}

class LocationResponse {
  List<Address>? locations;
  int? page;
  int? limit;
  int? total;

  LocationResponse({this.locations, this.page, this.limit, this.total});

  LocationResponse.fromJson(Map<String, dynamic> json) {
    if (json['locations'] != null) {
      locations = <Address>[];
      json['locations'].forEach((v) {
        locations!.add(Address.fromJson(v));
      });
    }
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (locations != null) {
      data['locations'] = locations!.map((v) => v.toJson()).toList();
    }
    data['page'] = page;
    data['limit'] = limit;
    data['total'] = total;
    return data;
  }
}