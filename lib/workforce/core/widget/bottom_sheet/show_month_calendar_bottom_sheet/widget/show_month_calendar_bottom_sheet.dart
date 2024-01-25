import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/show_month_calendar_bottom_sheet/cubit/show_month_calendar_cubit.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/leaderboard/data/model/leaderboard_widget_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final _showMonthCalendarCubit = sl<ShowMonthCalendarCubit>();

void showMonthCalendarBottomSheet(BuildContext context) {
  showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return const ShowMonthCalendarBottomSheet();
      });
}

class ShowMonthCalendarBottomSheet extends StatefulWidget {
  const ShowMonthCalendarBottomSheet({Key? key}) : super(key: key);

  @override
  State<ShowMonthCalendarBottomSheet> createState() =>
      _ShowMonthCalendarBottomSheetState();
}

class _ShowMonthCalendarBottomSheetState
    extends State<ShowMonthCalendarBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: Dimens.margin_32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.margin_16, Dimens.padding_16, Dimens.margin_8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyInkWell(
                    onTap: () {}, child: buildBackAndNext(Icons.arrow_back_ios)),
                buildMonthCalendar(),
                MyInkWell(
                    onTap: () {},
                    child: buildBackAndNext(Icons.arrow_forward_ios))
              ],
            ),
          ),
          HDivider(),
          StreamBuilder<List<MonthData>>(
              stream: _showMonthCalendarCubit.monthDataListStream,
              builder: (context, monthData) {
                if (monthData.hasData) {
                  return GridView.builder(
                      itemCount: monthData.data!.length,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3,
                            crossAxisSpacing: 12,
                      ),
                      itemBuilder: (_, int index) {
                        return StreamBuilder<String?>(
                          stream: _showMonthCalendarCubit.getMonthStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                            return MyInkWell(
                              onTap: (){

                              },
                              child: Container(
                                height: Dimens.padding_36,
                                width: Dimens.etWidth_100,
                                decoration: BoxDecoration(
                                  color: snapshot.data!.contains(monthData.data![index].monthItem as Pattern) ? AppColors.backgroundBlack : AppColors.transparent,
                                  borderRadius: BorderRadius.circular(Dimens.margin_4)
                                ),
                                margin: const EdgeInsets.fromLTRB(Dimens.padding_40,
                                    Dimens.margin_8, Dimens.padding_40, Dimens.margin_4),
                                child: Center(
                                  child: Text('${monthData.data![index].monthItem}',
                                      style: context.textTheme.bodyLarge?.copyWith(
                                          color:snapshot.data!.contains(monthData.data![index].monthItem as Pattern) ? AppColors.backgroundWhite : AppColors.backgroundGrey600,
                                          fontSize: Dimens.font_16,
                                          fontWeight: FontWeight.w400)),
                                ),
                              ),
                            );
                            } else {
                              return const SizedBox();
                            }
                          }
                        );
                      });
                } else {
                  return const SizedBox();
                }
              }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RaisedRectButton(
                    height: Dimens.margin_40,
                    text: 'cancel'.tr,
                    onPressed: () {},
                    backgroundColor: AppColors.backgroundWhite,
                    textColor: AppColors.primaryMain,
                    borderColor: AppColors.primaryMain,
                  ),
                ),
                const SizedBox(width: Dimens.margin_24,),
                Expanded(
                  child: RaisedRectButton(
                    height: Dimens.margin_40,
                    text: 'apply'.tr,
                    onPressed: () {},
                    backgroundColor: AppColors.primaryMain,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildBackAndNext(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: Dimens.padding_4),
      child: Icon(
        icon,
        color: AppColors.backgroundGrey900,
        size: Dimens.padding_16,
      ),
    );
  }

  Widget buildMonthCalendar() {
    return Text('2023',
        style: Get.context?.textTheme.bodyLarge?.copyWith(
            color: AppColors.backgroundGrey900,
            fontSize: Dimens.font_18,
            fontWeight: FontWeight.w600));
  }
}
