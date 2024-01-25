import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/dialog/custom_dialog.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppAlertDialog extends StatefulWidget {
  final String message;
  final Function() onOKTap;

  AppAlertDialog(this.message, this.onOKTap);

  @override
  _AppAlertDialogState createState() => _AppAlertDialogState(message, onOKTap);
}

class _AppAlertDialogState extends State<AppAlertDialog> {
  final String message;
  final Function() onOKTap;

  _AppAlertDialogState(this.message, this.onOKTap);

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      showPadding: false,
      child: buildDialogContent(context),
    );
  }

  Widget buildDialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimens.padding_16),
      constraints: BoxConstraints(
        maxWidth: Dimens.alertDialogMaxWidth,
      ),
      decoration: BoxDecoration(
        //color: AppColors.secondary,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(Dimens.radius_8),
        /*boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: Dimens.radius_8dp,
            offset: const Offset(0.0, 8.0),
          ),
        ],*/
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          //SizedBox(height: Dimens.margin_8dp),
          //Image.asset('assets/images/ns_logo_white.png'/*, height: 50*/),
          SizedBox(height: Dimens.margin_8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textTheme.headline5,
          ),

          SizedBox(height: Dimens.margin_16),
          //buildSaveButton(context),
          buildCancelButton(context),
          //SizedBox(height: Dimens.margin_8dp),
        ],
      ),
    );
  }

  /*Widget buildSaveButton(BuildContext context) {
    return RaisedRectButton(
      text: 'Save',
      textColor: AppColors.white,
      onPressed: () {},
      //backgroundColor: AppColors.white,
      //borderColor: AppColors.lightGrey,
    );
  }*/

  Widget buildCancelButton(BuildContext context) {
    return RaisedRectButton(
      text: 'OK',
      textColor: AppColors.backgroundWhite,
      onPressed: onOKTap,
      //backgroundColor: AppColors.colorAccent,
      //borderColor: AppColors.lightGrey,
    );
  }
}
