import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get.dart' as con;

String _dialogMessage = "Loading...";

enum ProgressDialogType { Normal, Download }

ProgressDialogType _progressDialogType = ProgressDialogType.Normal;
double _progress = 0.0;

bool _isShowing = false;

class AppProgressDialog {
  late _MyDialog _dialog;

  late BuildContext _buildContext, _context;

  AppProgressDialog(
      BuildContext buildContext, ProgressDialogType progressDialogType) {
    _buildContext = buildContext;

    _progressDialogType = progressDialogType;
  }

  void setMessage(String mess) {
    _dialogMessage = mess;
    // printWrapped("AppProgressDialog message changed: $mess");
  }

  void update({required double progress, required String message}) {
    // printWrapped("AppProgressDialog message changed: ");
    if (_progressDialogType == ProgressDialogType.Download) {
      // printWrapped("Old Progress: $_progress, New Progress: $progress");
      _progress = progress;
    }
    // printWrapped("Old message: $_dialogMessage, New Message: $message");
    _dialogMessage = message;
    _dialog.update();
  }

  bool isShowing() {
    return _isShowing;
  }

  void hide() {
    if (_isShowing) {
      _isShowing = false;
      Navigator.pop(con.Get.context!);
      // printWrapped('AppProgressDialog dismissed');
    }
  }

  void show() {
    if (!_isShowing) {
      _dialog = _MyDialog();
      _isShowing = true;
      // printWrapped('AppProgressDialog shown');
      showDialog<dynamic>(
        context: _buildContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _context = context;
          return Dialog(
              insetAnimationCurve: Curves.easeInOut,
              insetAnimationDuration: const Duration(milliseconds: 100),
              elevation: Dimens.elevation_8,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(Dimens.radius_8))),
              child: _dialog);
        },
      );
    }
  }

  void showLoadingDialog(String message) {
    if (!_isShowing) {
      _isShowing = true;
      // printWrapped('AppProgressDialog shown');
      showDialog<dynamic>(
        context: _buildContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _context = context;
          return Dialog(
            insetAnimationCurve: Curves.easeInOut,
            insetAnimationDuration: const Duration(milliseconds: 100),
            elevation: Dimens.elevation_8,
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimens.radius_16))),
            child: Container(
              width: 100,
              height: 100,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppCircularProgressIndicator(),
                    const SizedBox(height: Dimens.margin_8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: context.textTheme.subtitle2,
                    )
                  ],
                ),
              ),
            ),
          );

          // return Dialog(
          //   backgroundColor: AppColors.transparent,
          //   insetAnimationCurve: Curves.easeInOut,
          //   insetAnimationDuration: const Duration(milliseconds: 100),
          //   elevation: 0,
          //   shape: const RoundedRectangleBorder(
          //       borderRadius:
          //       BorderRadius.all(Radius.circular(Dimens.radius_16))),
          //   child: Container(
          //     // width: 100,
          //     // height: 100,
          //     child: Center(
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: <Widget>[
          //           // AppCircularProgressIndicator(),
          //           RippleAnimation(
          //             repeat: true,
          //             color: AppColors.primary500,
          //             minRadius: 90,
          //             ripplesCount: 6,
          //             duration: const Duration(milliseconds: 5300),
          //             child: SvgPicture.asset(
          //               'assets/images/ic_awign_logo.svg',
          //               color: AppColors.backgroundWhite,
          //             ),
          //           ),
          //           const SizedBox(height: Dimens.margin_8),
          //           Text(
          //             message,
          //             textAlign: TextAlign.center,
          //             style: context.textTheme.subtitle2?.copyWith(color: AppColors.backgroundWhite),
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          // );
        },
      );
    }
  }
}

// ignore: must_be_immutable
class _MyDialog extends StatefulWidget {
  final _dialog = _MyDialogState();

  update() {
    _dialog.changeState();
  }

  @override
  // ignore: must_be_immutable
  State<StatefulWidget> createState() {
    return _dialog;
  }
}

class _MyDialogState extends State<_MyDialog> {
  changeState() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _isShowing = false;
    // printWrapped('AppProgressDialog dismissed by back button');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.0,
      child: Row(
        children: <Widget>[
          const SizedBox(width: Dimens.margin_16),
          /*SizedBox(
            width: 60.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorPrimary),
              backgroundColor: AppColors.colorAccent,
            ),
          ),
          const SizedBox(width: 15.0),*/
          Expanded(
            child: _progressDialogType == ProgressDialogType.Normal
                ? buildNormalDialog()
                : Stack(
                    children: <Widget>[
                      Positioned(
                        top: 35.0,
                        child: Text(_dialogMessage,
                            style: context.textTheme.subtitle2),
                      ),
                      Positioned(
                        bottom: 15.0,
                        right: 15.0,
                        child: Text("$_progress/100",
                            style: context.textTheme.bodyText2),
                      ),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  Widget buildNormalDialog() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppCircularProgressIndicator(),
          const SizedBox(height: Dimens.margin_8),
          //Text(strings.loading, style: Styles.body1TextStyle)
          Text(
            _dialogMessage,
            textAlign: TextAlign.center,
            style: context.textTheme.headline5,
          )
        ],
      ),
    );
  }
}

class MessageBox {
  BuildContext buildContext;
  String message = " ", title = " ";

  MessageBox(this.buildContext, this.message, this.title);

  void show() {
    _showDialog();
  }

  Future? _showDialog() {
    showDialog(
      context: buildContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('$title'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.transparent,
              ),
              onPressed: () => {
                Navigator.of(context).pop(),
              },
              child: Text(
                'Ok',
                style: context.textTheme.bodyText1?.copyWith(
                    color: context.theme.iconColorHighlighted,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
          content: SizedBox(
            height: 45.0,
            child: Center(
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: context.textTheme.headline5,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                ],
              ),
            ),
          ),
        );
      },
    );
    return null;
  }
}
