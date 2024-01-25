import 'package:awign/workforce/auth/feature/app_language_selection/cubit/app_language_selection_cubit.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:simple_shadow/simple_shadow.dart';

class AppLanguageSelection extends StatefulWidget {
  const AppLanguageSelection({Key? key}) : super(key: key);

  @override
  State<AppLanguageSelection> createState() => _AppLanguageSelectionState();
}

class _AppLanguageSelectionState extends State<AppLanguageSelection> {
  final _appLanguageSelectionCubit = sl<AppLanguageSelectionCubit>();
  String selectedValue = "";
  String? appLanguage;

  @override
  void initState() {
    super.initState();
    setData();
    subscribeUIStatus();
  }

  Future<void> setData() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    appLanguage = spUtil?.getAppLanguage();
    _appLanguageSelectionCubit.changeSelectedLanguage(appLanguage);
  }

  void subscribeUIStatus() {
    _appLanguageSelectionCubit.uiStatus.listen(
          (uiStatus) async {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.updated:
            MRouter.pushNamedAndRemoveUntil(MRouter.phoneVerificationWidget);
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
        backgroundColor: AppColors.backgroundWhite,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
              0, Dimens.margin_60, Dimens.margin_16, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildImage(),
              const SizedBox(height: Dimens.margin_24),
              buildHeadingText(),
              const SizedBox(height: Dimens.margin_8),
              buildText(),
              languageSelector(),
              buildLanguageSelectionButton()
            ],
          ),
        ));
  }

  Widget buildHeadingText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text("Choose Language/भाषा चुनें",
          style: context.textTheme.headline6?.copyWith(color: AppColors.primary900)),
    );
  }

  Widget buildText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Text("You can now use Awign app in your preferred language",
          style: context.textTheme.bodyText2
              ?.copyWith(color: AppColors.backgroundGrey800)),
    );
  }

  Widget buildImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: SimpleShadow(
          child: SvgPicture.asset('assets/images/choose_language.svg'),
          color: Colors.grey,
          sigma: Dimens.margin_8),
    );
  }

  Widget languageSelector() {
    return Expanded(
      child: StreamBuilder<String?>(stream: null,builder: (context, snapshot) {
        return ListView(
          children: [
            radioButton("English", false, 'en'),
            radioButton("हिन्दी Hindi", true, 'hi'),
            radioButton("తెలుగు Telugu", true, 'te'),
            radioButton("मराठी Marathi", true, 'ma'),
            radioButton("ಕನ್ನಡ Kannada", true, 'kn')
          ],
        );
      }),
    );
  }

  Widget radioButton(String language, bool flag, String langCode) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimens.margin_4),
      child: RadioListTile<String>(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
          dense: true,
          value: langCode,
          groupValue: selectedValue,
          title: Row(
            children: [
              Text(
                language,
                style: context.textTheme.bodyText2SemiBold?.copyWith(color: AppColors.backgroundBlack),
              ),
              const SizedBox(
                width: Dimens.margin_12,
              ),
              if (flag)
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.yellow,
                      border: Border.all(color: AppColors.yellow),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(Dimens.radius_4))),
                  child: const Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                    child: Text(
                      "Beta",
                      style: TextStyle(fontSize: Dimens.font_12),
                    ),
                  ),
                )
            ],
          ),
          onChanged: (value) =>
              setState(() {
                selectedValue = value.toString();
              })),
    );
  }

  Widget buildLanguageSelectionButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
          Dimens.padding_16, Dimens.padding_16),
      child: RaisedRectButton(
        text: "Continue/आगे बढ़ें",
        onPressed: () {
          if (selectedValue.isNotEmpty) {
            _appLanguageSelectionCubit.setAppLanguage(selectedValue);
          }
          else {
            Helper.showErrorToast('please_select_language'.tr);
          }
        },
      ),
    );
  }
}
