import 'dart:io';

import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/app_config_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../../auth/data/model/device_info.dart';
import '../router/router.dart';
import '../widget/buttons/custom_text_button.dart';
import '../widget/theme/theme_manager.dart';
import 'app_log.dart';
import 'constants.dart';
import 'device_info_utils.dart';

class AppUpgradeDialogHelper {
  static bool showAppUpgradeDialog = true;
  late bool isForceUpdateCheck = false;

  Future<bool> checkVersionAndShowAppUpgradeDialog(
      BuildContext context, bool isForceUpdateCheck) async {
    try {
      this.isForceUpdateCheck = isForceUpdateCheck;
      if (!showAppUpgradeDialog) {
        return false;
      }

      /// Get Current installed version of app
      final DeviceInfo? deviceInfo = await DeviceInfoUtils.getDeviceInfoData();
      if (deviceInfo?.primaryAppVersion == null) {
        return false;
      }
      SPUtil? spUtil = await SPUtil.getInstance();
      NewVersionInfo? newVersionInfo =
          spUtil?.getLaunchConfigData()?.data?.newVersionInfo;
      int installedAppVersion =
          int.parse(deviceInfo?.primaryAppVersion?.split(".").last ?? "0");
      if (isForceUpdateCheck) {
        if (kIsWeb) {
          return false;
        } else if (newVersionInfo
                    ?.androidVersionInfo?.forcedRelease?.versionName !=
                null &&
            Platform.isAndroid) {
          int forcedAppVersion = int.parse(newVersionInfo
                  ?.androidVersionInfo?.forcedRelease?.versionName
                  ?.split(".")
                  .last ??
              "0");
          if (forcedAppVersion > installedAppVersion) {
            _showUpdateDialog(context);
            return true;
          }
          return false;
        } else if (newVersionInfo?.iosVersionInfo?.forcedRelease?.versionName !=
                null &&
            Platform.isIOS) {
          int forcedAppVersion = int.parse(newVersionInfo
                  ?.iosVersionInfo?.forcedRelease?.versionName
                  ?.split(".")
                  .last ??
              "0");
          if (forcedAppVersion > installedAppVersion) {
            //show dialog
            _showUpdateDialog(context);
            return true;
          }
          return false;
        }
        return false;
      } else {
        if (kIsWeb) {
          return false;
        } else if (newVersionInfo
                    ?.androidVersionInfo?.recommendedRelease?.versionName !=
                null &&
            Platform.isAndroid) {
          int recommendedAppVersion = int.parse(newVersionInfo
                  ?.androidVersionInfo?.recommendedRelease?.versionName
                  ?.split(".")
                  .last ??
              "0");
          if (recommendedAppVersion > installedAppVersion) {
            //show dialog
            _showUpdateDialog(context);
            return true;
          }
          return false;
        } else if (newVersionInfo
                    ?.iosVersionInfo?.recommendedRelease?.versionName !=
                null &&
            Platform.isIOS) {
          int recommendedAppVersion = int.parse(newVersionInfo
                  ?.iosVersionInfo?.recommendedRelease?.versionName
                  ?.split(".")
                  .last ??
              "0");
          if (recommendedAppVersion > installedAppVersion) {
            //show dialog
            _showUpdateDialog(context);
            return true;
          }
          return false;
        }
        return false;
      }
    } catch (e, st) {
      AppLog.e(
          'checkVersionAndShowAppUpgradeDialog : ${e.toString()} \n${st.toString()}');
      return false;
    }
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AppUpgradeDialog(
          isForceUpdate: isForceUpdateCheck),
    );
  }
}

class AppUpgradeDialog extends StatelessWidget {
  final bool isForceUpdate;

  const AppUpgradeDialog({required this.isForceUpdate, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: Dimens.elevation_8,
      insetAnimationCurve: Curves.easeInOut,
      backgroundColor: AppColors.backgroundWhite,
      insetPadding: const EdgeInsets.all(Dimens.padding_20),
      child: buildDialogContent(context),
    );
  }

  Widget buildDialogContent(BuildContext context) {
    String title = 'app_update'.tr;
    String subTitle = 'please_update_to_continue_using_the_app'.tr;
    String? releaseInfo;

    return Container(
      padding: const EdgeInsets.all(Dimens.padding_16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          const SizedBox(height: Dimens.margin_16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyLarge?.copyWith(
                fontSize: Dimens.font_20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Dimens.margin_16),
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: Get.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w400),
          ),
          buildReleaseInfo(releaseInfo),
          const SizedBox(height: Dimens.margin_16),
          Row(
            children: [
              buildLaterButton(context),
              const SizedBox(width: Dimens.margin_16),
              buildUpdateButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildReleaseInfo(String? releaseInfo) {
    if (releaseInfo != null) {
      return Column(
        children: [
          const SizedBox(height: Dimens.padding_16),
          Text(
            releaseInfo,
            textAlign: TextAlign.center,
            style: Get.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w400),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildUpdateButton(BuildContext context) {
    return Expanded(
      child: CustomTextButton(
        text: 'update'.tr,
        backgroundColor: AppColors.primaryMain,
        borderColor: AppColors.primaryMain,
        onPressed: () {
          _launchPlayStoreOrAppStore();
        },
      ),
    );
  }

  Widget buildLaterButton(BuildContext context) {
    if (!isForceUpdate) {
      AppUpgradeDialogHelper.showAppUpgradeDialog = false;
      return Expanded(
        child: CustomTextButton(
          text: 'later'.tr,
          backgroundColor: AppColors.transparent,
          borderColor: AppColors.primaryMain,
          textColor: AppColors.primaryMain,
          onPressed: () {
            MRouter.pop(null);
          },
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  _launchPlayStoreOrAppStore() {
    if (kIsWeb) {
    } else if (Platform.isAndroid) {
      launchUrl(
          Uri.parse(
              "https://play.google.com/store/apps/details?id=com.awign.intern"),
          mode: LaunchMode.externalApplication);
    } else if (Platform.isIOS) {
      launchUrl(Uri.parse("https://apps.apple.com/in/app/awign/id1629391041"),
          mode: LaunchMode.externalApplication);
    }
  }
}
