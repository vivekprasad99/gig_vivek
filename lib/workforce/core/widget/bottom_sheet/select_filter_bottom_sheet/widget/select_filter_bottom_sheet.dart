import 'package:awign/packages/pagination_view/pagination_view.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_filter_bottom_sheet/cubit/select_filter_cubit.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/take_a_tour/welcome_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/university/data/model/navbar_item.dart';
import 'package:awign/workforce/university/feature/awign_university/cubit/awign_university_cubit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final _selectFilterCubit = sl<SelectFilterCubit>();

void showFilterBottomSheet(
    BuildContext context, Function(String) onSkillFilterTap) {
  showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return FilterBottomSheet(onSkillFilterTap);
      });
}

class FilterBottomSheet extends StatefulWidget {
  final Function(String) onSkillFilterTap;
  const FilterBottomSheet(this.onSkillFilterTap, {Key? key}) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (_, controller) {
        return Container(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_20,
                Dimens.margin_32, Dimens.padding_20, Dimens.padding_16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'filter_by_skills'.tr,
                      style: Get.context?.textTheme.titleLarge?.copyWith(
                          color: AppColors.black, fontWeight: FontWeight.w500),
                    ),
                    MyInkWell(
                      onTap: () {
                        MRouter.pop(null);
                      },
                      child: const CircleAvatar(
                        backgroundColor: AppColors.backgroundGrey700,
                        radius: 12,
                        child: Icon(
                          Icons.close,
                          color: AppColors.backgroundWhite,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimens.margin_12),
                HDivider(),
                buildUniversityList(controller),
              ],
            ));
      },
    );
  }

  Widget buildUniversityList(ScrollController scrollController) {
    return Expanded(
      child: StreamBuilder<List<SkillFilterData>>(
          stream: _selectFilterCubit.skillFilterDataListStream,
          builder: (context, skillFilterData) {
            if (skillFilterData.hasData) {
              return ListView.builder(
                  itemCount: skillFilterData.data!.length,
                  controller: scrollController,
                  itemBuilder: (_, i) {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        StreamBuilder<String>(
                            stream: _selectFilterCubit.radioTempItemStream,
                            builder: (context, snapshot) {
                              return RadioListTile<String?>(
                                value: skillFilterData.data![i].skillFilterItem,
                                groupValue: snapshot.data,
                                onChanged: (String? value) {
                                  widget.onSkillFilterTap(value!);
                                  _selectFilterCubit.onFilterRadioTap(value!);
                                  MRouter.pop(null);
                                },
                                title: Text(
                                  skillFilterData.data![i].skillFilterItem!,
                                  style: Get.context?.textTheme.labelLarge
                                      ?.copyWith(
                                          color: AppColors.backgroundGrey800,
                                          fontSize: Dimens.font_18,
                                          fontWeight: FontWeight.w500),
                                ),
                              );
                            }),
                      ],
                    );
                  });
            } else {
              return AppCircularProgressIndicator();
            }
          }),
    );
  }

//  onFilterRadioTap(String value) {

// }
}
