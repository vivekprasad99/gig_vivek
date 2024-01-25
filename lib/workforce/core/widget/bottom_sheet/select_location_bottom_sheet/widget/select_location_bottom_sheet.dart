import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/debouncer.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_location_bottom_sheet/cubit/select_location_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_location_bottom_sheet/model/location_item.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/common/data_not_found.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final _selectLocationCubit = sl<SelectLocationCubit>();

void showSelectLocationBottomSheet(BuildContext context,
    LocationType locationType, Function(LocationItem?) onSubmitTap) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return SelectLocationWidget(locationType, onSubmitTap);
    },
  );
}

class SelectLocationWidget extends StatefulWidget {
  final LocationType locationType;
  final Function(LocationItem?) onSubmitTap;

  const SelectLocationWidget(this.locationType, this.onSubmitTap, {Key? key})
      : super(key: key);

  @override
  _SelectLocationWidgetState createState() => _SelectLocationWidgetState();
}

class _SelectLocationWidgetState extends State<SelectLocationWidget> {
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();
  final _searchQuery = TextEditingController();
  final _debouncer = Debouncer();

  @override
  void initState() {
    _searchQuery.addListener(_onSearchChanged);
    _selectLocationCubit.changeLocationType(widget.locationType);
    super.initState();
  }

  _onSearchChanged() {
    _debouncer(() {
      _paginationKey.currentState?.search(_searchQuery.text);
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = 'city'.tr;
    String hint = 'search_your_city'.tr;
    switch (widget.locationType) {
      case LocationType.allIndia:
      case LocationType.city:
        title = 'city'.tr;
        hint = 'search_your_city'.tr;
        break;
      case LocationType.pincode:
        title = 'pincode'.tr;
        hint = 'search_your_pincode'.tr;
        break;
      case LocationType.state:
        title = 'state'.tr;
        hint = 'search_your_state'.tr;
        break;
    }

    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery
          .of(context)
          .viewInsets
          .bottom),
        child: DraggableScrollableSheet(
            expand: false,
            builder: (_, controller) {
             return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: Dimens.padding_24),
                        child: Text(
                          title,
                          style: Get.textTheme.headline5,
                        ),
                      ),
                      buildCloseIcon(),
                    ],
                  ),
                  buildSearchTextField(),
                  const SizedBox(height: Dimens.margin_16),
                  buildLocationList(controller),
                ],
              );
            }
        ),

    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: const Padding(
          padding: EdgeInsets.all(Dimens.padding_16),
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildSearchTextField() {
    String hint = 'search_your_city'.tr;
    switch (widget.locationType) {
      case LocationType.allIndia:
      case LocationType.city:
        hint = 'search_your_city'.tr;
        break;
      case LocationType.pincode:
        hint = 'search_your_pincode'.tr;
        break;
      case LocationType.state:
        hint = 'search_your_state'.tr;
        break;
    }
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Dimens.padding_24, 0, Dimens.padding_24, 0),
      child: Stack(
        children: [
          TextField(
            style: Get.textTheme.bodyText1,
            maxLines: 1,
            controller: _searchQuery,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            onSubmitted: (v) {
              _selectLocationCubit.searchLocations(0, v);
            },
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_48,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: Get.theme.textFieldBackgroundColor,
              hintText: hint,
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide:
                BorderSide(color: Get.theme.textFieldBackgroundColor),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide:
                BorderSide(color: Get.theme.textFieldBackgroundColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                BorderSide(color: Get.theme.textFieldBackgroundColor),
              ),
            ),
            scrollPadding: EdgeInsets.only(bottom: 100.0),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: Dimens.padding_16),
                child: Icon(
                  Icons.search,
                  color: Get.theme.iconColorNormal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLocationList(ScrollController scrollController) {
    return PaginationView<LocationItem>(
      key: _paginationKey,
      scrollController: scrollController,
      shrinkWrap: true,
      itemBuilder:
          (BuildContext context, LocationItem locationItem, int index) =>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_24),
            child: MyInkWell(
              onTap: () {
                widget.onSubmitTap(locationItem);
                MRouter.pop(null);
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(
                    0, Dimens.margin_8, 0, Dimens.margin_8),
                child: Text(
                  locationItem.name ?? '',
                  style: Get.textTheme.headline5
                      ?.copyWith(fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
      paginationViewType: PaginationViewType.listView,
      pageIndex: 1,
      pageFetch: _selectLocationCubit.searchLocations,
      onError: (dynamic error) =>
          Center(
            child: DataNotFound(),
          ),
      onEmpty: DataNotFound(),
      bottomLoader: AppCircularProgressIndicator(),
      initialLoader: AppCircularProgressIndicator(),
    );
  }
}
