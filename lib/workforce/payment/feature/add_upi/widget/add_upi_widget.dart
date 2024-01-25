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
import 'package:awign/workforce/payment/feature/add_upi/cubit/add_upi_cubit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddUPIWidget extends StatefulWidget {
  const AddUPIWidget({Key? key}) : super(key: key);

  @override
  _AddUPIWidgetState createState() => _AddUPIWidgetState();
}

class _AddUPIWidgetState extends State<AddUPIWidget> {
  final AddUpiCubit _addUPICubit = sl<AddUpiCubit>();
  UserData? _currentUser;
  SPUtil? spUtil;
  final TextEditingController _upiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  void subscribeUIStatus() {
    _addUPICubit.uiStatus.listen(
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
            DefaultAppBar(isCollapsable: true, title: 'upi_id'.tr),
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
                      buildUPIIDLabel(),
                      buildUPIIDTextField(),
                    ],
                  ),
                ),
              ),
            ),
            buildVerifyNowButton(),
          ],
        ),
      ),
    );
  }

  Widget buildUPIIDLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, Dimens.padding_12),
      child: Text(
        'upi_id'.tr,
        style: Get.textTheme.bodyText2Medium
            ?.copyWith(color: AppColors.backgroundBlack),
      ),
    );
  }

  Widget buildUPIIDTextField() {
    return StreamBuilder<String?>(
      stream: _addUPICubit.upi,
      builder: (context, snapshot) {
        return TextField(
          style: context.textTheme.bodyText1,
          onChanged: _addUPICubit.changeUPI,
          controller: _upiController,
          keyboardType: TextInputType.text,
          maxLines: 1,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            hintText: 'enter_upi_id'.tr,
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

  Widget buildVerifyNowButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_24, Dimens.padding_16,
          Dimens.padding_24, Dimens.padding_32),
      child: RaisedRectButton(
        text: 'add_account'.tr,
        buttonStatus: _addUPICubit.buttonStatus,
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
          _addUPICubit.addUPI(_currentUser!);
        }
      }
    });
  }
}
