import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'en_US.dart';
import 'ja_JP.dart';
import 'vi_VN.dart';

class TranslationService extends Translations {
  static Locale? get locale => Get.deviceLocale;
  static const fallbackLocale = Locale('en', 'US');

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en_US,
        'vi_VN': vi_VN,
        'ja_JP': ja_JP,
      };
}
