import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/feature/lead_list/cubit/call_bridge_bottom_sheet_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../core/data/local/shared_preference_utils.dart';
import '../../../../../core/di/app_injection_container.dart';
import '../../../../../core/router/router.dart';

void showCallBridgeBottomSheet(
    BuildContext context, String uid, String leadId, String executionId) {
  showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return CallBridgeBottomSheet(
          uid: uid,
          leadId: leadId,
          executionId: executionId,
        );
      });
}

class CallBridgeBottomSheet extends StatefulWidget {
  final String uid;
  final String leadId;
  final String executionId;

  const CallBridgeBottomSheet(
      {Key? key,
      required this.uid,
      required this.leadId,
      required this.executionId})
      : super(key: key);

  @override
  State<CallBridgeBottomSheet> createState() => _CallBridgeBottomSheetState();
}

class _CallBridgeBottomSheetState extends State<CallBridgeBottomSheet> {
  final CallBridgeBottomSheetCubit _callBridgeBottomSheetCubit =
      sl<CallBridgeBottomSheetCubit>();
  TextEditingController textController = TextEditingController();
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    getUserData();
    subscribeUIStatus();
  }

  void subscribeUIStatus() {
    _callBridgeBottomSheetCubit.uiStatus.listen(
      (uiStatus) {
        switch (uiStatus.event) {
          case Event.success:
            MRouter.pop(null);
            break;
        }
      },
    );
  }

  void getUserData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    textController.text = _currentUser!.mobileNumber!;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Dimens.padding_32, horizontal: Dimens.padding_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHeadText(),
          const SizedBox(
            height: Dimens.margin_16,
          ),
          buildDescriptionText(),
          const SizedBox(
            height: Dimens.margin_32,
          ),
          buildPhoneNumberInputField(),
          const SizedBox(
            height: Dimens.margin_32,
          ),
          buildConnectCallButton(),
        ],
      ),
    );
  }

  Widget buildHeadText() {
    return Text('verify_phone_number'.tr,
        style: Get.context?.textTheme.bodyText1Bold
            ?.copyWith(color: AppColors.black, fontWeight: FontWeight.w600));
  }

  Widget buildDescriptionText() {
    return Text(
        'please_make_sure_the_number_you_have_entered_is_correct_you_will_get_a_call_on_the_entered_number'
            .tr,
        style: Get.context?.textTheme.bodyMedium?.copyWith(
            color: AppColors.backgroundGrey700, fontWeight: FontWeight.w600));
  }

  Widget buildPhoneNumberInputField() {
    return TextFormField(
      controller: textController,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.backgroundGrey300,
        hintText: 'enter_mobile_number'.tr,
        hintStyle: Get.textTheme.bodyText1?.copyWith(
            color: AppColors.backgroundGrey700,
            fontSize: Dimens.font_16,
            fontWeight: FontWeight.w400),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_16)),
        ),
        focusColor: AppColors.primaryMain,
      ),
    );
  }

  Widget buildConnectCallButton() {
    return RaisedRectButton(
      text: 'connect_call'.tr,
      backgroundColor: AppColors.primaryMain,
      elevation: 0,
      onPressed: () {
        if (textController.text.isNotEmpty &&
            textController.text.length == 10) {
          _callBridgeBottomSheetCubit.callBridge(widget.uid,
              textController.text, widget.leadId, widget.executionId);
        }
      },
    );
  }
}
