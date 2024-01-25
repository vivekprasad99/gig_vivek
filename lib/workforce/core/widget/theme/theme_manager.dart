import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ThemeManager {
  static final appTheme = ThemeData(
    primaryColor: AppColors.primaryMain,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryMain,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    backgroundColor: AppColors.backgroundLight,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: AppTextThemes.interLight,
    fontFamily: 'inter',
    dividerColor: AppColors.backgroundGrey500,
    dividerTheme: const DividerThemeData(thickness: 1),
    hintColor: AppColors.backgroundGrey700,
  );

  static final appThemeDark = ThemeData(
    primaryColor: AppColors.primaryMain,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryMain,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    backgroundColor: AppColors.backgroundDark,
    brightness: Brightness.dark,
    textTheme: AppTextThemes.interDark,
    fontFamily: 'inter',
    dividerColor: AppColors.backgroundWhite,
    dividerTheme: const DividerThemeData(thickness: 1),
    hintColor: AppColors.secondary2Default,
  );

  static const upwardsBoxShadow = BoxShadow(
      color: Color.fromARGB(25, 21, 28, 42),
      spreadRadius: 2,
      blurRadius: 4,
      offset: Offset(0, -2));

  static Brightness? get currentSystemBrightness =>
      SchedulerBinding.instance.window.platformBrightness;

  static setStatusBarAndNavigationBarColors(ThemeMode themeMode) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          themeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
      systemNavigationBarIconBrightness:
          themeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: themeMode == ThemeMode.light
          ? AppColors.backgroundLight
          : AppColors.backgroundDark,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
  }
}

class AppColors {
  static const primaryMain = Color(0xFF113DBC);
  static const primary50 = Color(0xFFECF1FD);
  static const primary100 = Color(0xFFDCE1FA);
  static const primary200 = Color(0xFFB7C3F4);
  static const primary300 = Color(0xFF5F7CE7);
  static const primary500 = Color(0xFF182F8F);
  static const primary600 = Color(0xFF11236C);
  static const primary700 = Color(0xFF0B1848);
  static const primary800 = Color(0xFF081236);
  static const primary900 = Color(0xFF030612);

  static const secondary1100 = Color(0xFFEFECFC);
  static const secondary1200 = Color(0xFFD1C7F6);
  static const secondary1300 = Color(0xFF937DEC);
  static const secondary1Default = Color(0xFF3A11BC);

  static const secondary2100 = Color(0xFFEEF9FC);
  static const secondary2200 = Color(0xFFCFEDF8);
  static const secondary2300 = Color(0xFF92D5F0);
  static const secondary2400 = Color(0xFF59B8E5);
  static const secondary2Default = Color(0xFF1193BC);

  static const success100 = Color(0xFFE3FEEF);
  static const success200 = Color(0xFF6FECA4);
  static const success300 = Color(0xFF28C269);
  static const success400 = Color(0xFF1F9A53);
  static const success500 = Color(0xFF115A30);

  static const link100 = Color(0xFFE1F2FF);
  static const link200 = Color(0xFF88CCFF);
  static const link300 = Color(0xFF2EA5FF);
  static const link400 = Color(0xFF028EF8);
  static const link500 = Color(0xFF0271C5);

  static const warning100 = Color(0xFFFFFAEB);
  static const warning200 = Color(0xFFFEF0C7);
  static const warning300 = Color(0xFFF79009);
  static const warning400 = Color(0xFFDC6803);
  static const warning500 = Color(0xFFB54708);
  static const warning250 = Color(0xFFF9A63A);
  static const yellow = Color(0xFFFFC82C);

  static const error100 = Color(0xFFFFEDED);
  static const error200 = Color(0xFFFFAEAE);
  static const error300 = Color(0xFFFE4141);
  static const error400 = Color(0xFFEA0000);
  static const error500 = Color(0xFFAC0101);

