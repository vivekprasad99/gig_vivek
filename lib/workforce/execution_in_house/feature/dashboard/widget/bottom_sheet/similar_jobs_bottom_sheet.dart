import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/dashboard/widget/bottom_sheet/tile/similar_job_tile.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/data/work_listing_details_arguments.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSimilarJobsBottomSheet(
    BuildContext context,
    List<WorkApplicationEntity> jobList,
    Function(WorkApplicationEntity) onJobTap) {
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
      return SimilarJobsWidget(jobList, onJobTap);
    },
  );
}

class SimilarJobsWidget extends StatefulWidget {
  final List<WorkApplicationEntity> jobList;
  final Function(WorkApplicationEntity) onJobTap;

  const SimilarJobsWidget(this.jobList, this.onJobTap, {Key? key})
      : super(key: key);

  @override
  _SimilarJobsWidgetState createState() => _SimilarJobsWidgetState();
}

class _SimilarJobsWidgetState extends State<SimilarJobsWidget> {
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
                    'similar_digital_gigs_jobs'.tr,
                    style: Get.textTheme.headline6
                        ?.copyWith(color: AppColors.backgroundBlack),
                  ),
                ),
                buildCloseIcon(),
              ],
            ),
            buildJobsList(controller),
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

  Widget buildJobsList(ScrollController scrollController) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.jobList.length,
        controller: scrollController,
        padding: const EdgeInsets.only(top: 0),
        itemBuilder: (_, i) {
          return SimilarJobTile(
            index: i,
            workApplicationEntity: widget.jobList[i],
            onJobSelected: _onJobSelected,
          );
        },
      ),
    );
  }

  _onJobSelected(int index, WorkApplicationEntity workApplicationEntity) {
    MRouter.pushNamed(MRouter.workListingDetailsWidget,
        arguments: WorkListingDetailsArguments(
            workApplicationEntity.workListingId?.toString() ?? '-1',
            fromRoute: MRouter.dashboardWidget));
  }
}
