class CollageSearchDetailRequest {
  CollageSearchDetailRequest({required this.searchTerm, required this.page});

  late final String? searchTerm;
  late final int? page;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['search_term'] = searchTerm;
    _data['page'] = page;
    return _data;
  }
}
