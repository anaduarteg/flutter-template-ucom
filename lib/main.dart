// ignore_for_file: library_private_types_in_public_api

import 'package:finpay/config/textstyle.dart';
import 'package:finpay/view/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuración de la UI del sistema
  _configureSystemUI();
  
  runApp(const MyApp());
}

void _configureSystemUI() {
  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setCustomTheme(BuildContext context, int index) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setCustomTheme(index);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void setCustomTheme(int index) {
    setState(() {
      AppTheme.isLightTheme = index == 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FinPay',
      theme: AppTheme.getTheme(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
