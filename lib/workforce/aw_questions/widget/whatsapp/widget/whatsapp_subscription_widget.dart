import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/widget/whatsapp/cubit/whatsapp_subscription_cubit.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/whatsapp_bottom_sheet/widget/whatsapp_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class WhatsappSubscriptionWidget extends StatefulWidget {
  final ScreenRow screenRow;
  final Function(ScreenRow screenRow) onAnswerAddOrUpdate;

  const WhatsappSubscriptionWidget(this.screenRow, this.onAnswerAddOrUpdate,
      {Key? key})
      : super(key: key);

  @override
  State<WhatsappSubscriptionWidget> createState() =>
      _WhatsappSubscriptionWidgetState();
}

class _WhatsappSubscriptionWidgetState
    extends State<WhatsappSubscriptionWidget> {
  final _whatsappSubscriptionCubit = sl<WhatsappSubscriptionCubit>();
  SPUtil? _spUtil;
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void subscribeUIStatus() {
    _whatsappSubscriptionCubit.uiStatus.listen(
          (uiStatus) {
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage,
              color: AppColors.success300);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
      },
    );
  }

  void getCurrentUser() async {
    _spUtil = await SPUtil.getInstance();
    _currentUser = _spUtil?.getUserData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _currentUser = _spUtil?.getUserData();
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: Dimens.switchHeight24,
              child: StreamBuilder<bool?>(
                stream: _whatsappSubscriptionCubit.isWhatsappSubscribed,
                builder: (context, subscribeWhatsapp) {
                  bool isSubscribed = false;
                  if((_spUtil?.isWhatsAppSubscribe() ?? false) || (subscribeWhatsapp.data ?? false) || (widget.screenRow.question?.answerUnit?.boolValue ?? false) || (_currentUser?.subscribedToWhatsapp ?? false))
                    {
                        isSubscribed = true;
                    }
                  return Switch(
                      splashRadius: Dimens.radius_48,
                      value: isSubscribed,
                      onChanged: (v) {
                        _whatsappSubscriptionCubit.changeIsWhatsappSubscribed(v);
                        _spUtil?.putWhatsappSubscribe(v);
                        if (v) {
                          _whatsappSubscriptionCubit
                              .subscribeWhatsapp(_currentUser!,true);
                        } else {
                          showWhatsAppBottomSheet(context, () {
                            _whatsappSubscriptionCubit.unSubscribeWhatsapp(_currentUser!);
                            MRouter.pop(null);
                          }, () {
                            _whatsappSubscriptionCubit
                                .changeIsWhatsappSubscribed(true);
                            _spUtil?.putWhatsappSubscribe(true);
                            _whatsappSubscriptionCubit.subscribeWhatsapp(_currentUser!,false);
                            MRouter.pop(null);
                          });
                        }
                        if (_currentUser != null) {
                          _currentUser!.subscribedToWhatsapp = v;
                          _spUtil?.putUserData(_currentUser);
                        }
                        widget.screenRow.question?.answerUnit?.boolValue = v;
                        widget.onAnswerAddOrUpdate(widget.screenRow);
                      });
                }
              ),
            )
          ],
        ),
      ],
    );
  }
}
