import 'package:awign/workforce/auth/feature/email_sign_in/cubit/email_sign_in_cubit.dart';
import 'package:awign/workforce/auth/helper/auth_helper.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:responsive_builder/responsive_builder.dart';

class EmailSignInWidget extends StatefulWidget {
  const EmailSignInWidget({Key? key}) : super(key: key);

  @override
  State<EmailSignInWidget> createState() => _EmailSignInWidgetState();
}

class _EmailSignInWidgetState extends State<EmailSignInWidget> {
  final _emailSignInCubit = sl<EmailSignInCubit>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final fnEmail = FocusNode();
  final fnPassword = FocusNode();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
  }

  void subscribeUIStatus() {
    _emailSignInCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
      },
    );
    _emailSignInCubit.validTokenWithProfile.listen((validTokenWithProfile) {
      AuthHelper.checkOnboardingStages(validTokenWithProfile.user!);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: 'login_using_email'.tr),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Dimens.padding_32,
                Dimens.padding_60, Dimens.padding_32, Dimens.padding_16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldLabel(label: 'email'.tr),
                const SizedBox(height: Dimens.margin_16),
                buildEmailTextField(),
                const SizedBox(height: Dimens.margin_24),
                TextFieldLabel(label: 'password'.tr),
                const SizedBox(height: Dimens.margin_16),
                buildPasswordTextField(),
                const SizedBox(height: Dimens.margin_24),
                buildSignInButton(),
                const SizedBox(height: Dimens.margin_24),
                buildForgotPasswordText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmailTextField() {
    return StreamBuilder<String?>(
      stream: _emailSignInCubit.email,
      builder: (context, snapshot) {
        return TextField(
          style: context.textTheme.bodyText1,
          onChanged: _emailSignInCubit.changeEmail,
          focusNode: fnEmail,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          maxLines: 1,
          textInputAction: TextInputAction.next,
          onSubmitted: (v) {
            FocusScope.of(context).requestFocus(fnPassword);
          },
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: 'enter_email'.tr,
            errorText: snapshot.error?.toString(),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: context.theme.textFieldBackgroundColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: context.theme.textFieldBackgroundColor),
            ),
          ),
        );
      },
    );
  }

  Widget buildPasswordTextField() {
    return StreamBuilder<String?>(
      stream: _emailSignInCubit.password,
      builder: (context, snapshot) {
        return TextField(
          style: context.textTheme.bodyText1,
          focusNode: fnPassword,
          controller: _passwordController,
          onChanged: _emailSignInCubit.changePassword,
          keyboardType: TextInputType.visiblePassword,
          maxLines: 1,
          textInputAction: TextInputAction.done,
          onSubmitted: (v) {},
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: 'password'.tr,
            errorText: snapshot.error?.toString(),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: context.theme.textFieldBackgroundColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: context.theme.textFieldBackgroundColor),
            ),
          ),
        );
      },
    );
  }

  Widget buildSignInButton() {
    return RaisedRectButton(
      text: 'sign_in'.tr,
      buttonStatus: _emailSignInCubit.buttonStatus,
      onPressed: () {
        Helper.hideKeyBoard(context);
        _emailSignInCubit.signInByEmail();
      },
    );
  }

  Widget buildForgotPasswordText() {
    return Align(
      alignment: Alignment.center,
      child: MyInkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_8),
          child: Text(
            'forgot_password'.tr,
            style: Get.context?.textTheme.bodyText1
                ?.copyWith(color: AppColors.secondary),
          ),
        ),
      ),
    );
  }
}
