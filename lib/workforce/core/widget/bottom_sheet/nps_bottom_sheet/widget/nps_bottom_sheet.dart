import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_actions.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_events.dart';
import 'package:awign/workforce/core/data/local/repository/logging_event/helper/logging_page_names.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/nps_bottom_sheet/cubit/nps_bottom_sheet_cubit.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

void showNpsBottomSheet(
    BuildContext context) {
  showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      builder: (_) {
        return const NpsBottomSheet();
      });
}

class NpsBottomSheet extends StatefulWidget {
  const NpsBottomSheet({Key? key}) : super(key: key);

  @override
  State<NpsBottomSheet> createState() => _NpsBottomSheetState();
}

class _NpsBottomSheetState extends State<NpsBottomSheet> {
  final _npsBottomSheetCubit = sl<NpsBottomSheetCubit>();
  UserData? _userData;
  SPUtil? spUtil;

  @override
  void initState() {
    super.initState();
    setData();
    subscribeUIStatus();
  }

  Future<void> setData() async {
    spUtil = await SPUtil.getInstance();
    setState(() {
      _userData = spUtil?.getUserData();
    });
  }

  void subscribeUIStatus() {
    _npsBottomSheetCubit.uiStatus.listen(
          (uiStatus) {
        switch (uiStatus.event) {
          case Event.success:
            MRouter.pop(null);
            Helper.showInfoToast('Rating Submitted Successfully',
                color: AppColors.success300);
            break;
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              Dimens.padding_16,
              Dimens.padding_88,
              Dimens.padding_16,
              Dimens.padding_48,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${'hey_serkan'.tr}${_userData?.name ?? ""}!',
                  style: Get.context?.textTheme.bodyText1SemiBold?.copyWith(
                      color: AppColors.black, fontSize: Dimens.font_16),
                ),
                const SizedBox(height: Dimens.margin_16),
                Text(
                  'your_review_is_valuable_to_us'.tr,
                  style: Get.context?.textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryMain,),
                ),
                const SizedBox(height: Dimens.margin_8),
                Text(
                  'share_your_experience'.tr,
                  textAlign: TextAlign.center,
                  style: Get.context?.textTheme.bodyMedium?.copyWith(
                      color: AppColors.backgroundGrey800, fontSize: Dimens.font_16),
                ),
                const SizedBox(height: Dimens.margin_16),
                buildNumberKeyBoardWidget(),
                const SizedBox(height: Dimens.margin_16),
                buildSubmitButton(),
              ],
            ),
          ),
          Positioned(
            top: -240,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/device.png',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNumberKeyBoardWidget()
  {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Dimens.padding_16,
        Dimens.padding_32,
        Dimens.padding_16,
        Dimens.padding_16,
      ),
      decoration:  BoxDecoration(
        color: AppColors.backgroundGrey300,
        borderRadius: BorderRadius.circular(Dimens.radius_16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'how_likely_are_you_to_recommend_awign'.tr,
            textAlign: TextAlign.center,
            style: Get.context?.textTheme.titleLarge?.copyWith(
                color: AppColors.backgroundBlack,),
          ),
          const SizedBox(height: Dimens.margin_16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Dimens.padding_8,
            runSpacing: Dimens.padding_8,
            children: List.generate(11, (index) {
              return MyInkWell(
                onTap: (){
                  _npsBottomSheetCubit.changeNumberRating(index);
                  _npsBottomSheetCubit.changeButtonStatus(ButtonStatus(isEnable: true));
                },
                  child: buildNumberButton(index));
            }),
          ),
          const SizedBox(height: Dimens.margin_16),
          Text(
            'not_likely'.tr,
            textAlign: TextAlign.center,
            style: Get.context?.textTheme.bodySmall?.copyWith(
              color: AppColors.backgroundGrey800,),
          ),
        ],
      ),
    );
  }

  Widget buildNumberButton(int i)
  {
    return StreamBuilder<int>(
      stream: _npsBottomSheetCubit.numberRatingStream,
      builder: (context, snapshot) {
        Color bgColor;
        Color textColor;
        if(snapshot.hasData && snapshot.data! <= 6 && snapshot.data! == i)
          {
            bgColor = AppColors.error200;
            textColor = AppColors.backgroundWhite;
          } else if(snapshot.hasData && snapshot.data! > 6 && snapshot.data! <= 8 && snapshot.data! == i)
            {
              bgColor = AppColors.warning250;
              textColor = AppColors.backgroundWhite;
            }else if(snapshot.hasData && snapshot.data! > 8 && snapshot.data! == i)
        {
          bgColor = AppColors.success300;
          textColor = AppColors.backgroundWhite;
        }else{
          bgColor = AppColors.backgroundWhite;
          textColor = AppColors.backgroundGrey600;
        }
        return Container(
          decoration:  BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(Dimens.radius_8),
          ),
          padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16,
            Dimens.padding_8,
            Dimens.padding_16,
            Dimens.padding_8,
          ),
          child: Text('$i',style: Get.context?.textTheme.titleLarge?.copyWith(
              color: textColor,),),
        );
      }
    );
  }

  Widget buildSubmitButton()
  {
    return RaisedRectButton(
      text: 'submit'.tr,
      buttonStatus: _npsBottomSheetCubit.buttonStatus,
      textColor: AppColors.backgroundWhite,
      onPressed: () {
          _npsBottomSheetCubit.npsRating("${_userData?.id}",_npsBottomSheetCubit.numberRatingValue);
          LoggingData loggingData = LoggingData(event: LoggingEvents.ratingSubmitted,
              action: LoggingActions.clicked,pageName: LoggingPageNames.enterOtpEarnings);
          CaptureEventHelper.captureEvent(
              loggingData: loggingData);
      },
    );
  }

  Future<bool> _onWillPop()
  {
    return Future.value(false);
  }
}
