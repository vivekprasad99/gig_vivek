class CallBridgeRequest {
  CallBridgeDataRequest callBridgeDataRequest;

  CallBridgeRequest(this.callBridgeDataRequest);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phone_bridge'] = callBridgeDataRequest;
    return data;
  }
}

class CallBridgeDataRequest {
  String phoneNumber;
  String uid;

  CallBridgeDataRequest(this.phoneNumber, this.uid);

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['phone_number'] = phoneNumber;
    data['phone_uid'] = uid;
    return data;
  }
}
