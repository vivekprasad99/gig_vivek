import 'dart:async';

import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/pin_locked_bottom_sheet/cubit/pin_locked_bottom_sheet_cubit.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showPINLockedBottomSheet(
    BuildContext context, Function(WidgetResult) onResult) {
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
          return PINLockedWidget(onResult);
        },
      );
    },
  );
}

class PINLockedWidget extends StatefulWidget {
  final Function(WidgetResult) onResult;

  const PINLockedWidget(this.onResult, {Key? key}) : super(key: key);

  @override
  State<PINLockedWidget> createState() => _PINLockedWidgetState();
}

class _PINLockedWidgetState extends State<PINLockedWidget> {
  final PinLockedBottomSheetCubit _pinLockedBottomSheetCubit =
      sl<PinLockedBottomSheetCubit>();
  Timer? countdownTimer;
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    _checkBlockedTime();
  }

  _checkBlockedTime() {
    if (_currentUser != null &&
        _currentUser!.pinBlockedTill != null &&
        _currentUser!.pinBlockedTill!.getDateTimeObjectFromUTCDateTime() !=
            null) {
      _pinLockedBottomSheetCubit.changeCurrentUser(_currentUser!);
      DateTime blockedDateTime =
          _currentUser!.pinBlockedTill!.getDateTimeObjectFromUTCDateTime()!;
      DateTime currentDateTime = DateTime.now();
      _pinLockedBottomSheetCubit.changeDuration(Duration(
          seconds: blockedDateTime.difference(currentDateTime).inSeconds));
      startTimer();
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDownTime());
  }

  void setCountDownTime() {
    const reduceSecondsBy = 1;
    final seconds =
        _pinLockedBottomSheetCubit.durationValue.inSeconds - reduceSecondsBy;
    if (seconds < 0) {
      countdownTimer!.cancel();
      widget.onResult(WidgetResult(event: Event.success));
    } else {
      _pinLockedBottomSheetCubit.changeDuration(Duration(seconds: seconds));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        widget.onResult(WidgetResult(event: Event.failed));
        return Future.value(true);
      },
      child: Column(
        children: [
          buildCloseIcon(),
          buildLockIcon(),
          buildPageLockedText(),
          buildDescriptionText(),
          buildOkayButton(),
          buildContactSupportButton(),
        ],
      ),
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
          widget.onResult(WidgetResult(event: Event.failed));
        },
        child: const Padding(
          padding: EdgeInsets.all(Dimens.padding_16),
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildLockIcon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child:
          Icon(Icons.lock, color: AppColors.error300, size: Dimens.iconSize_32),
    );
  }

  Widget buildPageLockedText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Text('page_locked'.tr, style: context.textTheme.headline7SemiBold),
    );
  }

  Widget buildDescriptionText() {
    return StreamBuilder<Duration>(
      stream: _pinLockedBottomSheetCubit.duration,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final hours = StringUtils.convertDigitsToString(
              snapshot.data!.inHours.remainder(24));
          final minutes = StringUtils.convertDigitsToString(
              snapshot.data!.inMinutes.remainder(60));
          final seconds = StringUtils.convertDigitsToString(
              snapshot.data!.inSeconds.remainder(60));
          if (_pinLockedBottomSheetCubit.durationValue.inSeconds < (59 * 60)) {
            return Padding(
              padding: const EdgeInsets.all(Dimens.padding_16),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: context.textTheme.bodyText1
                      ?.copyWith(color: AppColors.backgroundGrey700),
                  children: <TextSpan>[
                    const TextSpan(
                      text:
                          'Seems you have entered wrong PIN too many times. Please wait for ',
                    ),
                    buildTimerWidget('0', minutes, seconds),
                    const TextSpan(
                      text: ' for entering PIN again',
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(Dimens.padding_16),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: context.textTheme.bodyText1,
                  children: <TextSpan>[
                    const TextSpan(
                      text:
                          'You have reached the maximum number of PIN trials. Please try again after ',
                    ),
                    buildTimerWidget(hours, minutes, seconds),
                  ],
                ),
              ),
            );
          }
        } else {
          return const Padding(
            padding: EdgeInsets.all(Dimens.padding_16),
            child: Text(''),
          );
        }
      },
    );
  }

  TextSpan buildTimerWidget(String hours, String minutes, String seconds) {
    if (int.parse(hours) > 0) {
      return TextSpan(
        text: '$hours hour $minutes min',
        style:
            context.textTheme.bodyText1?.copyWith(color: AppColors.warning300),
      );
    } else {
      return TextSpan(
        text: '$minutes min $seconds sec',
        style:
            context.textTheme.bodyText1?.copyWith(color: AppColors.warning300),
      );
    }
  }

  Widget buildOkayButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: RaisedRectButton(
        text: 'okay_got_it'.tr,
        onPressed: () {
          MRouter.pop(null);
          widget.onResult(WidgetResult(event: Event.failed));
        },
      ),
    );
  }

  Widget buildContactSupportButton() {
    return StreamBuilder<UserData>(
      stream: _pinLockedBottomSheetCubit.currentUser,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.pinBlockedTill != null &&
            snapshot.data!.pinBlockedTill!.getDateTimeObjectFromUTCDateTime() !=
                null &&
            snapshot.data!.pinBlockedTill!
                    .getDateTimeObjectFromUTCDateTime()!
                    .millisecondsSinceEpoch >
                (DateTime.now().millisecondsSinceEpoch + (59 * 60 * 1000))) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
            child: CustomTextButton(
              text: 'contact_support'.tr,
              backgroundColor: AppColors.transparent,
              borderColor: AppColors.backgroundGrey800,
              textColor: AppColors.backgroundGrey800,
              onPressed: () {
                MRouter.pushNamed(MRouter.faqAndSupportWidget);
              },
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
