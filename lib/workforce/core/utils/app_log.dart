import 'package:awign/workforce/core/utils/constants.dart';
import 'package:logger/logger.dart';

/// A Logger For Flutter Apps
/// Usage:
/// 1) AppLog.i("Info Message");
/// 2) AppLog.i("Home Page", tag: "User Logging");
var logger = Logger();

class AppLog {
  static const _DEFAULT_TAG_PREFIX = Constants.appName;

  ///Print general logs
  static v(String message, {String tag = _DEFAULT_TAG_PREFIX}) {
    logger.v("$tag: $message");
  }

  ///Print info logs
  static i(String message, {String tag = _DEFAULT_TAG_PREFIX}) {
    logger.i("$tag: $message");
  }

  ///Print debug logs
  static d(String message, {String tag = _DEFAULT_TAG_PREFIX}) {
    logger.d("$tag: $message");
  }

  ///Print warning logs
  static w(String message, {String tag = _DEFAULT_TAG_PREFIX}) {
    logger.w("$tag: $message");
  }

  ///Print error logs
  static e(String message, {String tag = _DEFAULT_TAG_PREFIX}) {
    logger.e("$tag: $message");
  }

  ///Print failure logs
  static wtf(String message, {String tag = _DEFAULT_TAG_PREFIX}) {
    logger.wtf("$tag: $message");
  }
}
