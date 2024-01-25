import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_view_config_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showAddLeadAndRequestForWorkBottomSheet(
    BuildContext context,
        ListViews listView,
    bool isAddLead,
    bool isRequestForWork,
    Function(ListViews listView) onAddLeadTap,
    Function(ListViews listView) onRequestForWorkTap) {
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
      return AddLeadAndRequestForWorkBottomSheetWidget(listView,
          isAddLead, isRequestForWork, onAddLeadTap, onRequestForWorkTap);
    },
  );
}

class AddLeadAndRequestForWorkBottomSheetWidget extends StatefulWidget {
  final ListViews listView;
  final bool isAddLead;
  final bool isRequestForWork;
  final Function(ListViews listView) onAddLeadTap;
  final Function(ListViews listView) onRequestForWorkTap;

  const AddLeadAndRequestForWorkBottomSheetWidget(this.listView, this.isAddLead,
      this.isRequestForWork, this.onAddLeadTap, this.onRequestForWorkTap,
      {Key? key})
      : super(key: key);

  @override
  _SelectSignatureWidgetState createState() => _SelectSignatureWidgetState();
}

class _SelectSignatureWidgetState
    extends State<AddLeadAndRequestForWorkBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    double minChildSized = 0.18;
    if (widget.isAddLead && widget.isRequestForWork) {
      minChildSized = 0.25;
    }
    return DraggableScrollableSheet(
      expand: false,
      minChildSize: minChildSized,
      maxChildSize: minChildSized,
      initialChildSize: minChildSized,
      snap: true,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            // color: AppColors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.radius_16),
              topRight: Radius.circular(Dimens.radius_16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimens.padding_16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildCloseIcon(),
                Text('i_want_to'.tr, style: Get.textTheme.bodyText1SemiBold),
                buildAddLeadWidget(),
                SizedBox(
                    height: (widget.isAddLead && widget.isRequestForWork)
                        ? Dimens.padding_8
                        : 0),
                buildHDivider(),
                buildRequestForWorkWidget(),
              ],
            ),
          ),
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
        child: const Icon(Icons.close),
      ),
    );
  }

  Widget buildAddLeadWidget() {
    if (widget.isAddLead) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, Dimens.margin_16, 0, 0),
        child: MyInkWell(
          onTap: () {
            widget.onAddLeadTap(widget.listView);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.add,
                        color: AppColors.success200, size: Dimens.iconSize_20),
                    const SizedBox(width: Dimens.padding_16),
                    Text(
                      'add_new_task_by_yourself'.tr,
                      style: Get.textTheme.bodyText1,
                    )
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildHDivider() {
    if (widget.isAddLead && widget.isRequestForWork) {
      return HDivider();
    } else {
      return const SizedBox();
    }
  }

  Widget buildRequestForWorkWidget() {
    if (widget.isRequestForWork) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, Dimens.margin_16, 0, 0),
        child: MyInkWell(
          onTap: () {
            widget.onAddLeadTap(widget.listView);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.message,
                        color: AppColors.primaryMain, size: Dimens.iconSize_20),
                    const SizedBox(width: Dimens.padding_16),
                    Text(
                      'request_task_from_manager'.tr,
                      style: Get.textTheme.bodyText1,
                    )
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
