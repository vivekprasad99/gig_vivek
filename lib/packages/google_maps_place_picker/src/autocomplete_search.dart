import 'dart:async';

import 'package:awign/packages/google_maps_place_picker/providers/place_provider.dart';
import 'package:awign/packages/google_maps_place_picker/providers/search_provider.dart';
import 'package:awign/packages/google_maps_place_picker/src/components/on_screen_pridiction_tile.dart';
import 'package:awign/packages/google_maps_place_picker/src/components/prediction_tile.dart';
import 'package:awign/packages/google_maps_place_picker/src/controllers/autocomplete_search_controller.dart';
import 'package:awign/packages/google_maps_place_picker/src/place_picker.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';

class AutoCompleteSearch extends StatefulWidget {
  const AutoCompleteSearch(
      {Key? key,
      required this.sessionToken,
      required this.onPicked,
      required this.appBarKey,
      this.hintText,
      this.searchingText = "Searching...",
      this.height = 40,
      this.contentPadding = EdgeInsets.zero,
      this.debounceMilliseconds,
      this.onSearchFailed,
      required this.searchBarController,
      this.autocompleteOffset,
      this.autocompleteRadius,
      this.autocompleteLanguage,
      this.autocompleteComponents,
      this.autocompleteTypes,
      this.strictbounds,
      this.region,
      this.initialSearchString,
      this.searchForInitialValue,
      this.autocompleteOnTrailingWhitespace,
      this.onScreenAutocomplete = false,
      this.onScreenTextEditingController,
      this.errorText})
      : assert(searchBarController != null),
        super(key: key);

  final String? sessionToken;
  final String? hintText;
  final String? searchingText;
  final double height;
  final EdgeInsetsGeometry contentPadding;
  final int? debounceMilliseconds;
  final ValueChanged<Prediction> onPicked;
  final ValueChanged<String>? onSearchFailed;
  final SearchBarController searchBarController;
  final num? autocompleteOffset;
  final num? autocompleteRadius;
  final String? autocompleteLanguage;
  final List<String>? autocompleteTypes;
  final List<Component>? autocompleteComponents;
  final bool? strictbounds;
  final String? region;
  final GlobalKey appBarKey;
  final String? initialSearchString;
  final bool? searchForInitialValue;
  final bool? autocompleteOnTrailingWhitespace;
  final bool onScreenAutocomplete;
  final TextEditingController? onScreenTextEditingController;
  final String? errorText;

  @override
  AutoCompleteSearchState createState() => AutoCompleteSearchState();
}

