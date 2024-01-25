import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/widget/bottom_sheet/cubit/worklist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../packages/pagination_view/pagination_view.dart';
import '../../../../../../core/di/app_injection_container.dart';
import '../../../../../../core/router/router.dart';
import '../../../../../../core/utils/debouncer.dart';
import '../../../../../../core/widget/bottom_sheet/select_education_level_bottom_sheet/widget/select_education_level_bottom_sheet.dart';
import '../../../../../../core/widget/buttons/my_ink_well.dart';
import '../../../../../../core/widget/common/data_not_found.dart';
import '../../../../../../core/widget/dialog/loading/app_circular_progress_indicator.dart';
import '../../../../../../core/widget/theme/theme_manager.dart';
import '../../../../../data/model/work_listing_fetch_locations/address_entity.dart';

void showWorkListingBottomSheet(BuildContext context, String columnName,
    String workListingId, Function(AddressEntity) onItemClick) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    isScrollControlled: true,
    enableDrag: false,
    builder: (BuildContext context) {
      return WorkListingBottomSheetWidget(
        columnName: columnName,
        workListingId: workListingId,
        onItemClick: onItemClick,
      );
    },
  );
}

class WorkListingBottomSheetWidget extends StatefulWidget {
  String columnName;
  String workListingId;
  Function(AddressEntity) onItemClick;

  WorkListingBottomSheetWidget(
      {Key? key,
      required this.columnName,
      required this.workListingId,
      required this.onItemClick})
      : super(key: key);

  @override
  State<WorkListingBottomSheetWidget> createState() =>
      _WorkListingBottomSheetWidgetState();
}

class _WorkListingBottomSheetWidgetState
    extends State<WorkListingBottomSheetWidget> {
  final _worklistCubit = sl<WorklistCubit>();
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();

  final _searchQuery = TextEditingController();
  final _debouncer = Debouncer();

  @override
  void initState() {
    _searchQuery.addListener(_onSearchChanged);
    _worklistCubit.setBottomSheetTitle("Search ${widget.columnName}");
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
                   StreamBuilder<String>(
                       stream: _worklistCubit.title,
                       builder: (context, snapShot) {
                         return Text(
                           snapShot.data ?? "",
                           style: Get.textTheme.headline7Bold,
                         );
                       }),
                   buildCloseIcon(),
                 ],
               ),
               buildSearchTextField(),
               const SizedBox(height: Dimens.margin_16),
               buildWorkListDetails(controller),
             ],
           );
          }
      ),
    );
  }

  Widget buildSearchTextField() {
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
            onChanged:(value) {
              _worklistCubit.searchTerm = value;
              _worklistCubit.searchWorkList(
                  0, widget.workListingId, widget.columnName);
            },
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_48,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: Get.theme.textFieldBackgroundColor,
              hintText: 'search'.tr,
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

  Widget buildWorkListDetails(ScrollController scrollController) {
    return Expanded(
      child: PaginationView<WorklistingLocations>(
        key: _paginationKey,
        scrollController: scrollController,
        itemBuilder:
            (BuildContext context, WorklistingLocations workListItem, int index) =>
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.padding_24),
              child: MyInkWell(
                onTap: () {
                  MRouter.pop(null);
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(
                      0, Dimens.margin_8, 0, Dimens.margin_8),
                  child: Text(
                    _worklistCubit.getItemBottomSheetTitle(
                        widget.columnName, workListItem).toString(),
                    style: context.textTheme.bodyText1Bold
                        ?.copyWith(color: AppColors.backgroundGrey900),
                  ),
                ),
              ),
            ),
        paginationViewType: PaginationViewType.listView,
        pageIndex: 1,
        pageFetch: (index, value) {
          return _worklistCubit.searchWorkList(
              index, widget.workListingId, widget.columnName);
        },
        onError: (dynamic error) => Center(
          child: DataNotFound(),
        ),
        onEmpty: DataNotFound(),
        bottomLoader: AppCircularProgressIndicator(),
        initialLoader: AppCircularProgressIndicator(),
      ),
    );
  }
}
