import 'package:awign/workforce/auth/data/model/user_feedback_response.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/rate_us/cubit/rate_us_cubit.dart';
import 'package:awign/workforce/more/feature/rate_us/widget/thanks_feedback_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_page_names.dart';

void showrateUsBottomSheet(BuildContext context, String fromRoute) {
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
        return RateUsWidget(fromRoute);
      });
}

class RateUsWidget extends StatefulWidget {
  final String fromRoute;
  const RateUsWidget(this.fromRoute, {Key? key}) : super(key: key);

  @override
  State<RateUsWidget> createState() => _RateUsWidgetState();
}

class _RateUsWidgetState extends State<RateUsWidget> {
  final RateUsCubit _rateUsCubit = sl<RateUsCubit>();
  TextEditingController textController = TextEditingController();
  double getRating = 0;
  UserData? _currentUser;
  String pageName = '';
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    pageName = '';
    switch (widget.fromRoute) {
      case MRouter.moreWidget:
        pageName = LoggingPageNames.profiles;
        break;
      case MRouter.dashboardWidget:
        pageName = LoggingPageNames.myJobs;
        break;
      case MRouter.earningsWidget:
        pageName = LoggingPageNames.earnings;
        break;
    }
    LoggingData loggingData =
        LoggingData(event: LoggingEvents.appReviewPopUp, pageName: pageName);
    CaptureEventHelper.captureEvent(loggingData: loggingData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.margin_16,
          Dimens.padding_16, MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: MyInkWell(
                  onTap: () async {
                    await _rateUsCubit.internalUserFeedback(
                        getUserFeedback(Status.discarded));
                    LoggingData loggingData = LoggingData(
                        event: LoggingEvents.appReviewCrossClicked,
                        pageName: pageName);
                    CaptureEventHelper.captureEvent(loggingData: loggingData);
                    MRouter.pop(null);
                  },
                  child:
                      SvgPicture.asset('assets/images/ic_close_circle.svg'))),
          Text(
            'rate_your_experience_with_us'.tr,
            style: Get.textTheme.bodyText1Bold?.copyWith(
                color: AppColors.backgroundBlack, fontSize: Dimens.font_16),
          ),
          const SizedBox(height: Dimens.padding_16),
          Text(
            'your_feedback_helps_us_improve'.tr,
            style: Get.textTheme.bodyText1?.copyWith(
                color: AppColors.backgroundBlack, fontSize: Dimens.font_14),
          ),
          const SizedBox(height: Dimens.padding_12),
          RatingBar.builder(
              minRating: 1,
              itemBuilder: (context, _) => Padding(
                  padding: const EdgeInsets.only(right: Dimens.padding_12),
                  child: StreamBuilder<bool>(
                      stream: _rateUsCubit.isRated,
                      builder: (context, snapshot) {
                        return SvgPicture.asset(
                            snapshot.data ?? false
                                ? 'assets/images/color_star.svg'
                                : 'assets/images/star.svg',
                            height: Dimens.iconSize_40,
                            color: AppColors.warning250);
                      })),
              onRatingUpdate: (rating) {
                _rateUsCubit.changeIsRated(true);
                getRating = rating;
              }),
          const SizedBox(height: Dimens.padding_12),
          buildSuggestionBox(),
          buildSubmitButton(),
        ],
      ),
    );
  }

  Widget buildSubmitButton() {
    return StreamBuilder<bool>(
        stream: _rateUsCubit.isRated,
        builder: (context, snapshot) {
          return RaisedRectButton(
            text: 'submit'.tr,
            onPressed: () async {
              bool? value = snapshot.data ?? false
                  ? await _rateUsCubit
                      .internalUserFeedback(getUserFeedback(Status.submitted))
                  : null;
              if (value!) {
                MRouter.pop(null);
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
                      return const ThanksFeedbackWidget();
                    });
              }
              LoggingData loggingData = LoggingData(
                  event: LoggingEvents.appReviewSubmitClicked,
                  pageName: pageName);
              CaptureEventHelper.captureEvent(loggingData: loggingData);
            },
            backgroundColor: snapshot.data ?? false
                ? AppColors.primaryMain
                : AppColors.backgroundGrey700,
          );
        });
  }

  Widget buildSuggestionBox() {
    return StreamBuilder<bool>(
        stream: _rateUsCubit.isRated,
        builder: (context, snapshot) {
          return snapshot.data ?? false
              ? Column(
                  children: [
                    Text(
                      'please_share_your_experience_on_stuff_you_liked_or_disliked_optional'
                          .tr,
                      style: Get.textTheme.bodyText1?.copyWith(
                          color: AppColors.backgroundBlack,
                          fontSize: Dimens.font_16,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: Dimens.padding_12),
                    TextFormField(
                      minLines: 4,
                      maxLines: 6,
                      controller: textController,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.backgroundGrey300,
                        hintText: 'please_add_suggestions'.tr,
                        hintStyle: Get.textTheme.bodyText1?.copyWith(
                            color: AppColors.backgroundGrey700,
                            fontSize: Dimens.font_16,
                            fontWeight: FontWeight.w400),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(Dimens.radius_16)),
                        ),
                        focusColor: AppColors.primaryMain,
                      ),
                    ),
                    const SizedBox(height: Dimens.padding_12),
                  ],
                )
              : const SizedBox();
        });
  }

  UserFeedbackRequest getUserFeedback(Status status) {
    if (status == Status.submitted) {
      SupplyFeedback supplyFeedback = SupplyFeedback(
          message: textController.text ?? "",
          overallRating: getRating.toInt(),
          status: status.name,
          userId: _currentUser!.id ?? -1);
      return UserFeedbackRequest(supplyFeedback: supplyFeedback);
    } else {
      SupplyFeedback supplyFeedback =
          SupplyFeedback(status: status.name, userId: _currentUser!.id);
      return UserFeedbackRequest(supplyFeedback: supplyFeedback);
    }
  }
}