class AutoCompleteSearchState extends State<AutoCompleteSearch> {
  TextEditingController controller = TextEditingController();
  FocusNode focus = FocusNode();
  OverlayEntry? overlayEntry;
  SearchProvider provider = SearchProvider();

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchString != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.text = widget.initialSearchString!;
        if (widget.searchForInitialValue!) {
          _onSearchInputChange();
        }
      });
    }
    controller.addListener(_onSearchInputChange);
    focus.addListener(_onFocusChanged);

    widget.searchBarController.attach(this);
  }

  @override
  void dispose() {
    controller.removeListener(_onSearchInputChange);
    controller.dispose();

    focus.removeListener(_onFocusChanged);
    focus.dispose();
    _clearOverlay();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: widget.onScreenAutocomplete
          ? _buildOnScreenAutocomplete()
          : Padding(
              padding: const EdgeInsets.all(Dimens.padding_8),
              child: Card(
                elevation: 8.0,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black54
                    : Colors.white,
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 10),
                    const Icon(Icons.search),
                    const SizedBox(width: 10),
                    Expanded(child: _buildSearchTextField()),
                    _buildTextClearIcon(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOnScreenAutocomplete() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: widget.onScreenTextEditingController,
          style: Get.textTheme.bodyText1,
          keyboardType: TextInputType.streetAddress,
          maxLines: 1,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: 'search_by_area'.tr,
            hintStyle: const TextStyle(
                fontSize: Dimens.font_16, fontWeight: FontWeight.w400),
            errorText: widget.errorText,
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_8)),
              borderSide: BorderSide(color: AppColors.backgroundGrey400),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_8)),
              borderSide: BorderSide(color: AppColors.primaryMain),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.margin_16,
                  Dimens.margin_8, Dimens.margin_12, Dimens.margin_8),
              child: SvgPicture.asset('assets/images/ic_search.svg'),
            ),
          ),
        ),
        autoFlipDirection: true,
        suggestionsCallback: (pattern) async {
          return await _performOnScreenAutoCompleteSearch(pattern);
        },
        itemBuilder: (context, suggestion) {
          return OnScreenPredictionTile(
            prediction: suggestion as Prediction,
          );
        },
        onSuggestionSelected: (suggestion) {
          widget.onPicked(suggestion as Prediction);
        },
      ),
    );
  }

  Widget _buildSearchTextField() {
    return TextField(
      style: Get.textTheme.bodyText1,
      controller: controller,
      focusNode: focus,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_8,
            Dimens.padding_12, Dimens.padding_8, Dimens.padding_12),
      ),
    );
  }

  Widget _buildTextClearIcon() {
    return Selector<SearchProvider, String>(
        selector: (_, provider) => provider.searchTerm,
        builder: (_, data, __) {
          if (data.length > 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                child: Icon(
                  Icons.clear,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
                onTap: () {
                  clearText();
                },
              ),
            );
          } else {
            return SizedBox(width: 10);
          }
        });
  }

  _onSearchInputChange() {
    if (!mounted) return;
    this.provider.searchTerm = controller.text;

    PlaceProvider provider = PlaceProvider.of(context, listen: false);

    if (controller.text.isEmpty) {
      provider.debounceTimer?.cancel();
      _searchPlace(controller.text);
      return;
    }

    if (controller.text.trim() == this.provider.prevSearchTerm.trim()) {
      provider.debounceTimer?.cancel();
      return;
    }

    if (!widget.autocompleteOnTrailingWhitespace! &&
        controller.text.substring(controller.text.length - 1) == " ") {
      provider.debounceTimer?.cancel();
      return;
    }

    if (provider.debounceTimer?.isActive ?? false) {
      provider.debounceTimer!.cancel();
    }

    provider.debounceTimer =
        Timer(Duration(milliseconds: widget.debounceMilliseconds!), () {
      _searchPlace(controller.text.trim());
    });
  }

  _onFocusChanged() {
    PlaceProvider provider = PlaceProvider.of(context, listen: false);
    provider.isSearchBarFocused = focus.hasFocus;
    provider.debounceTimer?.cancel();
    provider.placeSearchingState = SearchingState.Idle;
  }

  _searchPlace(String searchTerm) {
    this.provider.prevSearchTerm = searchTerm;

    if (context == null) return;

    _clearOverlay();

    if (searchTerm.length < 1) return;

    _displayOverlay(_buildSearchingOverlay());

    _performAutoCompleteSearch(searchTerm);
  }

  _clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }

  _displayOverlay(Widget overlayChild) {
    _clearOverlay();

    final RenderBox? appBarRenderBox =
        widget.appBarKey.currentContext!.findRenderObject() as RenderBox?;
    final screenWidth = MediaQuery.of(context).size.width;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // top: appBarRenderBox!.size.height,
        top: 100,
        left: screenWidth * 0.025,
        right: screenWidth * 0.025,
        child: Material(
          elevation: 4.0,
          child: overlayChild,
        ),
      ),
    );

    Overlay.of(context)!.insert(overlayEntry!);
  }

  Widget _buildSearchingOverlay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              widget.searchingText ?? "Searching...",
              style: const TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPredictionOverlay(List<Prediction> predictions) {
    return ListBody(
      children: predictions
          .map<Widget>(
            (p) => PredictionTile(
              prediction: p,
              onTap: (selectedPrediction) {
                resetSearchBar();
                widget.onPicked(selectedPrediction);
              },
            ),
          )
          .toList(),
    );
  }

  _performAutoCompleteSearch(String searchTerm) async {
    PlaceProvider provider = PlaceProvider.of(context, listen: false);

    if (searchTerm.isNotEmpty) {
      final PlacesAutocompleteResponse response =
          await provider.places.autocomplete(
        searchTerm,
        sessionToken: widget.sessionToken,
        location: provider.currentPosition == null
            ? null
            : Location(
                lat: provider.currentPosition!.latitude,
                lng: provider.currentPosition!.longitude,
              ),
        offset: widget.autocompleteOffset,
        radius: widget.autocompleteRadius,
        language: widget.autocompleteLanguage,
        types: widget.autocompleteTypes ?? const [],
        components: widget.autocompleteComponents ?? const [],
        strictbounds: widget.strictbounds ?? false,
        region: widget.region,
      );

      if (response.errorMessage?.isNotEmpty == true ||
          response.status == "REQUEST_DENIED") {
        if (widget.onSearchFailed != null) {
          widget.onSearchFailed!(response.status);
        }
        return;
      }

      _displayOverlay(_buildPredictionOverlay(response.predictions));
    }
  }

  Future<List<Prediction>> _performOnScreenAutoCompleteSearch(
      String searchTerm) async {
    PlaceProvider provider = PlaceProvider.of(context, listen: false);

    if (searchTerm.isNotEmpty) {
      final PlacesAutocompleteResponse response =
          await provider.places.autocomplete(
        searchTerm,
        sessionToken: widget.sessionToken,
        location: provider.currentPosition == null
            ? null
            : Location(
                lat: provider.currentPosition!.latitude,
                lng: provider.currentPosition!.longitude,
              ),
        offset: widget.autocompleteOffset,
        radius: widget.autocompleteRadius,
        language: widget.autocompleteLanguage,
        types: widget.autocompleteTypes ?? const [],
        components: widget.autocompleteComponents ?? const [],
        strictbounds: widget.strictbounds ?? false,
        region: widget.region,
      );

      if (response.errorMessage?.isNotEmpty == true ||
          response.status == "REQUEST_DENIED") {
        if (widget.onSearchFailed != null) {
          widget.onSearchFailed!(response.status);
        }
        return <Prediction>[];
      }

      return response.predictions;
    } else {
      return <Prediction>[];
    }
  }

  clearText() {
    provider.searchTerm = "";
    controller.clear();
  }

  resetSearchBar() {
    clearText();
    focus.unfocus();
  }

  clearOverlay() {
    _clearOverlay();
  }
}
