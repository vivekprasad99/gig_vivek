import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(themeMode: ThemeMode.light)) {
    updateAppTheme();
  }

  void updateAppTheme() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    bool? isDarkModeEnabled = spUtil?.getIsDarkModeEnabled();
    if (isDarkModeEnabled != null && isDarkModeEnabled) {
      _setTheme(ThemeMode.dark);
    } else if (isDarkModeEnabled != null && !isDarkModeEnabled) {
      _setTheme(ThemeMode.light);
    } else {
      final Brightness? currentBrightness =
          ThemeManager.currentSystemBrightness;
      currentBrightness == Brightness.light
          ? _setTheme(ThemeMode.light)
          : _setTheme(ThemeMode.light);
    }
  }

  void _setTheme(ThemeMode themeMode) {
    ThemeManager.setStatusBarAndNavigationBarColors(themeMode);
    Get.changeThemeMode(themeMode);
    emit(ThemeState(themeMode: themeMode));
  }

  Future<bool> getIsDarkModeEnabled() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    bool? isDarkModeEnabled = spUtil?.getIsDarkModeEnabled();
    if (isDarkModeEnabled != null && isDarkModeEnabled) {
      return true;
    } else if (isDarkModeEnabled != null && !isDarkModeEnabled) {
      return false;
    } else {
      if (Get.isDarkMode) {
        return true;
      } else {
        return false;
      }
    }
  }

  void changeTheme(v) async {
    SPUtil? spUtil = await SPUtil.getInstance();
    if (v) {
      _setTheme(ThemeMode.dark);
    } else {
      _setTheme(ThemeMode.light);
    }
    spUtil?.putIsDarkModeEnabled(v);
  }
}