  static const  backgroundWhite = Color(0xFFFFFFFF);
  static const backgroundGrey100 = Color(0xffF6FAFB);
  static const backgroundGrey200 = Color(0xffF4F9FA);
  static const backgroundGrey300 = Color(0xFFECF3F5);
  static const backgroundGrey400 = Color(0xffD9E9ED);
  static const backgroundGrey500 = Color(0xFFAABFC3);
  static const backgroundGrey600 = Color(0xff9CAFB1);
  static const backgroundGrey700 = Color(0xff8FA3A5);
  static const backgroundGrey800 = Color(0xff606A7B);
  static const backgroundGrey900 = Color(0xFF3C4858);
  static const geyser = Color(0xFFdae0e5);

  static const grey = Color(0xFFF5F5F8);

  static const backgroundBlack = Color(0xFF1F2D3D);

  static const overlay = Color(0xBF1F2D3D);
  static const black = Color(0xFF000000);
  static const transparent = Color(0xFFFFFF);
  static const textColor = Color(0xFF171D27);

  static const secondary = primaryMain;

  static const backgroundLight = backgroundGrey100;
  static const backgroundDark = Color(0xFF1F2B2D);

  static const surfaceDark = Color(0xFF0E272D);

  static const pine = Color(0xff49be91);
  static const pattensBlue = Color(0xffdee2e4);
  static const orange = Color(0xfff8843b);
  static const alto = Color(0xffDDDDDD);
  static const concrete = Color(0xfff3f3f3);
  static const abyssalAnchorfishBlue = Color(0xff18212F);

  static const iconColorNormalLight = backgroundGrey600;
  static const iconColorNormalDark = backgroundGrey300;

  static const iconColorHighlightedLight = primaryMain;
  static const iconColorHighlightedDark = backgroundWhite;

  static const facebookBlue = Color(0xFF3A559F);
  static const googleRed = Color(0xFFDC4E41);
  static const backgroundPink = Color(0xFFFFD7CD);
  static const backgroundDarkPink = Color(0xFFD37E69);
  static const backgroundGold = Color(0xFFFFF7DA);
  static const backgroundYellow = Color(0xFFF6C629);
  static const backgroundViolet = Color(0xFF775091);
}

class Dimens {
  static const double margin_4 = 4;
  static const double margin_8 = 8;
  static const double margin_11 = 11;
  static const double margin_12 = 12.0;
  static const double margin_16 = 16.0;
  static const double margin_20 = 20.0;
  static const double margin_24 = 24.0;
  static const double margin_28 = 28.0;
  static const double margin_32 = 32.0;
  static const double margin_36 = 36.0;
  static const double margin_38 = 38.0;
  static const double margin_40 = 40.0;
  static const double margin_44 = 44.0;
  static const double margin_48 = 48.0;
  static const double margin_56 = 56.0;
  static const double margin_60 = 60.0;
  static const double margin_80 = 80.0;
  static const double margin_120 = 120.0;
  static const double margin_228 = 228.0;

  static const double padding_4 = 4;
  static const double padding_6 = 6;
  static const double padding_8 = 8;
  static const double padding_11 = 11.0;
  static const double padding_12 = 12.0;
  static const double padding_14 = 14.0;
  static const double padding_16 = 16.0;
  static const double padding_20 = 20.0;
  static const double padding_24 = 24.0;
  static const double padding_28 = 28.0;
  static const double padding_32 = 32.0;
  static const double padding_36 = 36.0;
  static const double padding_40 = 40.0;
  static const double padding_48 = 48.0;
  static const double padding_56 = 56.0;
  static const double padding_60 = 60.0;
  static const double padding_64 = 64.0;
  static const double padding_80 = 80.0;
  static const double padding_88 = 88.0;
  static const double padding_150 = 150.0;
  static const double padding_200 = 200.0;
  static const double padding_220 = 220.0;

  static const double font_8 = 8.0;
  static const double font_10 = 10.0;
  static const double font_12 = 12.0;
  static const double font_14 = 14.0;
  static const double font_16 = 16.0;
  static const double font_18 = 18.0;
  static const double font_20 = 20.0;
  static const double font_24 = 24.0;
  static const double font_28 = 28.0;
  static const double font_36 = 36.0;

  static const double radius_4 = 4;
  static const double radius_6 = 6;
  static const double radius_8 = 8;
  static const double radius_12 = 12;
  static const double radius_16 = 16;
  static const double radius_20 = 20;
  static const double radius_24 = 24;
  static const double radius_32 = 32;
  static const double radius_36 = 36;
  static const double radius_40 = 40;
  static const double radius_48 = 48;

