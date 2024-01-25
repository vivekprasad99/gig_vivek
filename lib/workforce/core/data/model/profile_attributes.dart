class ProfileAttributesResponse {
  ProfileAttributesResponse({
    this.profileAttributes,
    this.limit,
    this.page,
    this.offset,
    this.total,
  });

  late List<ProfileAttributes>? profileAttributes;
  late int? limit;
  late int? page;
  late int? offset;
  late int? total;

  ProfileAttributesResponse.fromJson(Map<String, dynamic> json) {
    profileAttributes = List.from(json['profile_attributes'])
        .map((e) => ProfileAttributes.fromJson(e))
        .toList();
    limit = json['limit'];
    page = json['page'];
    offset = json['offset'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['profile_attributes'] =
        profileAttributes?.map((e) => e.toJson()).toList();
    _data['limit'] = limit;
    _data['page'] = page;
    _data['offset'] = offset;
    _data['total'] = total;
    return _data;
  }
}

class ProfileAttributes {
  ProfileAttributes({
    this.id,
    this.userId,
    this.attributeName,
    this.attributeValue,
    this.createdAt,
    this.updatedAt,
    this.attributeUid,
    this.attributeType,
  });

  late int? id;
  late int? userId;
  late String? attributeName;
  late dynamic attributeValue;
  late String? createdAt;
  late String? updatedAt;
  String? attributeUid;
  String? attributeType;

  ProfileAttributes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    attributeName = json['attribute_name'];
    attributeValue = json['attribute_value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    attributeUid = json['attribute_uid'];
    attributeType = json['attribute_type'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['attribute_name'] = attributeName;
    _data['attribute_value'] = attributeValue;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['attribute_uid'] = attributeUid;
    _data['attribute_type'] = attributeType;
    return _data;
  }

  static ProfileAttributes? getProfileAttribute(
      String? attributeName, List<ProfileAttributes>? profileAttributesList) {
    if (profileAttributesList != null) {
      for (ProfileAttributes profileAttributes in profileAttributesList) {
        if (attributeName == profileAttributes.attributeName) {
          return profileAttributes;
        }
      }
    }
    return null;
  }

  static int? getProfileAttributeIndex(
      String? attributeName, List<ProfileAttributes>? profileAttributesList) {
    if (profileAttributesList != null) {
      for (int i = 0; i < profileAttributesList.length; i++) {
        if (attributeName == profileAttributesList[i].attributeName) {
          return i;
        }
      }
    }
    return null;
  }
}

class ProfileAttributesRequest {
  late ProfileAttributes profileAttributes;

  ProfileAttributesRequest({required this.profileAttributes});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['profile_attribute'] = profileAttributes.toJson();
    return _data;
  }
}
