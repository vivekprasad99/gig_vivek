import 'package:awign/packages/google_maps_place_picker/src/autocomplete_search.dart';
import 'package:flutter/cupertino.dart';

class SearchBarController extends ChangeNotifier {
  AutoCompleteSearchState? _autoCompleteSearch;

  attach(AutoCompleteSearchState searchWidget) {
    _autoCompleteSearch = searchWidget;
  }

  /// Just clears text.
  clear() {
    _autoCompleteSearch?.clearText();
  }

  /// Clear and remove focus (Dismiss keyboard)
  reset() {
    _autoCompleteSearch?.resetSearchBar();
  }

  clearOverlay() {
    _autoCompleteSearch?.clearOverlay();
  }
}
