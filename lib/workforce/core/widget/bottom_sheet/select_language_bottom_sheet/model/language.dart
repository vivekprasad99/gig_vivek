class Languages {
  Languages({
    this.id = 0,
    this.userId = -1,
    this.name = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.isSelected = false,
  });

  late int? id;
  late int? userId;
  late String? name;
  late String? createdAt;
  late String? updatedAt;
  late bool isSelected;

  Languages.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    isSelected = true;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    return _data;
  }
}