  static const double pbWidth_16 = 16;
  static const double pbWidth_48 = 48;
  static const double pbWidth_72 = 72;

  static const double pbHeight_16 = 16;
  static const double pbHeight_48 = 48;
  static const double pbHeight_72 = 72;

  static const double etWidth_56 = 56;
  static const double etWidth_60 = 60;
  static const double etWidth_64 = 64;
  static const double etWidth_72 = 72;
  static const double etWidth_100 = 100;
  static const double etWidth_140 = 140;
  static const double etWidth_150 = 150;

  static const double etHeight_32 = 32;
  static const double etHeight_40 = 40;
  static const double etHeight_48 = 48;

  static const double btnWidth_32 = 32;
  static const double btnWidth_40 = 40;
  static const double btnWidth_48 = 48;
  static const double btnWidth_64 = 64;
  static const double btnWidth_72 = 72;
  static const double btnWidth_90 = 90;
  static const double btnWidth_100 = 100;
  static const double btnWidth_110 = 110;
  static const double btnWidth_128 = 128;
  static const double btnWidth_150 = 150;
  static const double btnWidth_162 = 162;
  static const double btnWidth_180 = 180;
  static const double btnWidth_200 = 200;
  static const double btnWidth_250 = 250;

  static const double btnHeight_32 = 32;
  static const double btnHeight_40 = 40;
  static const double btnHeight_48 = 48;

  static const double imageWidth_40 = 40;
  static const double imageWidth_48 = 48;
  static const double imageWidth_56 = 56;
  static const double imageWidth_100 = 100;
  static const double imageWidth_150 = 150;
  static const double imageWidth_200 = 200;

  static const double imageHeight_40 = 40;
  static const double imageHeight_48 = 48;
  static const double imageHeight_56 = 56;
  static const double imageHeight_100 = 100;
  static const double imageHeight_150 = 150;
  static const double imageHeight_172 = 172;
  static const double imageHeight_200 = 200;

  static const double elevation_1 = 1;
  static const double elevation_2 = 2;
  static const double elevation_4 = 4;
  static const double elevation_8 = 8;

  static const double avatarRadius_20 = 20;
  static const double avatarRadius_48 = 48;
  static const double avatarRadius_56 = 56;

  static const double avatarWidth_40 = 40;
  static const double avatarWidth_90 = 90;
  static const double avatarWidth_100 = 100;

  static const double avatarHeight_40 = 40;
  static const double avatarHeight_90 = 90;
  static const double avatarHeight_100 = 100;

  static const double toolbarHeight = 56;
  static const double tabBarHeight = 56;

  static const double bottomNavBarHeight = 60;
  static const double stepperHeight = 124;

  static const double dividerHeight_1 = 1;
  static const double dividerHeight_3 = 3;
  static const double dividerHeight_02 = 0.2;

  static const double dividerWidth_1 = 1;
  static const double dividerWidth_3 = 3;
  static const double dividerWidth_02 = 0.2;

  static const double border_0_5 = 0.5;
  static const double border_1 = 1;
  static const double border_1_5 = 1.5;
  static const double border_2 = 2;

  static const double placeholderSize_48 = 48;

  static const double iconSize_8 = 8;
  static const double iconSize_12 = 12;
  static const double iconSize_16 = 16;
  static const double iconSize_14 = 14;
  static const double iconSize_20 = 20;
  static const double iconSize_24 = 24;
  static const double iconSize_28 = 28;
  static const double iconSize_32 = 32;
  static const double iconSize_40 = 40;
  static const double iconSize_48 = 48;
  static const double iconSize_100 = 100;

  static const double avatarWidth_32 = 32;
  static const double avatarWidth_24 = 24;
  static const double avatarWidth_20 = 20;

  static const double avatarHeight_32 = 32;
  static const double avatarHeight_24 = 24;
  static const double avatarHeight_20 = 20;

  static const double dialogMaxWidth = 500;
  static const double alertDialogMaxWidth = 200;

  static const double radioButtonWidth = 16;

  static const double radioButtonHeight = 16;

  static const double linearCircularIndicatorHeight_8 = 8;

  static const double linearProgressIndicatorHeight4 = 4;

