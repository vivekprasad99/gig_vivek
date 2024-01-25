import 'dart:async';

import 'package:awign/workforce/auth/feature/confirm_pin/cubit/confirm_pin_cubit.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ConfirmPINWidget extends StatefulWidget {
  const ConfirmPINWidget({Key? key}) : super(key: key);

  @override
  _ConfirmPINWidgetState createState() => _ConfirmPINWidgetState();
}

class _ConfirmPINWidgetState extends State<ConfirmPINWidget> {
  final _confirmPinCubit = sl<ConfirmPinCubit>();
  final StreamController<ErrorAnimationType> _pinErrorController =
      StreamController<ErrorAnimationType>();
  final StreamController<ErrorAnimationType> _confirmPINErrorController =
      StreamController<ErrorAnimationType>();
  final fnPIN = FocusNode();
  final fnConfirmPIN = FocusNode();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getUserData();
  }

  void subscribeUIStatus() {
    _confirmPinCubit.uiStatus.listen(
      (uiStatus) {
        switch (uiStatus.event) {
          case Event.updated:
            MRouter.pop(WidgetResult(event: Event.updated));
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
  void dispose() {
    _pinErrorController.close();
    _confirmPINErrorController.close();
    super.dispose();
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
                title: 'confirm_pin'.tr),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      padding: EdgeInsets.only(
          bottom: defaultTargetPlatform == TargetPlatform.iOS
              ? Dimens.padding_32
              : 0),
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                      Dimens.padding_24, Dimens.padding_16, 0),
                  child: TextFieldLabel(label: 'enter_pin'.tr),
                ),
                buildPINTextField(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                      Dimens.padding_24, Dimens.padding_16, 0),
                  child: TextFieldLabel(label: 'confirm_pin'.tr),
                ),
                buildConfirmPINTextField(),
                buildSetPINButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPINTextField() {
    return StreamBuilder<String?>(
      stream: _confirmPinCubit.pin,
      builder: (context, otp) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_80, 0),
          child: PinCodeTextField(
            appContext: context,
            length: 4,
            obscureText: true,
            animationType: AnimationType.fade,
            focusNode: fnPIN,
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
            errorAnimationController: _pinErrorController,
            controller: TextEditingController(),
            onCompleted: (v) {
              FocusScope.of(context).requestFocus(fnConfirmPIN);
            },
            onChanged: _confirmPinCubit.changePIN,
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

  Widget buildConfirmPINTextField() {
    return StreamBuilder<String?>(
      stream: _confirmPinCubit.confirmPIN,
      builder: (context, otp) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_80, 0),
          child: PinCodeTextField(
            appContext: context,
            length: 4,
            obscureText: true,
            animationType: AnimationType.fade,
            focusNode: fnConfirmPIN,
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
            errorAnimationController: _confirmPINErrorController,
            controller: TextEditingController(),
            onCompleted: (v) {},
            onChanged: _confirmPinCubit.changeConfirmPIN,
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

  Widget buildSetPINButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_48, Dimens.padding_16, 0),
      child: RaisedRectButton(
        text: 'set_pin'.tr,
        buttonStatus: _confirmPinCubit.buttonStatus,
        onPressed: () {
          Helper.hideKeyBoard(context);
          _confirmPinCubit.updatePIN(_currentUser?.id ?? -1);
        },
      ),
    );
  }
}
