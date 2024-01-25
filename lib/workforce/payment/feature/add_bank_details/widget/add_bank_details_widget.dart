import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/payment/data/model/ifsc_response.dart';
import 'package:awign/workforce/payment/feature/add_bank_details/cubit/add_bank_account_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AddBankDetailsWidget extends StatefulWidget {
  const AddBankDetailsWidget({Key? key}) : super(key: key);

  @override
  _AddBankDetailsWidgetState createState() => _AddBankDetailsWidgetState();
}

class _AddBankDetailsWidgetState extends State<AddBankDetailsWidget> {
  final AddBankAccountCubit _addBankAccountCubit = sl<AddBankAccountCubit>();
  UserData? _currentUser;
  SPUtil? spUtil;
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _reEnterAccountNumberController =
      TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final _accountNumberFN = FocusNode();
  final _reEnterAccountNumberFN = FocusNode();
  final _ifscFN = FocusNode();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _reEnterAccountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void subscribeUIStatus() {
    _addBankAccountCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.created:
            MRouter.pop(true);
            break;
        }
      },
    );
  }

  void getCurrentUser() async {
    spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(isCollapsable: true, title: 'bank_account'.tr),
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
                      buildAccountNumberLabel(),
                      buildAccountNumber(),
                      buildReEnterAccountNumberLabel(),
                      buildReEnterAccountNumber(),
                      buildIFSCLabel(),
                      buildIFSCTextField(),
                      buildBranchNameText(),
                    ],
                  ),
                ),
              ),
            ),
            buildBottomWidgets(),
          ],
        ),
      ),
    );
  }

  Widget buildAccountNumberLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_12),
      child: Text(
        'account_number'.tr,
        style: Get.textTheme.bodyText2Medium
            ?.copyWith(color: AppColors.backgroundBlack),
      ),
    );
  }

  Widget buildAccountNumber() {
    return StreamBuilder<String?>(
      stream: _addBankAccountCubit.accountNumber,
      builder: (context, snapshot) {
        return TextField(
          style: context.textTheme.bodyText1,
          onChanged: _addBankAccountCubit.changeAccountNumber,
          focusNode: _accountNumberFN,
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLines: 1,
          textInputAction: TextInputAction.next,
          onSubmitted: (v) {
            FocusScope.of(context).requestFocus(_reEnterAccountNumberFN);
          },
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: 'enter_account_number'.tr,
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

  Widget buildReEnterAccountNumberLabel() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, Dimens.padding_12),
      child: Text(
        're_enter_account_number'.tr,
        style: Get.textTheme.bodyText2Medium
            ?.copyWith(color: AppColors.backgroundBlack),
      ),
    );
  }

  Widget buildReEnterAccountNumber() {
    return StreamBuilder<String?>(
      stream: _addBankAccountCubit.reEnterAccountNumber,
      builder: (context, snapshot) {
        return StreamBuilder<bool>(
            stream: _addBankAccountCubit.isValidAccountNumber,
            builder: (context, isValidAccountNumber) {
              return TextField(
                style: context.textTheme.bodyText1,
                onChanged: _addBankAccountCubit.changeReEnterAccountNumber,
                focusNode: _reEnterAccountNumberFN,
                controller: _reEnterAccountNumberController,
                keyboardType: TextInputType.number,
                maxLines: 1,
                textInputAction: TextInputAction.next,
                onSubmitted: (v) {
                  FocusScope.of(context).requestFocus(_ifscFN);
                },
                decoration: InputDecoration(
                  filled: true,
                  contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                      Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
                  fillColor: context.theme.textFieldBackgroundColor,
                  hintText: 're_enter_account_number'.tr,
                  errorText: snapshot.error?.toString(),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: context.theme.textFieldBackgroundColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: context.theme.textFieldBackgroundColor),
                  ),
                  suffixIcon: (isValidAccountNumber.data ?? false)
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(
                              Dimens.margin_16,
                              Dimens.margin_8,
                              Dimens.margin_12,
                              Dimens.margin_8),
                          child: SvgPicture.asset(
                              'assets/images/ic_valid_account_number.svg'),
                        )
                      : const SizedBox(),
                ),
              );
            });
      },
    );
  }

  Widget buildIFSCLabel() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, Dimens.padding_12),
      child: Text(
        'ifsc_code'.tr,
        style: Get.textTheme.bodyText2Medium
            ?.copyWith(color: AppColors.backgroundBlack),
      ),
    );
  }

  Widget buildIFSCTextField() {
    return StreamBuilder<String?>(
      stream: _addBankAccountCubit.ifscCode,
      builder: (context, snapshot) {
        return TextField(
          style: context.textTheme.bodyText1,
          onChanged: _addBankAccountCubit.changeIfscCode,
          focusNode: _ifscFN,
          controller: _ifscController,
          keyboardType: TextInputType.text,
          maxLines: 1,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: 'enter_ifsc_code'.tr,
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

  Widget buildBranchNameText() {
    return StreamBuilder<BankData>(
      stream: _addBankAccountCubit.bankData,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, Dimens.padding_12, 0, 0),
            child: Text(
              '${snapshot.data!.bank}, ${snapshot.data!.branch}',
              style:
                  Get.textTheme.bodyText2?.copyWith(color: AppColors.link400),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget buildBottomWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
          Dimens.padding_16, Dimens.padding_32),
      child: Column(
        children: [
          buildNoteWidget(),
          buildVerifyNowButton(),
        ],
      ),
    );
  }

  Widget buildNoteWidget() {
    return Container(
      padding: const EdgeInsets.all(Dimens.padding_12),
      decoration: BoxDecoration(
        color: AppColors.warning100,
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.radius_16)),
        border: Border.all(
          color: AppColors.warning200,
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: context.textTheme.bodyText1
              ?.copyWith(color: AppColors.backgroundGrey700),
          children: <TextSpan>[
            TextSpan(
              text: 'note'.tr,
              style: Get.textTheme.bodyText2SemiBold,
            ),
            TextSpan(
              text: 'make_sure_your_back_account_has_the'.tr,
              style: Get.textTheme.bodyText2,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVerifyNowButton() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, Dimens.padding_32),
      child: RaisedRectButton(
        text: 'add_account'.tr,
        buttonStatus: _addBankAccountCubit.buttonStatus,
        onPressed: () {
          _showConfirmDialogForAddAccount();
        },
      ),
    );
  }

  _showConfirmDialogForAddAccount() {
    Future<ConfirmAction?> deleteTap = Helper.asyncConfirmDialog(
        context, 'are_you_sure_want_to_submit'.tr,
        textOKBtn: 'yes'.tr, textCancelBtn: 'no'.tr);
    deleteTap.then((value) {
      if (value == ConfirmAction.OK) {
        if (_currentUser != null) {
          _addBankAccountCubit.addBeneficiary(_currentUser!);
        }
      }
    });
  }
}