  static const double mobileWidth = 500;

  static const double mobileHeight = 1200;

  static const double tabIndicatorHeight = 1.0;

  static const double switchHeight24 = 24;

  static const double badgeIconWidth = 16;

  static const double badgeIconHeight = 16;
}

class AppTextThemes {
  static TextTheme interLight = textThemeLight;
  static TextTheme interDark = textThemeDark;
  static TextTheme textThemeLight = const TextTheme(
    headline1: headline1,
    headline2: headline2,
    headline3: headline3,
    headline4: headline4,
    headline5: headline5,
    headline6: headline6,
    bodyText1: bodyText1,
    bodyText2: bodyText2,
    button: button,
    subtitle1: subtitle1,
    subtitle2: subtitle2,
    caption: caption,
    overline: overline,
  );

  static TextTheme textThemeDark = TextTheme(
    headline1: headline1Dark,
    headline2: headline2Dark,
    headline3: headline3Dark,
    headline4: headline4Dark,
    headline5: headline5Dark,
    headline6: headline6Dark,
    bodyText1: bodyText1Dark,
    bodyText2: bodyText2Dark,
    button: buttonDark,
    subtitle1: subtitle1Dark,
    subtitle2: subtitle2Dark,
    caption: captionDark,
    overline: overLineDark,
  );

  static const headline1 = TextStyle(
      fontSize: 72, fontWeight: FontWeight.w700, color: AppColors.textColor);
  static const headline2 = TextStyle(
      fontSize: 60, fontWeight: FontWeight.w800, color: AppColors.textColor);
  static const headline3 = TextStyle(
      fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.textColor);
  static const headline4 = TextStyle(
      fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textColor);
  static const headline5 = TextStyle(
      fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textColor);
  static const headline6 = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textColor);
  static const subtitle1 = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textColor);
  static const subtitle2 = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textColor);
  static const bodyText1 = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textColor);
  static const bodyText2 = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textColor);
  static const button = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.backgroundWhite);
  static const caption = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textColor);
  static const overline = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: AppColors.textColor,
      letterSpacing: 0.1);

  static final headline1Dark =
      headline1.copyWith(color: AppColors.backgroundWhite);
  static final headline2Dark =
      headline2.copyWith(color: AppColors.backgroundWhite);
  static final headline3Dark =
      headline3.copyWith(color: AppColors.backgroundWhite);
  static final headline4Dark =
      headline4.copyWith(color: AppColors.backgroundWhite);
  static final headline5Dark =
      headline5.copyWith(color: AppColors.backgroundWhite);
  static final headline6Dark =
      headline6.copyWith(color: AppColors.backgroundWhite);
  static final subtitle1Dark =
      subtitle1.copyWith(color: AppColors.backgroundWhite);
  static final subtitle2Dark =
      subtitle2.copyWith(color: AppColors.backgroundWhite);
  static final bodyText1Dark =
      bodyText1.copyWith(color: AppColors.backgroundWhite);
  static final bodyText2Dark =
      bodyText2.copyWith(color: AppColors.backgroundWhite);
  static final buttonDark = button.copyWith();
  static final captionDark = caption.copyWith(color: AppColors.backgroundWhite);
  static final overLineDark =
      overline.copyWith(color: AppColors.backgroundWhite);
}

