import 'package:awign/workforce/auth/feature/enter_email_manually/cubit/enter_email_manually_cubit.dart';
import 'package:awign/workforce/auth/feature/enter_email_manually/widget/bottom_sheet/account_already_exists_bottom_sheet.dart';
import 'package:awign/workforce/auth/helper/auth_helper.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class EnterEmailManuallyWidget extends StatefulWidget {
  const EnterEmailManuallyWidget({Key? key}) : super(key: key);

  @override
  _EnterEmailManuallyWidgetState createState() =>
      _EnterEmailManuallyWidgetState();
}

class _EnterEmailManuallyWidgetState extends State<EnterEmailManuallyWidget> {
  final _enterEmailManuallyCubit = sl<EnterEmailManuallyCubit>();
  final TextEditingController _emailController = TextEditingController();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void subscribeUIStatus() {
    _enterEmailManuallyCubit.uiStatus.listen(
      (uiStatus) async {
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.updated:
            SPUtil? spUtil = await SPUtil.getInstance();
            _currentUser = spUtil?.getUserData();
            AuthHelper.checkOnboardingStages(_currentUser!);
            break;
          case Event.failed:
            if (uiStatus.data != null) {
              showAccountAlreadyExistsBottomSheet(context, _currentUser!,
                  _onLoginAgainTapped, _onUseDifferentEmailTapped);
            } else {}
            break;
        }
      },
    );
  }

  _onLoginAgainTapped() {
    MRouter.pushNamedAndRemoveUntil(MRouter.phoneVerificationWidget);
  }

  _onUseDifferentEmailTapped() {
    _emailController.text = '';
    _enterEmailManuallyCubit.changeEmail('');
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    setState(() {});
    _emailController.text = _currentUser?.email ?? '';
    if ((_currentUser?.email ?? '').isNotEmpty) {
      _enterEmailManuallyCubit.changeEmail(_currentUser?.email);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
      topPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
              isCollapsable: true,
              title: 'create_account'.tr,
              isPopUpMenuVisible: true,
            ),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                      Dimens.padding_32, Dimens.padding_16, Dimens.padding_16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildPhoneNumberLabelWidget(),
                      const SizedBox(height: Dimens.padding_4),
                      buildPhoneNumberWidget(),
                      const SizedBox(height: Dimens.padding_40),
                      TextFieldLabel(label: 'email_address'.tr),
                      const SizedBox(height: Dimens.padding_12),
                      buildEmailTextField(),
                    ],
                  ),
                ),
              ),
            ),
            buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget buildPhoneNumberLabelWidget() {
    return Text(
      'create_account_with_the_phone_number'.tr,
      style:
          Get.textTheme.bodyText2?.copyWith(color: AppColors.backgroundGrey900),
    );
  }

  Widget buildPhoneNumberWidget() {
    return Text(
      _currentUser?.mobileNumber ?? '',
      style: Get.textTheme.bodyText2Medium
          ?.copyWith(color: AppColors.backgroundBlack),
    );
  }

  Widget buildEmailTextField() {
    return StreamBuilder<String?>(
      stream: _enterEmailManuallyCubit.email,
      builder: (context, snapshot) {
        return TextField(
          style: context.textTheme.bodyText1,
          onChanged: _enterEmailManuallyCubit.changeEmail,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          maxLines: 1,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_12,
                Dimens.padding_12, Dimens.padding_12, Dimens.padding_12),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: 'enter_email_address'.tr,
            errorText: snapshot.error?.toString(),
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_8)),
              borderSide: BorderSide(color: AppColors.backgroundGrey400),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_8)),
              borderSide: BorderSide(color: AppColors.primaryMain),
            ),
          ),
        );
      },
    );
  }

  Widget buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_40,
          Dimens.margin_16, Dimens.padding_32),
      child: RaisedRectButton(
        text: 'continue'.tr,
        buttonStatus: _enterEmailManuallyCubit.buttonStatus,
        onPressed: () {
          _enterEmailManuallyCubit.emailUpdate(_currentUser!);
        },
      ),
    );
  }
}
