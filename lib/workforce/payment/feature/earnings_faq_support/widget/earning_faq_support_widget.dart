import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/app_config_response.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/zoho/zoho_helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class EarningFaqSupportWidget extends StatefulWidget {
  const EarningFaqSupportWidget({Key? key}) : super(key: key);

  @override
  State<EarningFaqSupportWidget> createState() =>
      _EarningFaqSupportWidgetState();
}

class _EarningFaqSupportWidgetState extends State<EarningFaqSupportWidget> {
  UserData? _currentUser;
  AppConfigResponse? _appConfigResponse;

  void getCurrentUserAndConfiguration() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    _appConfigResponse = spUtil?.getLaunchConfigData();
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserAndConfiguration();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody() {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimens.padding_24),
      child: Column(
        children: [
          MyInkWell(
            onTap: () {
              ZohoHelper.setupAndOpenZohoFaq(_currentUser);
            },
            child: buildFaQAndChat(
                'frequently_asked_questions'.tr, 'assets/images/document.svg'),
          ),
          HDivider(),
          MyInkWell(
              onTap: () {
                ZohoHelper.setupAndOpenZohoChat(_currentUser);
              },
              child: buildFaQAndChat(
                  'chat_with_us'.tr, 'assets/images/messages.svg')),
          HDivider(),
          const Spacer(),
          buildContactSupport(context),
        ],
      ),
    );
  }

  Widget buildFaQAndChat(String name, String url) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 0),
      visualDensity: const VisualDensity(
        horizontal: -4,
      ),
      leading: SvgPicture.asset(
        url,
        color: AppColors.backgroundGrey900,
      ),
      title: Text(
        name,
        style: Get.context?.textTheme.bodyText1Medium
            ?.copyWith(color: AppColors.black),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.backgroundGrey700,
        size: Dimens.font_20,
      ),
    );
  }

  Widget buildContactSupport(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: Dimens.padding_8,
      ),
      child: Column(
        children: [
          Text(
            'need_more_help'.tr,
            style: Get.context?.textTheme.titleMedium
                ?.copyWith(color: AppColors.backgroundGrey900),
          ),
          const SizedBox(height: Dimens.margin_12),
          MyInkWell(
            onTap: () {
              showContactSupportBottomSheet(context);
            },
            child: Text(
              'contact_support'.tr,
              style: Get.context?.textTheme.bodyText1Bold
                  ?.copyWith(color: AppColors.primaryMain),
            ),
          ),
        ],
      ),
    );
  }

  void showContactSupportBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimens.radius_16),
            topRight: Radius.circular(Dimens.radius_16),
          ),
        ),
        builder: (_) {
          return buildContactDetailsDetails();
        });
  }

  Widget buildContactDetailsDetails() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_32,
        Dimens.padding_16,
        Dimens.padding_16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'contact_support'.tr,
                style: Get.context?.textTheme.titleLarge
                    ?.copyWith(color: AppColors.black),
              ),
              MyInkWell(
                onTap: () {
                  MRouter.pop(null);
                },
                child: const CircleAvatar(
                  backgroundColor: AppColors.backgroundGrey700,
                  radius: 12,
                  child: Icon(
                    Icons.close,
                    color: AppColors.backgroundWhite,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimens.margin_12),
          MyInkWell(
              onTap: () {
                _onEmailShareTap();
              },
              child: buildFaQAndChat(
                  'email_us'.tr, 'assets/images/sms_tracking.svg')),
          HDivider(),
          MyInkWell(
              onTap: () {
                _onCallUsTap();
              },
              child: buildFaQAndChat(
                  'call_us'.tr, 'assets/images/call_calling.svg')),
        ],
      ),
    );
  }

  _onEmailShareTap() async {
    try {
      await Share.share(" ");
    } catch (e, st) {
      AppLog.e(
          'FaqAndSupportWidget  _onEmailShareTap: ${e.toString()} \n${st.toString()}');
    }
  }

  _onCallUsTap() async {
    await FlutterPhoneDirectCaller.callNumber(
        _appConfigResponse!.data!.primaryContact!.phone ?? '');
  }
}