extension TextThemeExtras on TextTheme {
  TextStyle get headline7 => TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: Get.isDarkMode ? AppColors.backgroundWhite : AppColors.textColor);

  TextStyle get headline7SemiBold =>
      headline7.copyWith(fontWeight: FontWeight.w600);

  TextStyle get headline7Bold =>
      headline7.copyWith(fontWeight: FontWeight.w700);

  TextStyle get headline7MediumUnderLine => headline7.copyWith(
      fontWeight: FontWeight.w500, decoration: TextDecoration.underline);

  TextStyle? get headline6SemiBold => headline6?.copyWith(
      fontWeight: FontWeight.w600,
      color: Get.isDarkMode ? AppColors.backgroundWhite : AppColors.textColor);

  TextStyle? get headline5SemiBold => headline5?.copyWith(
      fontWeight: FontWeight.w600,
      color: Get.isDarkMode ? AppColors.backgroundWhite : AppColors.textColor);

  TextStyle? get headline3Medium => headline3?.copyWith(
      fontWeight: FontWeight.w500,
      color: Get.isDarkMode ? AppColors.backgroundWhite : AppColors.textColor);

  TextStyle? get bodyText1SemiBold =>
      bodyText1?.copyWith(fontWeight: FontWeight.w600);

  TextStyle? get bodyText1Bold =>
      bodyText1?.copyWith(fontWeight: FontWeight.w700);

  TextStyle? get bodyText1MediumUnderLine => bodyText1?.copyWith(
      fontWeight: FontWeight.w500, decoration: TextDecoration.underline);

  TextStyle? get bodyText1Medium =>
      bodyText1?.copyWith(fontWeight: FontWeight.w500);

  TextStyle? get bodyText2SemiBold =>
      bodyText2?.copyWith(fontWeight: FontWeight.w600);

  TextStyle? get bodyText2Bold =>
      bodyText2?.copyWith(fontWeight: FontWeight.w700);

  TextStyle? get bodyText2MediumUnderLine => bodyText2?.copyWith(
      fontWeight: FontWeight.w500, decoration: TextDecoration.underline);

  TextStyle? get bodyText2Medium =>
      bodyText2?.copyWith(fontWeight: FontWeight.w500);

  TextStyle? get captionMedium =>
      caption?.copyWith(fontWeight: FontWeight.w500);

  TextStyle? get captionMediumUnderLine => caption?.copyWith(
      fontWeight: FontWeight.w500, decoration: TextDecoration.underline);

  TextStyle? get captionBold => caption?.copyWith(fontWeight: FontWeight.w700);

  TextStyle get caption2 => TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: Get.isDarkMode ? AppColors.backgroundWhite : AppColors.textColor);

  TextStyle get caption2Medium =>
      caption2.copyWith(fontWeight: FontWeight.w500);

  TextStyle get caption2BoldCAP =>
      caption2.copyWith(fontWeight: FontWeight.w700);

  TextStyle get caption2Bold => caption2.copyWith(fontWeight: FontWeight.w700);
}

extension ThemeExtras on ThemeData {
  Color get appBarColor => brightness == Brightness.light
      ? AppColors.primaryMain
      : AppColors.surfaceDark;

  Color get navBarColor => brightness == Brightness.light
      ? AppColors.backgroundWhite
      : AppColors.surfaceDark;

  Color get textFieldBackgroundColor => brightness == Brightness.light
      ? AppColors.backgroundGrey300
      : AppColors.surfaceDark;

  Color get textFieldOutlineColorSecondary => brightness == Brightness.light
      ? AppColors.secondary2Default
      : AppColors.surfaceDark;

  Color get captionSecondaryColor => brightness == Brightness.light
      ? AppColors.secondary2Default
      : AppColors.secondary2Default;

  Color get iconColorNormal => brightness == Brightness.light
      ? AppColors.iconColorNormalLight
      : AppColors.iconColorNormalDark;

  Color get iconColorHighlighted => brightness == Brightness.light
      ? AppColors.iconColorHighlightedLight
      : AppColors.iconColorHighlightedDark;

  Color get buttonSecondaryColor => brightness == Brightness.light
      ? AppColors.primaryMain
      : AppColors.secondary2Default;

  Color get appDividerColor => brightness == Brightness.light
      ? AppColors.backgroundGrey500
      : AppColors.backgroundWhite;

  Color get toastBackgroundColor => brightness == Brightness.light
      ? AppColors.surfaceDark
      : AppColors.backgroundGrey100;

  Color get toastTextColor => brightness == Brightness.light
      ? AppColors.backgroundWhite
      : AppColors.black;

  Color get inputBoxBackgroundColor => brightness == Brightness.light
      ? AppColors.backgroundGrey300
      : AppColors.surfaceDark;

  Color get inputBoxBorderColor =>
      brightness == Brightness.light ? AppColors.geyser : AppColors.surfaceDark;

  Color get shimmerBaseColor =>
      brightness == Brightness.light ? AppColors.alto : AppColors.alto;

  Color get shimmerHighlightColor =>
      brightness == Brightness.light ? AppColors.concrete : AppColors.concrete;
}
