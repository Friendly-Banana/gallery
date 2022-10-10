import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The ultimate loading indicator for everything
Widget get loadingWidget => const ColoredBox(color: Colors.blueGrey);

class Config {
  static const Map<Curve, String> animationCurves = {
    Curves.easeInOut: "EaseInOut (Default)",
    Curves.linear: "Linear",
    Curves.decelerate: "Decelerate",
    Curves.fastLinearToSlowEaseIn: "FastLinearToSlowEaseIn",
    Curves.ease: "Ease",
    Curves.easeIn: "EaseIn",
    Curves.easeInToLinear: "EaseInToLinear",
    Curves.easeInSine: "EaseInSine",
    Curves.easeInQuad: "EaseInQuad",
    Curves.easeInCubic: "EaseInCubic",
    Curves.easeInQuart: "EaseInQuart",
    Curves.easeInQuint: "EaseInQuint",
    Curves.easeInExpo: "EaseInExpo",
    Curves.easeInCirc: "EaseInCirc",
    Curves.easeInBack: "EaseInBack",
    Curves.easeOut: "EaseOut",
    Curves.linearToEaseOut: "LinearToEaseOut",
    Curves.easeOutSine: "EaseOutSine",
    Curves.easeOutQuad: "EaseOutQuad",
    Curves.easeOutCubic: "EaseOutCubic",
    Curves.easeOutQuart: "EaseOutQuart",
    Curves.easeOutQuint: "EaseOutQuint",
    Curves.easeOutExpo: "EaseOutExpo",
    Curves.easeOutCirc: "EaseOutCirc",
    Curves.easeOutBack: "EaseOutBack",
    Curves.easeInOutSine: "EaseInOutSine",
    Curves.easeInOutQuad: "EaseInOutQuad",
    Curves.easeInOutCubic: "EaseInOutCubic",
    Curves.easeInOutCubicEmphasized: "EaseInOutCubicEmphasized",
    Curves.easeInOutQuart: "EaseInOutQuart",
    Curves.easeInOutQuint: "EaseInOutQuint",
    Curves.easeInOutExpo: "EaseInOutExpo",
    Curves.easeInOutCirc: "EaseInOutCirc",
    Curves.easeInOutBack: "EaseInOutBack",
    Curves.fastOutSlowIn: "FastOutSlowIn",
    Curves.slowMiddle: "SlowMiddle",
    Curves.bounceIn: "BounceIn",
    Curves.bounceOut: "BounceOut",
    Curves.bounceInOut: "BounceInOut",
    Curves.elasticIn: "ElasticIn",
    Curves.elasticOut: "ElasticOut",
    Curves.elasticInOut: "ElasticInOut",
  };
  static const String imageDir = "images";
  static const String videoDir = "videos";

  static late final PackageInfo packageInfo;
  static late final String appVersion;
  static late final String appDirPath;
  static late VoidCallback onAppDir;

  static late final SharedPreferences _prefs;
  static const String _durKey = "slideDur";
  static const String _animKey = "slideAnim";
  static const String _thumbnailKey = "thumbWidth";
  static const String _modeKey = "dark";
  static const String _unhideKey = "unhideToDownloads";
  static const String _onlyFirstKey = "onlyFirst";

  static late double slideDuration;
  static late Curve slideAnimation;
  static late int logicalThumbnailSize;
  static bool darkMode = true;
  static late bool unhideToDownloads;
  static late bool onlyFirstTry;

  static get realThumbnailSize =>
      (logicalThumbnailSize * WidgetsBinding.instance.window.devicePixelRatio)
          .round();

  static String animationName(Curve curve) =>
      animationCurves[curve] ?? animationCurves.values.first;

  static Curve _getAnimationByName(String? name) {
    if (name != null && animationCurves.containsValue(name)) {
      for (var entry in animationCurves.entries) {
        if (entry.value == name) {
          return entry.key;
        }
      }
    }
    return Curves.easeInOut;
  }

  static Future<void> load() async {
    appDirPath = (await getApplicationDocumentsDirectory()).path;
    onAppDir();

    packageInfo = await PackageInfo.fromPlatform();
    appVersion = "${packageInfo.version}+${packageInfo.buildNumber}";

    _prefs = await SharedPreferences.getInstance();
    slideDuration = _prefs.getDouble(_durKey) ?? 3.5;
    slideAnimation = _getAnimationByName(_prefs.getString(_animKey));
    logicalThumbnailSize = _prefs.getInt(_thumbnailKey) ?? 256;
    darkMode = _prefs.getBool(_modeKey) ?? true;
    unhideToDownloads = _prefs.getBool(_unhideKey) ?? false;
    onlyFirstTry = _prefs.getBool(_onlyFirstKey) ?? true;
  }

  static void save() {
    _prefs.setDouble(_durKey, slideDuration);
    _prefs.setString(_animKey, animationName(slideAnimation));
    _prefs.setInt(_thumbnailKey, logicalThumbnailSize);
    _prefs.setBool(_modeKey, darkMode);
    _prefs.setBool(_unhideKey, unhideToDownloads);
    _prefs.setBool(_onlyFirstKey, onlyFirstTry);
  }
}
