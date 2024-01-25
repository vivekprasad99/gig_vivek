import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/string_utils.dart';
import 'package:awign/workforce/core/widget/buttons/custom_text_button.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/circle_avatar/custom_circle_avatar.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

void showAccountAlreadyExistsBottomSheet(
    BuildContext context,
    UserData currentUser,
    Function() onLoginAgainTapped,
    Function() onUseDifferentEmailTapped) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return AccountAlreadyExistsWidget(
          currentUser, onLoginAgainTapped, onUseDifferentEmailTapped);
    },
  );
}

class AccountAlreadyExistsWidget extends StatelessWidget {
  final UserData currentUser;
  final Function() onLoginAgainTapped;
  final Function() onUseDifferentEmailTapped;
  const AccountAlreadyExistsWidget(
      this.currentUser, this.onLoginAgainTapped, this.onUseDifferentEmailTapped,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      builder: (_, controller) {
        return Column(
          children: [
            buildCloseIcon(),
            Text('account_already_exists'.tr,
                style: Get.textTheme.bodyText1Bold
                    ?.copyWith(color: AppColors.backgroundBlack)),
            Container(
              margin: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.backgroundGrey300,
                ),
                borderRadius:
                    const BorderRadius.all(Radius.circular(Dimens.radius_4)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildAvatar(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildName(),
                          buildEmail(),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                        Dimens.padding_16,
                        Dimens.padding_16,
                        Dimens.padding_16,
                        Dimens.padding_16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.backgroundGrey200,
                      ),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(Dimens.radius_4)),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/images/ic_link.svg'),
                        const SizedBox(width: Dimens.padding_16),
                        buildMobileNumber(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Dimens.padding_16, Dimens.padding_24, Dimens.padding_16, 0),
              child: Text(
                'to_use_the_existing_account_login_again_or_create_a_new_account'
                    .tr,
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyText2
                    ?.copyWith(color: AppColors.backgroundGrey800),
              ),
            ),
            buildLoginAgainButton(),
            buildUseDifferEmailButton(),
          ],
        );
      },
    );
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null);
        },
        child: const Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildAvatar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
          Dimens.padding_16, Dimens.padding_16),
      child: CustomCircleAvatar(
          radius: Dimens.radius_24,
          url: currentUser.image ??
              "https://awign-production.s3.ap-south-1.amazonaws.com/awign/defaults/icons/${currentUser.name?.substring(0, 1).toLowerCase() ?? 'z'}.png"),
    );
  }

  Widget buildName() {
    if (currentUser.name != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Text(
          currentUser.name ?? '',
          style: Get.textTheme.bodyText2SemiBold
              ?.copyWith(color: AppColors.backgroundBlack),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildEmail() {
    if (currentUser.email != null) {
      return Text(
        currentUser.email ?? '',
        style: Get.textTheme.bodyText2
            ?.copyWith(color: AppColors.backgroundGrey800),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildMobileNumber() {
    String mobileNo =
        StringUtils.maskString(currentUser.userProfile?.mobileNumber, 3, 3);
    return RichText(
      text: TextSpan(
        style: Get.textTheme.bodyText1,
        children: <TextSpan>[
          TextSpan(
            text: 'account_linked_to'.tr,
            style: Get.textTheme.bodyText2
                ?.copyWith(color: AppColors.backgroundGrey800),
          ),
          TextSpan(
            text: ' $mobileNo',
            style: Get.textTheme.bodyText2
                ?.copyWith(color: AppColors.backgroundBlack),
          ),
        ],
      ),
    );
  }

  Widget buildLoginAgainButton() {
    String mobileNo =
        StringUtils.maskString(currentUser.userProfile?.mobileNumber, 3, 3);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.margin_16, Dimens.margin_24, Dimens.margin_16, 0),
      child: RaisedRectButton(
        text: '${'login_again_using'.tr} $mobileNo',
        onPressed: () {
          MRouter.pop(null);
          onLoginAgainTapped();
        },
      ),
    );
  }

  Widget buildUseDifferEmailButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.margin_16, Dimens.margin_16,
          Dimens.margin_16, Dimens.margin_16),
      child: CustomTextButton(
        height: Dimens.btnHeight_40,
        text: 'use_different_email_address'.tr,
        backgroundColor: AppColors.transparent,
        textStyle: Get.textTheme.bodyText2SemiBold
            ?.copyWith(color: AppColors.primaryMain),
        onPressed: () {
          MRouter.pop(null);
          onUseDifferentEmailTapped();
        },
      ),
    );
  }
}
