class Option {
  Option({
    this.index = 0,
    this.name = '',
    this.isSelected = false,
  });

  late int index;
  late String name;
  late bool isSelected;
  String? uid;
  String? value;

  Option.fromJson(Map<String, dynamic> json, int i) {
    uid = json['uid'];
    value = json['value'];
    name = json['value'];
    isSelected = false;
    index = i;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['value'] = value;
    return data;
  }
}
