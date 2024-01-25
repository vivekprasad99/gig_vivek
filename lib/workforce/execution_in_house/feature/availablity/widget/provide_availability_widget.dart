import 'dart:async';

import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/available_entity.dart';
import 'package:awign/workforce/execution_in_house/feature/availablity/cubit/availablity_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/availablity/widget/tile/availability_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ProvideAvailabilityWidget extends StatefulWidget {
  final Map<String, dynamic> cleverTapEvent;
  const ProvideAvailabilityWidget(this.cleverTapEvent, {Key? key})
      : super(key: key);

  @override
  State<ProvideAvailabilityWidget> createState() =>
      _ProvideAvailabilityWidgetState();
}

class _ProvideAvailabilityWidgetState extends State<ProvideAvailabilityWidget> {
  final AvailabilityCubit _availablityCubit = sl<AvailabilityCubit>();
  UserData? _currentUser;
  bool slotCreated = false;
  late String realTime;
  bool isTommorow = false;

  @override
  void initState() {
    realTime = "${DateTime.now().hour} : ${DateTime.now().minute}";
    Timer.periodic(
        const Duration(seconds: 1),
        (Timer t) => WidgetsBinding.instance
            .addPostFrameCallback((_) => _getCurrentTime()));
    super.initState();
    getCurrentUser();
    subscribeUIStatus();
  }

