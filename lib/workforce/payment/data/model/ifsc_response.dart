class BankData {
  String? bank;
  String? address;
  String? city;
  String? state;
  String? branch;

  BankData({
    this.bank,
    this.address,
    this.city,
    this.state,
    this.branch,
  });

  BankData.fromJson(Map<String, dynamic> json) {
    bank = json['bank'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    branch = json['branch'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bank'] = bank;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['branch'] = branch;
    return data;
  }
}
