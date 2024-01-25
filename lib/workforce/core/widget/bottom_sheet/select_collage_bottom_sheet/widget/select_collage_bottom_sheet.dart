import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/debouncer.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_collage_bottom_sheet/cubit/select_collage_cubit.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/common/data_not_found.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSelectCollageBottomSheet(
    BuildContext context, Function(Education?) onSubmitTap,
    {bool isLocalNavigation = false}) {
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
      return SelectCollageWidget(onSubmitTap,
          isLocalNavigation: isLocalNavigation);
    },
  );
}

class SelectCollageWidget extends StatefulWidget {
  Function(Education?) onSubmitTap;
  bool isLocalNavigation;

  SelectCollageWidget(this.onSubmitTap,
      {this.isLocalNavigation = false, Key? key})
      : super(key: key);

  @override
  _SelectCollageWidgetState createState() => _SelectCollageWidgetState();
}

class _SelectCollageWidgetState extends State<SelectCollageWidget> {
  final _selectCollageCubit = sl<SelectCollageCubit>();
  final GlobalKey<PaginationViewState> _paginationKey =
      GlobalKey<PaginationViewState>();
  final _searchQuery = TextEditingController();
  final _debouncer = Debouncer();

  @override
  void initState() {
    _searchQuery.addListener(_onSearchChanged);
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
    return DraggableScrollableSheet(
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: Dimens.padding_24),
                  child: Text(
                    'collage'.tr,
                    style: Get.textTheme.headline7Bold,
                  ),
                ),
                buildCloseIcon(),
              ],
            ),
            buildSearchTextField(),
            const SizedBox(height: Dimens.margin_16),
            buildCollageList(controller),
          ],
        );
      },
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null, isLocal: widget.isLocalNavigation);
        },
        child: const Padding(
          padding: EdgeInsets.all(Dimens.padding_16),
          child: Icon(Icons.close),
        ),
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
            onSubmitted: (v) {
              _selectCollageCubit.searchCollage(0, v);
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

  Widget buildCollageList(ScrollController scrollController) {
    return Expanded(
      child: PaginationView<Education>(
        key: _paginationKey,
        scrollController: scrollController,
        itemBuilder: (BuildContext context, Education education, int index) =>
            Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_24),
          child: MyInkWell(
            onTap: () {
              widget.onSubmitTap(education);
              MRouter.pop(null, isLocal: widget.isLocalNavigation);
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(
                  0, Dimens.margin_8, 0, Dimens.margin_8),
              child: Text(
                education.collegeName ?? '',
                style: Get.textTheme.bodyText1,
              ),
            ),
          ),
        ),
        paginationViewType: PaginationViewType.listView,
        pageIndex: 0,
        pageFetch: _selectCollageCubit.searchCollage,
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
