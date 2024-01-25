import 'package:awign/workforce/core/data/model/user_data.dart';

class AddressRequest {
  AddressRequest({
    required this.address
  });

  late final Address? address;

  AddressRequest.fromJson(Map<String, dynamic> json) {
    address = json['address'] != null ? Address.fromJson(json['address']) : null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['address'] = address?.toJson();
    return _data;
  }
}