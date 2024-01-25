
class AddressEntity {
  List<WorklistingLocations>? worklistingLocations;
  int? page;
  int? limit;
  int? count;
  int? total;

  AddressEntity(
      {this.worklistingLocations,
      this.page,
      this.limit,
      this.count,
      this.total});

  AddressEntity.fromJson(Map<String, dynamic> json) {
    if (json['worklisting_locations'] != null) {
      worklistingLocations = <WorklistingLocations>[];
      json['worklisting_locations'].forEach((v) {
        worklistingLocations!.add(new WorklistingLocations.fromJson(v));
      });
    }
    page = json['page'];
    limit = json['limit'];
    count = json['count'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.worklistingLocations != null) {
      data['worklisting_locations'] =
          this.worklistingLocations!.map((v) => v.toJson()).toList();
    }
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['count'] = this.count;
    data['total'] = this.total;
    return data;
  }
}

class WorklistingLocations {
  int? id;
  int? pincode;
  String? area;
  String? city;
  String? state;
  String? latitude;
  String? longitude;
  String? addressType;
  int? entityId;
  String? entityType;
  String? coordinates;
  String? createdAt;
  String? updatedAt;
  String? primary;

  WorklistingLocations({this.id, this.pincode});

  WorklistingLocations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pincode = json['pincode'];
    area = json['area'];
    city = json['city'];
    state = json['state'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    addressType = json['address_type'];
    entityId = json['entity_id'];
    entityType = json['entity_type'];
    coordinates = json['coordinates'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    primary = json['primary'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['pincode'] = this.pincode;
    data['area'] = this.area;
    data['city'] = this.city;
    data['state'] = this.state;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['address_type'] = this.addressType;
    data['entity_id'] = this.entityId;
    data['entity_type'] = this.entityType;
    data['coordinates'] = this.coordinates;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['primary'] = this.primary;
    return data;
  }
}
