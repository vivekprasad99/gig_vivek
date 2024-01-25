import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/cubit/select_working_domain_cubit.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/model/working_domain.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_working_domain_bottom_sheet/widget/tile/working_domain_tile.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

final _selectWorkingDomainCubit = sl<SelectWorkingDomainCubit>();

void showSelectWorkingDomainBottomSheet(
    BuildContext context, Function(List<WorkingDomain>?) onSubmitTap) {
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
      return DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) {
          return Column(
            children: [
              buildCloseIcon(),
              buildWorkingDomainList(controller),
              buildSubmitButton(onSubmitTap),
            ],
          );
        },
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

Widget buildWorkingDomainList(ScrollController scrollController) {
  return StreamBuilder<List<WorkingDomain>>(
    stream: _selectWorkingDomainCubit.workingDomainListStream,
    builder: (context, items) {
      if (items.hasData) {
        return Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: items.data?.length,
            itemBuilder: (_, i) {
              return WorkingDomainTile(
                index: i,
                workingDomain: items.data![i],
                onTap: (index, workingDomain) {
                  _selectWorkingDomainCubit.updateWorkingDomainList(
                      index, workingDomain);
                },
              );
            },
          ),
        );
      } else {
        return AppCircularProgressIndicator();
      }
    },
  );
}

Widget buildSubmitButton(Function(List<WorkingDomain>?) onSubmitTap) {
  return Padding(
    padding: const EdgeInsets.all(Dimens.padding_24),
    child: RaisedRectButton(
      text: 'submit'.tr,
      onPressed: () {
        List<WorkingDomain>? selectedWorkingDomainList = _selectWorkingDomainCubit.getSelectedWorkingDomainList();
        onSubmitTap(selectedWorkingDomainList);
        MRouter.pop(null);
      },
    ),
  );
}
