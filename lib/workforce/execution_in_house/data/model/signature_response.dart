class SignatureResponse {
  List<Signature>? signatures;
  Signature? signature;
  int? limit;
  int? page;
  int? offset;
  int? total;

  SignatureResponse(
      {this.signatures,
      this.signature,
      this.limit,
      this.page,
      this.offset,
      this.total});

  SignatureResponse.fromJson(Map<String, dynamic> json) {
    if (json['signatures'] != null) {
      signatures = <Signature>[];
      json['signatures'].forEach((v) {
        signatures!.add(Signature.fromJson(v));
      });
    }
    signature = json['signature'] != null
        ? Signature.fromJson(json['signature'])
        : null;
    limit = json['limit'];
    page = json['page'];
    offset = json['offset'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (signatures != null) {
      data['signatures'] = signatures!.map((v) => v.toJson()).toList();
    }
    data['signature'] = signature?.toJson();
    data['limit'] = limit;
    data['page'] = page;
    data['offset'] = offset;
    data['total'] = total;
    return data;
  }
}

class Signature {
  String? id;
  String? name;
  String? mobileNumber;
  String? signature;
  String? address;
  String? pincode;
  String? city;
  String? state;
  String? font;

  Signature(
      {this.id,
      this.name,
      this.mobileNumber,
      this.signature,
      this.address,
      this.pincode,
      this.city,
      this.state,
      this.font});

  Signature.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    mobileNumber = json['mobile_number'];
    signature = json['signature'];
    address = json['address'];
    pincode = json['pincode'];
    city = json['city'];
    state = json['state'];
    font = json['font'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['mobile_number'] = mobileNumber;
    data['signature'] = signature;
    data['address'] = address;
    data['pincode'] = pincode;
    data['city'] = city;
    data['state'] = state;
    data['font'] = font;
    return data;
  }
}

class CreateSignatureRequest {
  CreateSignatureRequest({required this.signature});

  late final Signature? signature;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['signature'] = signature?.toJson();
    return _data;
  }
}