  void _getCurrentTime() {
    if (mounted) {
      setState(() {
        realTime = "${DateTime.now().hour} : ${DateTime.now().minute}";
      });
    }
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    String memberId = _currentUser!.ihOmsId!;
    if (isTommorow) {
      _availablityCubit.memberTimeSlotResponseValue.memberTimeSlot?.date =
          DateFormat(StringUtils.dateFormatYMD).format(DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day + 1));
      _availablityCubit.getUpcomingSlots(
          memberId,
          DateFormat(StringUtils.dateFormatYMD).format(DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day + 1)));
    } else {
      _availablityCubit.memberTimeSlotResponseValue.memberTimeSlot?.date =
          DateFormat('yyyy-MM-dd').format(DateTime.now());
      _availablityCubit.getUpcomingSlots(
          memberId, DateFormat('yyyy-MM-dd').format(DateTime.now()));
    }
  }

  void subscribeUIStatus() {
    _availablityCubit.uiStatus.listen(
      (uiStatus) {
        switch (uiStatus.event) {
          case Event.success:
            slotCreated = true;
            break;
          case Event.failed:
            slotCreated = false;
            break;
          case Event.updated:
            isTommorow = true;
            getCurrentUser();
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
            DefaultAppBar(
                isCollapsable: true,
                isActionVisible: false,
                title: 'provide_availability'.tr),
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
        child: StreamBuilder<UIStatus>(
            stream: _availablityCubit.uiStatus,
            builder: (context, uiStatus) {
              if (uiStatus.hasData &&
                  (uiStatus.data?.isOnScreenLoading ?? false)) {
                return AppCircularProgressIndicator();
              } else {
                return Column(
                  children: [
                    StreamBuilder<bool>(
                        stream: _availablityCubit.isChecked,
                        builder: (context, snapshot) {
                          return snapshot.data ?? false
                              ? buildNotAvailableWidget()
                              : Expanded(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: isTommorow
                                          ? const EdgeInsets.fromLTRB(
                                              Dimens.padding_16,
                                              Dimens.padding_4,
                                              Dimens.padding_16,
                                              Dimens.padding_16)
                                          : const EdgeInsets.fromLTRB(
                                              Dimens.padding_16,
                                              Dimens.padding_36,
                                              Dimens.padding_16,
                                              Dimens.padding_16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          buildCopySchedule(),
                                          ListTile(
                                            visualDensity: const VisualDensity(
                                              horizontal: -4,
                                              vertical: -4,
                                            ),
                                            leading: SvgPicture.asset(
                                              'assets/images/ic_calendar.svg',
                                            ),
                                            title: Text(
                                              !isTommorow
                                                  ? 'today'.tr
                                                  : 'tomorrow'.tr,
                                              style: Get
                                                  .context?.textTheme.bodyMedium
                                                  ?.copyWith(
                                                      color: AppColors
                                                          .backgroundGrey800),
                                            ),
                                            subtitle: Text(
                                              isTommorow
                                                  ? '${StringUtils.getMonth(DateTime.now())} ${DateFormat('yyyy-MM-dd').format(DateTime.now()).getTommorowWeekDay()}, ${StringUtils.getNextWeekDay(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1))}'
                                                  : '${StringUtils.getMonth(DateTime.now())} ${DateFormat('yyyy-MM-dd').format(DateTime.now()).getTodayWeekDay()}, ${StringUtils.getWeekDay(DateTime.now())}',
                                              style: Get
                                                  .context?.textTheme.titleLarge
                                                  ?.copyWith(
                                                      color: AppColors
                                                          .backgroundGrey900,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: Dimens.font_18),
                                            ),
                                          ),
                                          const SizedBox(
                                              height: Dimens.margin_24),
                                          Text(
                                            isTommorow
                                                ? 'please_provide_your_availability_for_tomorrow_so_that_we_can_allocate_tasks_accordingly'
                                                    .tr
                                                : 'please_provide_your_availability_for_today_so_that_we_can_allocate_tasks_accordingly'
                                                    .tr,
                                            style: Get
                                                .context?.textTheme.bodyMedium
                                                ?.copyWith(
                                                    color: AppColors
                                                        .backgroundGrey800,
                                                    fontSize: Dimens.font_16),
                                          ),
                                          const SizedBox(
                                              height: Dimens.margin_16),
                                          MyInkWell(
                                            onTap: () {
                                              bool result = _availablityCubit
                                                  .validateRequiredAnswers();
                                              if (result) {
                                                _availablityCubit.addSlot(
                                                    widget.cleverTapEvent);
                                              } else {
                                                Helper.showErrorToast(
                                                    'Please fill the slot');
                                              }
                                            },
                                            child: Text(
                                              'add_more_slot'.tr,
                                              style: context.textTheme.bodyText1
                                                  ?.copyWith(
                                                      color: context.theme
                                                          .iconColorHighlighted,
                                                      fontWeight:
                                                          FontWeight.w500),
                                            ),
                                          ),
                                          const SizedBox(
                                              height: Dimens.margin_16),
                                          buildSlotList(),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                        }),
                    HDivider(),
                    StreamBuilder<bool>(
                        stream: _availablityCubit.isChecked,
                        builder: (context, snapshot) {
                          return CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            checkColor: AppColors.backgroundWhite,
                            tileColor: AppColors.backgroundWhite,
                            activeColor: AppColors.secondary2Default,
                            title: Text(
                              'i_am_not_available_to_work_today'.tr,
                              style: Get.context?.textTheme.bodyMedium
                                  ?.copyWith(
                                      color: AppColors.black,
                                      fontSize: Dimens.font_18),
                            ),
                            value: _availablityCubit.isCheckedValue,
                            onChanged: (value) {
                              _availablityCubit.onCheckBoxTap(
                                  value!, widget.cleverTapEvent);
                            },
                          );
                        }),
                    buildNextButton(),
                  ],
                );
              }
            }),
      ),
    );
  }

  Widget buildNextButton() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_40,
            Dimens.padding_16, Dimens.padding_32),
        child: RaisedRectButton(
          text: !isTommorow ? 'confirm_and_next'.tr : 'submit'.tr,
          onPressed: () {
            onCreateSlotClicked(widget.cleverTapEvent);
          },
        ));
  }

  Widget buildCopySchedule() {
    return isTommorow
        ? Padding(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
            child: Column(
              children: [
                StreamBuilder<bool>(
                    stream: _availablityCubit.isTodayChecked,
                    builder: (context, snapshot) {
                      return CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        checkColor: AppColors.backgroundWhite,
                        tileColor: AppColors.backgroundWhite,
                        activeColor: AppColors.secondary2Default,
                        title: Text(
                          'Copy Today${"'"}s Schedule'.tr,
                          style: Get.context?.textTheme.bodyMedium?.copyWith(
                              color: AppColors.black, fontSize: Dimens.font_18),
                        ),
                        value: _availablityCubit.isTodayCheckedValue,
                        onChanged: (value) {
                          _availablityCubit.onTodayCheckBoxTap(value!);
                          _availablityCubit.showTodaySchedule(value);
                          if (value) {
                            ClevertapHelper.instance().addCleverTapEvent(
                                ClevertapHelper.copyScheduleFromToday,
                                widget.cleverTapEvent);
                          }
                        },
                      );
                    }),
                HDivider(),
              ],
            ),
          )
        : const SizedBox();
  }

  Widget buildSlotList() {
    return StreamBuilder<List<Slot>>(
      stream: _availablityCubit.slotListStream,
      builder: (context, slotListStream) {
        if (slotListStream.hasData &&
            slotListStream.data != null &&
            slotListStream.data!.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 0),
            itemCount: slotListStream.data?.length,
            itemBuilder: (_, i) {
              return AvailabilityTile(slotListStream.data![i], onStartTap,
                  onEndTap, i, onDeleteTap);
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildNotAvailableWidget() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/ic_calendar_delete.svg',
          ),
          const SizedBox(height: Dimens.margin_12),
          Text(
            'not_available_today'.tr,
            style: Get.context?.textTheme.bodyMedium?.copyWith(
                color: AppColors.black,
                fontSize: Dimens.font_20,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Dimens.margin_12),
          Text(
            'provide_schedule_in_order_to_nwork_today'.tr,
            textAlign: TextAlign.center,
            style: Get.context?.textTheme.bodyMedium?.copyWith(
                color: AppColors.backgroundGrey800,
                fontSize: Dimens.font_14,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  onStartTap(int index, Slot slot) async {
    TimeOfDay? pickedTime1 = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: int.parse(realTime.split(":")[0]),
            minute: int.parse(realTime.split(":")[1])));
    if (pickedTime1 == null) return null;
    DateTime now = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, pickedTime1.hour, pickedTime1.minute);
    DateFormat dateFormat = DateFormat(StringUtils.dateTimeFormatYMDHMS);
    String string = dateFormat.format(now);
    slot.startTime = string;
    _availablityCubit.updateSlotList(index, slot);
  }

  onEndTap(int index, Slot slot) async {
    TimeOfDay? pickedTime2 = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: int.parse(realTime.split(":")[0]),
            minute: int.parse(realTime.split(":")[1])));
    if (pickedTime2 == null) return null;
    DateTime now = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, pickedTime2.hour, pickedTime2.minute);
    DateFormat dateFormat = DateFormat(StringUtils.dateTimeFormatYMDHMS);
    String string = dateFormat.format(now);
    slot.endTime = string;
    _availablityCubit.updateSlotList(index, slot);
  }

  onDeleteTap(int index) {
    Future<ConfirmAction?> deleteTap = Helper.asyncConfirmDialog(
        context, 'are_you_sure'.tr,
        heading: 'Delete Slot', textOKBtn: 'yes'.tr, textCancelBtn: 'no'.tr);
    deleteTap.then((value) {
      if (value == ConfirmAction.OK) {
        _availablityCubit.deleteSlot(index);
      }
    });
  }

  bool isTimeStampCorrect() {
    for (var i = 0; i < _availablityCubit.slotListValue.length; i++) {
      if (!isStartTimeValid(i) || !isEndTimeValid(i)) {
        return false;
      }
    }
    return true;
  }

  bool isStartTimeValid(int position) {
    late String time;
    if (_availablityCubit.slotListValue[position].startTime.isNullOrEmpty) {
      return false;
    } else {
      time = _availablityCubit.slotListValue[position].startTime ?? "";
    }
    DateTime startTime =
        DateFormat(StringUtils.dateTimeFormatYMDhMS).parse(time);
    DateTime currentTime = getTimeWithForward();
    if ((_availablityCubit.slotListValue[position].isUpdated ?? false) &&
        startTime.isBefore(currentTime)) {
      return false;
    }
    return validateTime(startTime, position);
  }

  bool validateTime(DateTime time, int position) {
    final now = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 23, 59, 59);
    if (now.isBefore(time)) {
      return false;
    }
    int index = 0;
    for (Slot? slot in _availablityCubit.slotListValue) {
      if (index < position) {
        if (slot!.startTime == null || slot.endTime == null) {
          return false;
        }
        // if (slot!.startTime <= time && slot.endTime!! >= time) return false
        // if(slot!.startTime )
        //   {
        //
        //   }
      } else {
        break;
      }
      index++;
    }
    return true;
  }

  bool isEndTimeValid(int position) {
    late String time;
    if (_availablityCubit.slotListValue[position].endTime.isNullOrEmpty) {
      return false;
    } else {
      time = _availablityCubit.slotListValue[position].endTime ?? "";
    }
    DateTime endTime = DateFormat(StringUtils.dateTimeFormatYMDhMS).parse(time);
    DateTime currentTime = getTimeWithForward();
    if (endTime.isBefore(currentTime)) {
      return false;
    }
    return _availablityCubit.slotListValue[position].startTime != null &&
        validateTime(endTime, position);
  }

  DateTime getTimeWithForward() {
    final today = DateTime.now();
    return today.subtract(const Duration(minutes: 2));
  }

  void onCreateSlotClicked(Map<String, dynamic> cleverTapEvent) {
    if (isTimeStampCorrect() || _availablityCubit.isCheckedValue) {
      if (_availablityCubit.slotListValue.isEmpty ||
          _availablityCubit.isCheckedValue) {
        _availablityCubit.memberTimeSlotResponseValue.memberTimeSlot?.sStatus =
            "not_working";
      } else {
        _availablityCubit.memberTimeSlotResponseValue.memberTimeSlot?.sStatus =
            "working";
      }
      String memberId = _currentUser!.ihOmsId!;
      if (slotCreated &&
          _availablityCubit.memberTimeSlotResponseValue.memberTimeSlot?.sId !=
              null) {
        _availablityCubit.updateAvailabilitySlots(
            memberId,
            _availablityCubit.memberTimeSlotResponseValue.memberTimeSlot!.sId!,
            _availablityCubit.memberTimeSlotResponseValue,
            cleverTapEvent);
      } else {
        _availablityCubit.createAvailabilitySlots(memberId,
            _availablityCubit.memberTimeSlotResponseValue, cleverTapEvent);
      }
      if (isTommorow) {
        MRouter.pop(null);
      }
    } else {
      Helper.showErrorToast('Please fill correct time to continue');
    }
  }
}
