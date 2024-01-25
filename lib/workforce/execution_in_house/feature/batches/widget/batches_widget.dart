import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/data_not_found.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/batches/cubit/batches_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/batches/widget/tile/batch_tile.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/batch_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'tile/batches_day_tile.dart';

class BatchesWidget extends StatefulWidget {
  final WorkApplicationEntity workApplicationEntity;

  const BatchesWidget(this.workApplicationEntity, {Key? key}) : super(key: key);

  @override
  State<BatchesWidget> createState() => _BatchesWidgetState();
}

class _BatchesWidgetState extends State<BatchesWidget> {
  final BatchesCubit _batchesCubit = sl<BatchesCubit>();
  UserData? _currentUser;
  bool isSkipSaasOrgID = false;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (spUtil!.getSaasOrgID().isNullOrEmpty) {
      isSkipSaasOrgID = true;
    }
    _batchesCubit.fetchTrainingBatches(
        _currentUser!.id!, widget.workApplicationEntity);
  }

  void subscribeUIStatus() {
    _batchesCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.scheduled:
            Helper.showInfoToast('batch_scheduled'.tr);
            MRouter.popNamedWithResult(widget.workApplicationEntity.fromRoute, Constants.doRefresh, true);
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: 'select_a_batch'.tr),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: StreamBuilder<List<DayBatchesEntity>>(
            stream: _batchesCubit.dayBatchesEntityListStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            buildDayList(snapshot.data!),
                            buildDayOfWeek(),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  Dimens.padding_16,
                                  Dimens.padding_8,
                                  Dimens.padding_16,
                                  0),
                              child: HDivider(),
                            ),
                            buildDayBatchesWidget(),
                          ],
                        ),
                      ),
                    ),
                    buildBottomButton(),
                  ],
                );
              } else if (snapshot.hasError) {
                return DataNotFound(error: snapshot.error?.toString() ?? '');
              } else {
                return AppCircularProgressIndicator();
              }
            }),
      ),
    );
  }

  Widget buildDayList(List<DayBatchesEntity> dayBatchesEntityList) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_8, Dimens.padding_8, Dimens.margin_8, 0),
        scrollDirection: Axis.horizontal,
        itemCount: dayBatchesEntityList.length,
        itemBuilder: (_, i) {
          DayBatchesEntity dayBatchesEntity = dayBatchesEntityList[i];
          return BatchesDayTile(
            index: i,
            dayBatchesEntity: dayBatchesEntity,
            onDayTapped: _onDayTapped,
          );
        },
      ),
    );
  }

  void _onDayTapped(int index, DayBatchesEntity dayBatchesEntity) {
    _batchesCubit.updateDayBatchesEntityList(index, dayBatchesEntity);
  }

  Widget buildDayOfWeek() {
    return StreamBuilder<DayBatchesEntity>(
        stream: _batchesCubit.selectedDayBatchesEntityStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
              child: Text(snapshot.data!.date.getPrettyWeekDay(),
                  style: Get.textTheme.headline4
                      ?.copyWith(fontWeight: FontWeight.w500)),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildDayBatchesWidget() {
    return StreamBuilder<List<BatchEntity>>(
        stream: _batchesCubit.allBatchesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, Dimens.padding_16, Dimens.margin_16, 0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (_, i) {
                return BatchTile(
                    index: i,
                    batchEntity: snapshot.data![i],
                    onBatchTapped: _dayBatchTapped);
              },
            );
          } else {
            return Column(
              children: [
                buildDayBatchesTitleWidget('(No ${'slot'.tr})'),
                const SizedBox(height: Dimens.padding_24),
              ],
            );
          }
        });
  }

  void _dayBatchTapped(int index, BatchEntity batchEntity) {
    _batchesCubit.updateAllSlotList(index, batchEntity);
  }

  Widget buildDayBatchesTitleWidget(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
      child: Row(
        children: [
          TextFieldLabel(label: text),
        ],
      ),
    );
  }

  Widget buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_24,
          Dimens.margin_16, Dimens.margin_24),
      child: RaisedRectButton(
        // height: Dimens.btnHeight_40,
        text: 'confirm_training_batch'.tr,
        onPressed: () {
          _batchesCubit.scheduleTrainingBatch(
              _currentUser?.id ?? -1, widget.workApplicationEntity);
        },
      ),
    );
  }
}
