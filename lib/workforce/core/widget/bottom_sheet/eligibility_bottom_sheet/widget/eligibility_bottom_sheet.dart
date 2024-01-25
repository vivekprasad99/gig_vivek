import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../execution_in_house/data/model/eligibility_entity_response.dart';
import '../../../../di/app_injection_container.dart';
import '../../../theme/theme_manager.dart';
import '../cubit/eligibility_bottom_sheet_cubit.dart';

Future<bool>? eligibilityBottomSheet(
    BuildContext context,
    int? categoryApplicationId,
    int? workListingId,
    int? categoryId,
    Function(List<ApplicationAnswers>?, int?) onUpdateTap) {
  showModalBottomSheet<bool?>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return EligibilityBottomSheet(
            categoryApplicationId, workListingId, categoryId, onUpdateTap);
      });
}

class EligibilityBottomSheet extends StatefulWidget {
  final int? categoryApplicationId;
  final int? workListingId;
  final int? categoryId;
  final Function(List<ApplicationAnswers>?, int?) onUpdateTap;
  const EligibilityBottomSheet(this.categoryApplicationId, this.workListingId,
      this.categoryId, this.onUpdateTap,
      {Key? key})
      : super(key: key);

  @override
  State<EligibilityBottomSheet> createState() => _EligibilityBottomSheetState();
}

class _EligibilityBottomSheetState extends State<EligibilityBottomSheet> {
  final _eligibilityBottomSheetCubit = sl<EligibilityBottomSheetCubit>();

  @override
  void initState() {
    super.initState();
    _eligibilityBottomSheetCubit.getEligiblity(
        widget.categoryApplicationId, widget.workListingId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_32,
        Dimens.padding_16,
        Dimens.padding_32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'eligibility_criteria'.tr,
                style: Get.context?.textTheme.titleLarge?.copyWith(
                    color: AppColors.black, fontSize: Dimens.font_16),
              ),
              MyInkWell(
                onTap: () {
                  MRouter.pop(null);
                },
                child: const CircleAvatar(
                  backgroundColor: AppColors.backgroundGrey700,
                  radius: Dimens.padding_12,
                  child: Icon(
                    Icons.close,
                    color: AppColors.backgroundWhite,
                    size: Dimens.padding_16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimens.margin_16),
          showInEligigibilityText(),
          const SizedBox(height: Dimens.margin_16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
            child: Text(
              'update_application_text'.tr,
              textAlign: TextAlign.center,
              style: Get.context?.textTheme.titleLarge?.copyWith(
                  color: AppColors.black,
                  fontSize: Dimens.font_14,
                  fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(height: Dimens.margin_16),
          updateMyApplicationButton(),
        ],
      ),
    );
  }

  Widget updateMyApplicationButton() {
    return StreamBuilder<EligiblityEntityResponse>(
        stream: _eligibilityBottomSheetCubit.eligiblityEntityResponseStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RaisedRectButton(
              text: 'update_my_application'.tr,
              onPressed: () {
                widget.onUpdateTap(
                    snapshot.data!.applicationAnswers, widget.categoryId);
              },
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget showInEligigibilityText() {
    return StreamBuilder<EligiblityEntityResponse>(
        stream: _eligibilityBottomSheetCubit.eligiblityEntityResponseStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.applicationAnswers?.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                String message = snapshot.data?.applicationAnswers?[index]
                        .ineligibleWorklistings!["${widget.workListingId}"]
                    ["message"];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•',
                    ),
                    const SizedBox(width: Dimens.margin_8),
                    Expanded(
                      child: Text(
                        message,
                        style: Get.context?.textTheme.titleLarge?.copyWith(
                            color: AppColors.black,
                            fontSize: Dimens.font_14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            return const SizedBox();
          }
        });
  }
}
