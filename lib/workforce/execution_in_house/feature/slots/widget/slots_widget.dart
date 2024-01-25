import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/data_not_found.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/slots/cubit/slots_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/slots/widget/tile/day_tile.dart';
import 'package:awign/workforce/execution_in_house/feature/slots/widget/tile/slot_tile.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/slot_entity.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SlotsWidget extends StatefulWidget {
  final WorkApplicationEntity workApplicationEntity;

  const SlotsWidget(this.workApplicationEntity, {Key? key}) : super(key: key);

  @override
  State<SlotsWidget> createState() => _SlotsWidgetState();
}

class _SlotsWidgetState extends State<SlotsWidget> {
  final SlotsCubit _slotsCubit = sl<SlotsCubit>();
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
    _slotsCubit.fetchInterviewSlots(
        _currentUser!.id!, widget.workApplicationEntity);
  }

  void subscribeUIStatus() {
    _slotsCubit.uiStatus.listen(
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
            Helper.showInfoToast('slot_scheduled'.tr);
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: 'select_a_time_slot'.tr),
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
        child: StreamBuilder<List<DaySlotsEntity>>(
            stream: _slotsCubit.daySlotsEntityListStream,
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
                            buildMorningSlotsWidget(),
                            const SizedBox(height: Dimens.padding_16),
                            buildNoonSlotsWidget(),
                            const SizedBox(height: Dimens.padding_16),
                            buildEveningSlotsWidget(),
                          ],
                        ),
                      ),
                    ),
                    buildBottomButton(),
                  ],
                );
              }
              if (snapshot.hasData) {
                return DataNotFound(error: snapshot.error?.toString() ?? '');
              } else {
                return AppCircularProgressIndicator();
              }
            }),
      ),
    );
  }

  Widget buildDayList(List<DaySlotsEntity> daySlotsEntityList) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        // shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_8, Dimens.padding_8, Dimens.margin_8, 0),
        scrollDirection: Axis.horizontal,
        itemCount: daySlotsEntityList.length,
        itemBuilder: (_, i) {
          // String key = slots.keys.elementAt(i);
          // List<List<SlotEntity>>? slotsListList = slots[key];
          DaySlotsEntity daySlotsEntity = daySlotsEntityList[i];
          return DayTile(
            index: i,
            daySlotsEntity: daySlotsEntity,
            onDayTapped: _onDayTapped,
          );
        },
      ),
    );
  }

  void _onDayTapped(int index, DaySlotsEntity daySlotsEntity) {
    _slotsCubit.updateDaySlotsEntityList(index, daySlotsEntity);
  }

  Widget buildDayOfWeek() {
    return StreamBuilder<DaySlotsEntity>(
        stream: _slotsCubit.selectedDaySlotsEntityStream,
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

  Widget buildMorningSlotsWidget() {
    return StreamBuilder<List<SlotEntity>>(
        stream: _slotsCubit.morningSlotsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return StreamBuilder<bool>(
                stream: _slotsCubit.isViewMoreMorningSlotsStream,
                builder: (context, isViewMoreMorningSlotsStream) {
                  if (isViewMoreMorningSlotsStream.hasData) {
                    return Column(
                      children: [
                        buildMorningSlotsTitleWidget(
                            '${'morning'.tr} (${snapshot.data!.length} ${snapshot.data!.length > 1 ? 'slots'.tr : 'slot'.tr})'),
                        GridView.builder(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                              Dimens.padding_16, Dimens.margin_16, 0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length > 8
                              ? (isViewMoreMorningSlotsStream.data!
                                  ? snapshot.data!.length
                                  : 8)
                              : snapshot.data!.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.9,
                            crossAxisSpacing: Dimens.padding_8,
                            mainAxisSpacing: Dimens.padding_8,
                          ),
                          itemBuilder: (_, i) {
                            return SlotTile(
                                index: i,
                                slotEntity: snapshot.data![i],
                                onSlotTapped: _morningSlotTapped);
                          },
                        ),
                        buildMorningSlotsViewMoreWidget(snapshot.data!.length,
                            isViewMoreMorningSlotsStream.data!),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                });
          } else {
            return Column(
              children: [
                buildMorningSlotsTitleWidget(
                    '${'morning'.tr} (No ${'slot'.tr})'),
                const SizedBox(height: Dimens.padding_24),
              ],
            );
          }
        });
  }

  void _morningSlotTapped(int index, SlotEntity slotEntity) {
    _slotsCubit.updateMorningSlotList(index, slotEntity);
  }

  Widget buildMorningSlotsTitleWidget(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
      child: Row(
        children: [
          SvgPicture.asset('assets/images/ic_morning.svg'),
          const SizedBox(width: Dimens.padding_8),
          TextFieldLabel(label: text),
        ],
      ),
    );
  }

  Widget buildMorningSlotsViewMoreWidget(int length, bool isViewMore) {
    if (length > 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
        child: MyInkWell(
          onTap: () {
            _slotsCubit.changeIsViewMoreMorningSlots(!isViewMore);
          },
          child: Row(
            children: [
              TextFieldLabel(
                  label: isViewMore ? 'view_less'.tr : 'view_more'.tr,
                  color: AppColors.primaryMain),
              const SizedBox(width: Dimens.padding_8),
              Icon(
                isViewMore
                    ? Icons.arrow_drop_up_outlined
                    : Icons.arrow_drop_down_outlined,
                size: Dimens.iconSize_16,
                color: AppColors.primaryMain,
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildNoonSlotsWidget() {
    return StreamBuilder<List<SlotEntity>>(
        stream: _slotsCubit.noonSlotsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return StreamBuilder<bool>(
                stream: _slotsCubit.isViewMoreNoonSlotsStream,
                builder: (context, isViewMoreNoonSlotsStream) {
                  if (isViewMoreNoonSlotsStream.hasData) {
                    return Column(
                      children: [
                        buildNoonSlotsTitleWidget(
                            '${'afternoon'.tr} (${snapshot.data!.length} ${snapshot.data!.length > 1 ? 'slots'.tr : 'slot'.tr})'),
                        GridView.builder(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                              Dimens.padding_16, Dimens.margin_16, 0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length > 8
                              ? (isViewMoreNoonSlotsStream.data!
                                  ? snapshot.data!.length
                                  : 8)
                              : snapshot.data!.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.9,
                            crossAxisSpacing: Dimens.padding_8,
                            mainAxisSpacing: Dimens.padding_8,
                          ),
                          itemBuilder: (_, i) {
                            return SlotTile(
                                index: i,
                                slotEntity: snapshot.data![i],
                                onSlotTapped: _noonSlotTapped);
                          },
                        ),
                        buildNoonSlotsViewMoreWidget(snapshot.data!.length,
                            isViewMoreNoonSlotsStream.data!),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                });
          } else {
            return Column(
              children: [
                buildNoonSlotsTitleWidget(
                    '${'afternoon'.tr} (No ${'slot'.tr})'),
                const SizedBox(height: Dimens.padding_24),
              ],
            );
          }
        });
  }

  void _noonSlotTapped(int index, SlotEntity slotEntity) {
    _slotsCubit.updateNoonSlotList(index, slotEntity);
  }

  Widget buildNoonSlotsTitleWidget(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
      child: Row(
        children: [
          SvgPicture.asset('assets/images/ic_afternoon.svg'),
          const SizedBox(width: Dimens.padding_8),
          TextFieldLabel(label: text),
        ],
      ),
    );
  }

  Widget buildNoonSlotsViewMoreWidget(int length, bool isViewMore) {
    if (length > 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
        child: MyInkWell(
          onTap: () {
            _slotsCubit.changeIsViewMoreNoonSlots(!isViewMore);
          },
          child: Row(
            children: [
              TextFieldLabel(
                  label: isViewMore ? 'view_less'.tr : 'view_more'.tr,
                  color: AppColors.primaryMain),
              const SizedBox(width: Dimens.padding_8),
              Icon(
                isViewMore
                    ? Icons.arrow_drop_up_outlined
                    : Icons.arrow_drop_down_outlined,
                size: Dimens.iconSize_16,
                color: AppColors.primaryMain,
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildEveningSlotsWidget() {
    return StreamBuilder<List<SlotEntity>>(
        stream: _slotsCubit.eveningSlotsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return StreamBuilder<bool>(
                stream: _slotsCubit.isViewMoreEveningSlotsStream,
                builder: (context, isViewMoreEveningSlotsStream) {
                  if (isViewMoreEveningSlotsStream.hasData) {
                    return Column(
                      children: [
                        buildEveningSlotsTitleWidget(
                            '${'evening'.tr} (${snapshot.data!.length} ${snapshot.data!.length > 1 ? 'slots'.tr : 'slot'.tr})'),
                        GridView.builder(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                              Dimens.padding_16, Dimens.margin_16, 0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length > 8
                              ? (isViewMoreEveningSlotsStream.data!
                                  ? snapshot.data!.length
                                  : 8)
                              : snapshot.data!.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.9,
                            crossAxisSpacing: Dimens.padding_8,
                            mainAxisSpacing: Dimens.padding_8,
                          ),
                          itemBuilder: (_, i) {
                            return SlotTile(
                                index: i,
                                slotEntity: snapshot.data![i],
                                onSlotTapped: _eveningSlotTapped);
                          },
                        ),
                        buildEveningSlotsViewMoreWidget(snapshot.data!.length,
                            isViewMoreEveningSlotsStream.data!),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                });
          } else {
            return Column(
              children: [
                buildEveningSlotsTitleWidget(
                    '${'evening'.tr} (No ${'slot'.tr})'),
                const SizedBox(height: Dimens.padding_24),
              ],
            );
          }
        });
  }

  void _eveningSlotTapped(int index, SlotEntity slotEntity) {
    _slotsCubit.updateEveningSlotList(index, slotEntity);
  }

  Widget buildEveningSlotsTitleWidget(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
      child: Row(
        children: [
          SvgPicture.asset('assets/images/ic_night.svg'),
          const SizedBox(width: Dimens.padding_8),
          TextFieldLabel(label: text),
        ],
      ),
    );
  }

  Widget buildEveningSlotsViewMoreWidget(int length, bool isViewMore) {
    if (length > 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, Dimens.padding_8, Dimens.padding_16, 0),
        child: MyInkWell(
          onTap: () {
            _slotsCubit.changeIsViewMoreEveningSlots(!isViewMore);
          },
          child: Row(
            children: [
              TextFieldLabel(
                  label: isViewMore ? 'view_less'.tr : 'view_more'.tr,
                  color: AppColors.primaryMain),
              const SizedBox(width: Dimens.padding_8),
              Icon(
                isViewMore
                    ? Icons.arrow_drop_up_outlined
                    : Icons.arrow_drop_down_outlined,
                size: Dimens.iconSize_16,
                color: AppColors.primaryMain,
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_24,
          Dimens.margin_16, Dimens.margin_16),
      child: RaisedRectButton(
        height: Dimens.btnHeight_40,
        text: 'schedule_slot'.tr,
        onPressed: () {
          _slotsCubit.scheduleTelephonicInterview(_currentUser?.id ?? -1,
              _currentUser?.mobileNumber ?? '', widget.workApplicationEntity);
        },
      ),
    );
  }
}
