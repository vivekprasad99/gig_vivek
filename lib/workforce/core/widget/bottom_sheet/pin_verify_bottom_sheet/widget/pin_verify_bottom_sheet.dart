import 'dart:async';

import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/pin_verify_bottom_sheet/cubit/pin_verify_bottom_sheet_cubit.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

void showPINVerifyBottomSheet(
    BuildContext context, Function(WidgetResult) onResult) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return PINVerifyWidget(onResult);
          },
        ),
      );
    },
  );
}

class PINVerifyWidget extends StatefulWidget {
  final Function(WidgetResult) onResult;

  const PINVerifyWidget(this.onResult, {Key? key}) : super(key: key);

  @override
  State<PINVerifyWidget> createState() => _PINVerifyWidgetState();
}

class _PINVerifyWidgetState extends State<PINVerifyWidget> {
  final PinVerifyBottomSheetCubit _pinVerifyBottomSheetCubit =
      sl<PinVerifyBottomSheetCubit>();
  final TextEditingController _pinController = TextEditingController();
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getUserData();
  }

  void subscribeUIStatus() {
    _pinVerifyBottomSheetCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.verified:
            MRouter.pop(null);
            widget.onResult(WidgetResult(event: Event.success));
            break;
          case Event.updated:
            MRouter.pop(null);
            widget.onResult(WidgetResult(event: Event.updated));
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  void getUserData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildCloseIcon(),
          buildLockIcon(),
          buildPageLockedText(),
          buildPINTextField(),
          buildConfirmButton(),
          buildForgotPINText(),
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
      child: Icon(Icons.lock,
          color: AppColors.backgroundGrey900, size: Dimens.iconSize_32),
    );
  }

  Widget buildPageLockedText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Text('enter_4_digit_pin'.tr,
          style: context.textTheme.headline7SemiBold),
    );
  }

  Widget buildPINTextField() {
    return StreamBuilder<String?>(
      stream: _pinVerifyBottomSheetCubit.pin,
      builder: (context, otp) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_64, Dimens.padding_24, Dimens.padding_64, 0),
          child: PinCodeTextField(
            appContext: context,
            length: 4,
            obscureText: true,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
                shape: PinCodeFieldShape.circle,
                borderWidth: Dimens.border_1,
                borderRadius: BorderRadius.circular(Dimens.radius_4),
                fieldHeight: Dimens.imageHeight_48,
                fieldWidth: Dimens.imageHeight_48,
                activeFillColor: AppColors.backgroundGrey400,
                activeColor: AppColors.backgroundGrey400,
                inactiveColor: AppColors.backgroundGrey400,
                inactiveFillColor: AppColors.backgroundGrey400,
                selectedColor: AppColors.primaryMain,
                selectedFillColor: AppColors.backgroundGrey400),
            keyboardType: TextInputType.number,
            animationDuration: const Duration(milliseconds: 300),
            // backgroundColor: Colors.blue.shade50,
            enableActiveFill: true,
            errorAnimationController: _errorController,
            controller: _pinController,
            onCompleted: (v) {},
            onChanged: _pinVerifyBottomSheetCubit.changePIN,
            beforeTextPaste: (text) {
              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
              //but you can show anything you want here, like your pop up saying wrong paste format or etc
              return true;
            },
          ),
        );
      },
    );
  }

  Widget buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
      child: RaisedRectButton(
        text: 'confirm'.tr,
        buttonStatus: _pinVerifyBottomSheetCubit.buttonStatus,
        onPressed: () {
          _pinVerifyBottomSheetCubit.verifyPIN(_currentUser?.id ?? -1);
        },
      ),
    );
  }

  Widget buildForgotPINText() {
    return Align(
      alignment: Alignment.centerRight,
      child: MyInkWell(
        onTap: () {
          _openForgotPINWidget();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_24, Dimens.padding_24, Dimens.padding_24, 0),
          child: Text(
            'forgot_pin_with_question_mark'.tr,
            style: Get.context?.textTheme.bodyText1SemiBold
                ?.copyWith(color: AppColors.secondary),
          ),
        ),
      ),
    );
  }

  _openForgotPINWidget() async {
    WidgetResult? widgetResult =
        await MRouter.pushNamed(MRouter.forgotPINWidget);
    if (widgetResult != null) {}
  }
}
