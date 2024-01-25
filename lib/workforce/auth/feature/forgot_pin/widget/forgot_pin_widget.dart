import 'package:awign/workforce/auth/feature/forgot_pin/cubit/forgot_pin_cubit.dart';
import 'package:awign/workforce/auth/feature/otp_verification/widget/otp_verification_widget.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/model/widget_result.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ForgotPINWidget extends StatefulWidget {
  const ForgotPINWidget({Key? key}) : super(key: key);

  @override
  _ForgotPINWidgetState createState() => _ForgotPINWidgetState();
}

class _ForgotPINWidgetState extends State<ForgotPINWidget> {
  final _forgotPINCubit = sl<ForgotPINCubit>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getUserData();
  }

  void subscribeUIStatus() {
    _forgotPINCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.otpSent:
            _openOTPVerificationWidget();
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  _openOTPVerificationWidget() async {
    WidgetResult? widgetResult =
        await MRouter.pushNamed(MRouter.oTPVerificationWidget, arguments: {
      'mobile_number': _currentUser?.mobileNumber ?? '',
      'from_route': MRouter.earningsWidget,
      'page_type': PageType.forgotPIN,
    });
    if (widgetResult != null && widgetResult.event == Event.verified) {
      _forgotPINCubit.changeButtonStatus(ButtonStatus(isEnable: true));
      WidgetResult? widgetResult =
          await MRouter.pushNamed(MRouter.confirmPINWidget);
      if (widgetResult != null) {
        MRouter.pop(WidgetResult(event: Event.updated));
      }
    }
  }

  void getUserData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    if (_currentUser != null) {
      _forgotPINCubit.changeCurrentUser(_currentUser!);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mobileNumberController.dispose();
    _dateOfBirthController.dispose();
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
                title: 'forgot_pin'.tr),
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
        child: StreamBuilder<UIStatus>(
            stream: _forgotPINCubit.uiStatus,
            builder: (context, uiStatus) {
              if (uiStatus.hasData && uiStatus.data!.isOnScreenLoading) {
                return AppCircularProgressIndicator();
              } else {
                return SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                              Dimens.padding_24, Dimens.padding_16, 0),
                          child: TextFieldLabel(
                              label: 'registered_email_address'.tr),
                        ),
                        buildEmailTextField(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                              Dimens.padding_24, Dimens.padding_16, 0),
                          child: TextFieldLabel(
                              label: 'registered_mobile_number'.tr),
                        ),
                        buildMobileNumberTextField(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                              Dimens.margin_24, Dimens.padding_16, 0),
                          child: TextFieldLabel(label: 'date_of_birth'.tr),
                        ),
                        buildDateOfBirthContainer(),
                        buildSaveChangesButton(),
                      ],
                    ),
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget buildEmailTextField() {
    return StreamBuilder<String?>(
      stream: _forgotPINCubit.email,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            onChanged: _forgotPINCubit.changeEmail,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: context.theme.textFieldBackgroundColor,
              hintText: 'enter_email_address'.tr,
              errorText: snapshot.error?.toString(),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.backgroundGrey400),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.primaryMain),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildMobileNumberTextField() {
    return StreamBuilder<String?>(
      stream: _forgotPINCubit.mobileNumber,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            controller: _mobileNumberController,
            keyboardType: TextInputType.number,
            maxLines: 1,
            maxLength: 10,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            textInputAction: TextInputAction.done,
            onChanged: _forgotPINCubit.changeMobileNumber,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: context.theme.textFieldBackgroundColor,
              hintText: 'enter_mobile_number'.tr,
              counterText: "",
              hintStyle: const TextStyle(color: AppColors.backgroundGrey600),
              errorText: snapshot.error?.toString(),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    const BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide:
                    BorderSide(color: context.theme.textFieldBackgroundColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.primaryMain),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildDateOfBirthContainer() {
    return StreamBuilder<String?>(
      stream: _forgotPINCubit.dateOfBirth,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _dateOfBirthController.text = DateFormat('MMMM dd, yyyy')
              .format(DateTime.parse(snapshot.data!));
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_12, Dimens.padding_16, 0),
          child: TextField(
            style: context.textTheme.bodyText1,
            maxLines: 1,
            controller: _dateOfBirthController,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: AppColors.backgroundGrey300,
              hintText: 'enter_date_of_birth'.tr,
              counterText: "",
              hintStyle: const TextStyle(color: AppColors.backgroundGrey600),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.backgroundGrey400),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_8)),
                borderSide: BorderSide(color: AppColors.backgroundGrey400),
              ),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  context: context,
                  initialDate:
                      DateTime.now().subtract(const Duration(days: 6570)),
                  firstDate: DateTime(1920),
                  //DateTime.now() - not to allow to choose before today.
                  lastDate:
                      DateTime.now().subtract(const Duration(days: 6570)));
              if (pickedDate != null) {
                String formattedDate =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
                _forgotPINCubit.changeDateOfBirth(formattedDate);
              }
            },
            readOnly: true,
          ),
        );
      },
    );
  }

  Widget buildSaveChangesButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.padding_16, Dimens.padding_48, Dimens.padding_16, 0),
      child: RaisedRectButton(
        text: 'get_otp'.tr,
        buttonStatus: _forgotPINCubit.buttonStatus,
        onPressed: () {
          Helper.hideKeyBoard(context);
          _forgotPINCubit.generatePINOTP(_currentUser?.id ?? -1);
        },
      ),
    );
  }
}
