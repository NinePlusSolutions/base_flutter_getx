import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/shared/constants/assets_path.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  _initScreen() async {
    await Future.delayed(const Duration(seconds: 1));

    if (Platform.isIOS) {
      FlutterNativeSplash.remove();
    }
    final firstInstall = StorageService.firstInstall;
    await Future.delayed(const Duration(milliseconds: 300));
    if (firstInstall) {
      NavigatorHelper.toOnBoardScreen();
    }

    final accessToken = StorageService.token;
    NavigatorHelper.toAuth();
    // if (accessToken != null) {
    //   NavigatorHelper.toHome();
    // } else {
    //   NavigatorHelper.toAuth();
    // }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: Center(
        child: Image.asset(
          AssetPath.iconNinePlus,
          width: 200.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
