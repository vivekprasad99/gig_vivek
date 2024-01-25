import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/data/remote/facebook/facebook_constant.dart';
import 'package:awign/workforce/core/data/remote/facebook/facebook_helper.dart';
import 'package:awign/workforce/core/data/remote/moengage/moengage_helper.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/widget/dialog/alert_dialog/app_alert_dialog.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_progress_dialog.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:share_plus/share_plus.dart';

enum ConfirmAction { CANCEL, OK }

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

class Helper {
  static AppProgressDialog? pr;

  static double getToolbarStatusBarHeightWithMarginTop(BuildContext context) {
    return Dimens.toolbarHeight;
  }

  static double getToolbarStatusBarHeight(BuildContext context) {
    return Dimens.toolbarHeight + 1;
  }

  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static showLoadingDialog(BuildContext context, String message) {
    /*if (pr != null && pr.isShowing()) {
      pr.update(message: message);
    } else {
      pr = AppProgressDialog(context, ProgressDialogType.Normal);
      pr.setMessage(message);
      pr.show();
    }*/
    if (pr != null && pr!.isShowing()) {
    } else {
      pr = AppProgressDialog(context, ProgressDialogType.Normal);
      pr!.showLoadingDialog(message);
    }
  }

  static hideLoadingDialog() {
    if (pr != null && pr!.isShowing()) {
      pr!.hide();
    }
  }

  static void showAlertDialog(BuildContext c, String heading,
      {String? body, String textOKBtn = 'OK'}) {
    if (body == null) {
      showDialog(
        context: c,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              heading,
              style: c.textTheme.bodyText1,
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text(textOKBtn),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: c,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(heading, style: c.textTheme.bodyText1),
            content: Text(body, style: c.textTheme.bodyText1),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.transparent,
                ),
                onPressed: () => {
                  Navigator.of(context).pop(),
                },
                child: Text(
                  textOKBtn,
                  style: context.textTheme.bodyText1?.copyWith(
                      color: context.theme.iconColorHighlighted,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  static void showAlertDialogWithOnTap(
      BuildContext context, String heading, VoidCallback onTap,
      {String textOKBtn = 'OK'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AppAlertDialog(heading, onTap),
    );
  }

  static Future<ConfirmAction?> asyncConfirmDialog(
      BuildContext context, String body,
      {String heading = 'Alert',
      String textOKBtn = 'Ok',
      String textCancelBtn = 'CANCEL'}) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(heading, style: context.textTheme.bodyText1),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.transparent,
              ),
              onPressed: () => {
                Navigator.of(context).pop(ConfirmAction.CANCEL),
              },
              child: Text(
                textCancelBtn,
                style: context.textTheme.bodyText1?.copyWith(
                    color: context.theme.iconColorHighlighted,
                    fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.transparent,
              ),
              onPressed: () => {
                Navigator.of(context).pop(ConfirmAction.OK),
              },
              child: Text(
                textOKBtn,
                style: context.textTheme.bodyText1?.copyWith(
                    color: context.theme.iconColorHighlighted,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showSnackBar(String message) {
    /*_scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: duration),
    ));*/
    Get.snackbar('', message);
  }

  static void showSnackBarWithAction(
    String message,
    String actionLabel,
    VoidCallback onTap, {
    int duration = 3,
  }) {
    Get.showSnackbar(GetSnackBar(
      messageText: Text(message),
      duration: Duration(seconds: duration),
      // action: SnackBarAction(label: actionLabel, onPressed: onTap),
    ));
  }

  static void showInfoToast(String message, {Color? color}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor:
            color.isBlank! ? Get.theme.toastBackgroundColor : color,
        textColor: Get.theme.toastTextColor,
        fontSize: Dimens.font_16);
  }

  static void showErrorToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.error400,
        textColor: AppColors.backgroundWhite,
        fontSize: Dimens.font_16);
  }

  static hideKeyBoard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static String timeAgoSinceDate(String dateString,
      {bool numericDates = true}) {
    DateTime date = DateTime.parse(dateString);
    final date2 = DateTime.now().toLocal();
    final difference = date2.difference(date);

    if (difference.inSeconds < 5) {
      return 'Just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes <= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours <= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inHours < 60) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays <= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inDays < 6) {
      return '${difference.inDays} days ago';
    } else if ((difference.inDays / 7).ceil() <= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if ((difference.inDays / 7).ceil() < 4) {
      return '${(difference.inDays / 7).ceil()} weeks ago';
    } else if ((difference.inDays / 30).ceil() <= 1) {
      return (numericDates) ? '1 month ago' : 'Last month';
    } else if ((difference.inDays / 30).ceil() < 30) {
      return '${(difference.inDays / 30).ceil()} months ago';
    } else if ((difference.inDays / 365).ceil() <= 1) {
      return (numericDates) ? '1 year ago' : 'Last year';
    }
    return '${(difference.inDays / 365).floor()} years ago';
  }

  static String addCountryCodeInContactNumber(String number) {
    if (number != null && number.startsWith('+44')) {
      return number;
    } else if (number != null && number.startsWith('0')) {
      var result = number.replaceFirst('0', '+44');
      return result;
    } else if (number != null) {
      return '+44$number';
    } else {
      return '';
    }
  }

  static shareAwignAppLink(UserData? currentUser) async {
    try {
      String text =
          'Part-time internships all across India. Work few hours a day and earn handsome stipend. \nDownload Awign App Now!\n \n\nhttps://play.google.com/store/apps/details?id=com.awign.intern';
      await Share.share(text, subject: 'Choose one');
    } catch (e, st) {
      AppLog.e('shareAwignAppLink: ${e.toString()} \n${st.toString()}');
    }
    Map<String, dynamic> properties =
        await UserProperty.getUserProperty(currentUser);
    ClevertapHelper.instance()
        .addCleverTapEvent(ClevertapHelper.shareApp, properties);
  }

  static doLogout() async {
    MoEngage.logout();
    FaceBookEventHelper.addEvent(FacebookConstant.signOut, null);
    SPUtil? spUtil = await SPUtil.getInstance();
    spUtil?.clear();
    shouldShowProfileCompletionBottomSheet();
    MRouter.pushNamedAndRemoveUntil(MRouter.loginScreenWidget);
    MoEngage.logout();
  }

  static clearUserData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    spUtil?.clear();
  }

  static shouldShowProfileCompletionBottomSheet() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    if (spUtil?.getProfileCompletionBottomSheetCount() == null || (spUtil?.getProfileCompletionBottomSheetCount() ?? 0) < 3) {
      // spUtil?.shouldShowProfileCompletionBottomSheet(true);
      spUtil?.putProfileCompletionBottomSheetCount((spUtil.getProfileCompletionBottomSheetCount() ?? 0) + 1);
    }
  }
}
