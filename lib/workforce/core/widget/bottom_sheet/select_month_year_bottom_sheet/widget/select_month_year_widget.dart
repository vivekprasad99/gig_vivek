import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_month_year_bottom_sheet/cubit/select_month_year_cubit.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSelectMonthYearBottomSheet(
    BuildContext context, Function(String) onMonthYearSelected) {
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
      return SelectMonthYearWidget(onMonthYearSelected);
    },
  );
}

class SelectMonthYearWidget extends StatefulWidget {
  final Function(String) onMonthYearSelected;

  const SelectMonthYearWidget(this.onMonthYearSelected, {Key? key})
      : super(key: key);

  @override
  _SelectMonthYearWidgetState createState() => _SelectMonthYearWidgetState();
}

class _SelectMonthYearWidgetState extends State<SelectMonthYearWidget> {
  final SelectMonthYearCubit _selectMonthYearCubit = sl<SelectMonthYearCubit>();

  @override
  void initState() {
    _selectMonthYearCubit.loadMonthYearList();
    super.initState();
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
                    'select_month'.tr,
                    style: Get.textTheme.headline7Bold,
                  ),
                ),
                buildCloseIcon(),
              ],
            ),
            buildMonthYearList(controller),
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
          MRouter.pop(null);
        },
        child: const Padding(
          padding: EdgeInsets.all(Dimens.padding_16),
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildMonthYearList(ScrollController scrollController) {
    return Expanded(
      child: StreamBuilder<List<String>>(
        stream: _selectMonthYearCubit.monthYearList,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return SingleChildScrollView(
              controller: scrollController,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 0),
                itemCount: snapshot.data?.length,
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Dimens.padding_24,
                        Dimens.padding_16,
                        Dimens.padding_24,
                        Dimens.padding_16),
                    child: MyInkWell(
                      onTap: () {
                        widget.onMonthYearSelected(snapshot.data![i]);
                        MRouter.pop(null);
                      },
                      child: Text(snapshot.data![i],
                          style: Get.textTheme.bodyText1),
                    ),
                  );
                },
              ),
            );
          } else {
            return AppCircularProgressIndicator();
          }
        },
      ),
    );
  }
}
